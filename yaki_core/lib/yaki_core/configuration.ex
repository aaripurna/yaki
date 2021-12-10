defmodule YakiCore.Configuration do
  @type variant() :: {atom(), {height :: number(), {width :: number()}}}

  defstruct [:adapters, :default_adapter, :variants]

  @type t() :: %__MODULE__{
          adapters: list({atom(), module()}),
          default_adapter: {atom(), module()},
          variants: list(variant())
        }

  use GenServer

  @impl true
  def init(_args) do
    {:ok,
     %YakiCore.Configuration{
       adapters: [],
       variants: []
     }}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def adapters do
    GenServer.call(__MODULE__, :adapters)
  end

  def default_adapter do
    GenServer.call(__MODULE__, :default_adapter)
  end

  @spec add_adapter({atom(), module()}) :: :ok
  def add_adapter({_name, _handler} = adapter) do
    GenServer.cast(__MODULE__, {:add_adapter, adapter})
  end

  @spec set_default_adapter(atom()) :: :ok
  def set_default_adapter(name) do
    GenServer.cast(__MODULE__, {:set_default_adapter, name})
  end

  @spec set_variants(list(variant())) :: :ok
  def set_variants(variants) do
    GenServer.cast(__MODULE__, {:set_variants, variants})
  end

  @spec variants :: list(variant())
  def variants do
    GenServer.call(__MODULE__, :variants)
  end

  @impl true
  def handle_call(:adapters, _from, state) do
    {:reply, state.adapters, state}
  end

  @impl true
  def handle_call(:default_adapter, _from, state) do
    {:reply, state.default_adapter, state}
  end

  @impl true
  def handle_call(:variants, _from, state) do
    {:reply, state.variants, state}
  end

  @impl true
  def handle_cast({:add_adapter, adapter}, state) do
    adapters = [adapter | Map.get(state, :adapters)]
    {:noreply, Map.put(state, :adapters, adapters)}
  end

  @impl true
  def handle_cast({:set_default_adapter, name}, state) do
    {:noreply, Map.put(state, :default_adapter, {name, Keyword.get(state.adapters, name)})}
  end

  @impl true
  def handle_cast({:set_variants, variants}, state) do
    {:noreply, Map.put(state, :variants, variants)}
  end
end
