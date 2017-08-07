defmodule Resolver do
  use GenServer
  require Logger

  @resolve_ets :resolve_ets
  @resolve_size 100

  @type host :: binary    # www.upyun.com
  @type address :: binary # 192.168.1.100

  # =============================================================================
  # Public Functions
  # =============================================================================

  def start_link do
    GenServer.start_link __MODULE__, [], name: __MODULE__
  end

  @spec resolve(host) :: {:ok, address} | {:error, term}
  def resolve(host) do
    case :ets.lookup(@resolve_ets, {random, host}) do
      [] -> GenServer.call __MODULE__, {:resolve, host}
      [{_, address}] -> {:ok, address}
    end
  end

  # =============================================================================
  # GenServer Callbacks
  # =============================================================================

  def init([]) do
    :ets.new(@resolve_ets, [:set, :public, :named_table])

    :erlang.send_after(1000, self, :resolve)
    {:ok, []}
  end

  def handle_call({:resolve, host}, _from, hosts) do
    case Enum.member?(hosts, host) do
      true ->
        [{_, address}] = :ets.lookup(@resolve_ets, {0, host})
        {:reply, {:ok, address}, hosts}
      false ->
        case do_resolve(host) do
          {:ok, address}   -> {:reply, {:ok, address}, [host | hosts]}
          {:error, reason} -> {:reply, {:error, reason}, hosts}
        end
    end
  end

  def handle_info(:resolve, hosts) do
    Enum.each(hosts, &do_resolve/1)
    :erlang.send_after(1000, self, :resolve)

    {:noreply, hosts}
  end

  # =============================================================================
  # Internal Functions
  # =============================================================================

  def random do
    rem(System.unique_integer([:positive]), @resolve_size)
  end

  defp do_resolve(host) do
    case :inet.getaddrs(to_char_list(host), :inet) do
      {:ok, addrs} ->
        addrs1 = Enum.map(addrs, fn({a, b, c, d}) -> "#{a}.#{b}.#{c}.#{d}" end)
        addrs2 = Enum.map(0..@resolve_size-1, &{{&1, host}, Enum.random(addrs1)})
        :ets.insert(@resolve_ets, addrs2)
        {:ok, hd(addrs1)}
      {:error, reason} ->
        Logger.error "resolve #{host} error: #{inspect reason}"
        {:error, reason}
    end
  end
end
