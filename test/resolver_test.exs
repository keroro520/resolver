defmodule ResolverTest do
  use ExUnit.Case

  @resolve_size 100

  test "resolve www.upyun.com" do
    assert {:ok, _addr} = Resolver.resolve("www.upyun.com")
    for index <- 0..@resolve_size-1 do
      assert [{{^index, "www.upyun.com"}, _}] = :ets.lookup(:resolve_ets, {index, "www.upyun.com"})
    end
  end

  test "resolve www.invalid_upyun.com" do
    assert {:error, :nxdomain} = Resolver.resolve("www.invalid_upyun.com")
  end

  test "when nxdomain, reuse the previous addresses" do
    hostaddrs = for index <- 0..@resolve_size-1, do: {{index, "www.reuse_upyun.com"}, "127.0.0.1"}
    :ets.insert(:resolve_ets, hostaddrs)

    assert {:ok, _addr} = Resolver.resolve("www.reuse_upyun.com")
    for index <- 0..@resolve_size-1 do
      assert [{{^index, "www.reuse_upyun.com"}, "127.0.0.1"}] = :ets.lookup(:resolve_ets, {index, "www.reuse_upyun.com"})
    end
    assert {:error, :nxdomain} = GenServer.call(Resolver, {:resolve, "www.reuse_upyun.com"})
    send(Resolver, :resolve)
    :timer.sleep(1000)
    assert {:ok, _addr} = Resolver.resolve("www.reuse_upyun.com")
    for index <- 0..@resolve_size-1 do
      assert [{{^index, "www.reuse_upyun.com"}, "127.0.0.1"}] = :ets.lookup(:resolve_ets, {index, "www.reuse_upyun.com"})
    end
  end
end
