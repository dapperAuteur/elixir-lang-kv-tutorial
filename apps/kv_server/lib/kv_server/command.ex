defmodule KVServer.Command do
  @doc """
  Runs the given command.
  """
  def run(command)

  def run({:create, bucket}, pid) do
    KV.Registry.create(pid, bucket)
    {:ok, "OK\r\n"}
  end

  def run({:get, bucket, key}, pid) do
    lookup bucket, fn pid ->
      value = KV.Bucket.get(pid, key)
      {:ok, "#{value}\r\nOK\r\n"}
    end
  end

  def run({:put, bucket, key, value}, pid) do
    lookup bucket, fn pid ->
      KV.Bucket.put(pid, key, value)
      {:ok, "OK\r\n"}
    end
  end

  def run({:delete, bucket, key}, pid) do
    lookup bucket, fn pid ->
      KV.Bucket.delete(pid, key)
      {:ok, "OK\r\n"}
    end
  end

  defp lookup(bucket, callback) do
    case KV.Registry.lookup(KV.Registry, bucket) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
  @doc ~s"""
  Parses the given `line` into a command.

  ## Examples

  iex> KVServer.Command.parse "CREATE shopping\\r\\n"
  {:ok, {:create, "shopping"}}

  iex> KVServer.Command.parse "CREATE shopping\\r\\n"
  {:ok, {:create, "shopping"}}

  iex> KVServer.Command.parse "PUT shopping milk 1\\r\\n"
  {:ok, {:put, "shopping", "milk", "1"}}

  iex> KVServer.Command.parse "GET shopping milk\\r\\n"
  {:ok, {:get, "shopping", "milk"}}

  iex> KVServer.Command.parse "DELETE shopping eggs\\r\\n"
  {:ok, {:delete, "shopping", "eggs"}}

  Unkown commands or commands with the wrong number of arguments return an error:

  iex> KVServer.Command.parse "UNKNOWN shopping exggs\\r\\n"
  {:error, :unknown_command}

  iex> KVServer.Command.parse "GET shopping\\r\\n"
  {:error, :unknown_command}

  iex> 1 + 1
  2

  iex> Enum.map [1, 2, 3], fn(x) ->
  ...> x * 2
  ...> end
  [2, 4, 6]

  iex> Enum.map [1, 2, 3], fn(x) ->
  iex> x + 3
  iex> end
  [4, 5, 6]

  iex> a = 1
  1
  iex> a + 1
  2

  iex> pid = spawn fn -> :ok end
  iex> is_pid(pid)
  true

  iex(1)> [1 + 2,
  ...(1)> 3]
  [3, 3]

  iex(1)> [3 -1,
  iex(1)> 4]
  [2, 4]
  """

  # def parse(_line) do
  #   :not_implemented
  # end

  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
      ["GET", bucket, key] -> {:ok, {:get, bucket, key}}
      ["PUT", bucket, key, value] -> {:ok, {:put, bucket, key, value}}
      ["DELETE", bucket, key] -> {:ok, {:delete, bucket, key}}
      _ -> {:error, :unknown_command}
    end
  end
end
