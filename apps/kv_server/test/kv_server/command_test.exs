defmodule KVServer.CommandTest do
  use ExUnit.Case, async: true
  doctest KVServer.Command

  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
    end
  end
end
