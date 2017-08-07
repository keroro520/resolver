defmodule Resolver.Application do
  use Application

  def start(_, _), do: Resolver.Supervisor.start_link
  def stop(_), do: :ok
end
