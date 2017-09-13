defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry with the given options.
  `:name` is always required.
  """

  def start_link(opts) do
    # 1. Pass the name to GenServer's init
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """

  def lookup(server, name) do
    # 2. Lookup is now done directly in ETS, without accessing the server
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """

  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  ## Server Callbacks

  def init(table) do
    # 3. We have replaced the names map by the ETs table
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  # handle_call/3 must be used for synchronous requests. This should be the default choice as waiting for the server reply is a useful backpressure mechanism.

  # 4. The previous handle_call callback for lookup was removed

  # handle_cast/2 must be used for asynchronous requests, when you don't care about a reply. A cast does not even guarantee the server has received the message and, for this reason, should be used sparingly. For example, the create/2 function we have defined in this chapter should have used call/2. We have used cast/2 for didactic purposes.

  #this version invokes 'start_bucket'

  def handle_call({:create, name}, _from, {names, refs}) do
    # 5. Read and write to the ETS table instead of the map
    case lookup(names, name) do
      {:ok, pid} ->
        {:reply, pid, {names, refs}}
      :error ->
        {:ok, pid} = KV.BucketSupervisor.start_bucket()
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      :ets.insert(names, {name, pid})
      {:reply, pid, {names, refs}}
    end
  end

  # handle_info/2 must be used for all other messages a server may receive that are not sent via GenServer.call/2 or GenServer.cast/2, including regular messages sent with send/2. The monitoriing :DOWN messages are such an example of this.

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
