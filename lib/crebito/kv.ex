defmodule Crebito.KV do
  @moduledoc false

  use GenServer

  # Client

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @spec has?(integer()) :: boolean()
  def has?(server \\ __MODULE__, id) do
    GenServer.call(server, {:has, id})
  end

  @spec put(integer()) :: :ok
  def put(server \\ __MODULE__, id) do
    GenServer.cast(server, {:put, id})
  end

  # Callbacks

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:has, id}, _from, state) do
    {:reply, Map.has_key?(state, id), state}
  end

  @impl true
  def handle_cast({:put, id}, state) do
    {:noreply, Map.put_new(state, id, id)}
  end
end
