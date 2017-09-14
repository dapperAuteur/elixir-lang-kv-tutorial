defmodule KVServer.Command do
  @doc ~s"""
  Parses the given `line` into a command.
  ## Examples
  iex> KVServer.Command.parse "CREATE shopping\\r\\n"
  {:ok, {:create, "shopping"}}
  """
  # def parse(_line) do
  #   :not_implemented
  # end

  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
    end
  end
end
