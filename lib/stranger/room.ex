defmodule Stranger.Room do
  @moduledoc ~S"""
  Each room is for a chat between two strangers.

  Only strangers within the `ids` list are allowed to join.
  """

  use GenServer

  @doc ~S"""
  Helper method for calling `Stranger.Room.Supervisor.start_child/2`.
  """
  def create(name, ids) when is_list(ids) do
    Supervisor.start_child(__MODULE__.Supervisor, [name, ids])
  end

  @doc ~S"""
  Starts the GenServer, named globally based on the room name.
  """
  def start_link(name, ids) when is_list(ids) do
    GenServer.start_link(__MODULE__, ids, name: ref(name))
  end

  @doc ~S"""
  Attempts to the join the room. If successful will return `{:ok, pid}`.

  Failing to join will return `{:error, reason}`.
  """
  def join(name, id) do
    case GenServer.whereis(ref(name)) do
      nil ->
        {:error, "Room does not exist"}
      pid ->
        GenServer.call(pid, {:join, id})
    end
  end


  @doc ~S"""
  The ID is only allowed to join if the ID is present in the `ids` list.
  """
  def handle_call({:join, id}, _from, ids) do
    if Enum.member?(ids, id) do
      {:reply, {:ok, self}, ids}
    else
      {:reply, {:error, "ID not allowed to join room"}, ids}
    end
  end


  defp ref(name) do
    {:global, {:room, name}}
  end
end
