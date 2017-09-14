defmodule KVServer do
  require Logger
  @moduledoc """
  Documentation for KVServer.
  """

  @doc """
  Hello world.

  ## Examples

      iex> KVServer.hello
      :world

  """
  def hello do
    :world
  end

  @doc """
  Starts accepting connections on the given `port`.
  """

  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` -receives data as binaries (instead of lists)
    # 2. `packet: :line` -receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    IO.puts("I'm here.")

    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    IO.puts("'Now we can get started.' -loop_acceptor")
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(KVServer.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    IO.puts("I'm reading.")
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    IO.puts("I'm writing.")
    :gen_tcp.send(socket, line)
  end
end
