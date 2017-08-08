defmodule Resolver.Mixfile do
  use Mix.Project

  def project do
    [app: :resolver,
     version: "0.0.2",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger],
     mod: {Resolver.Application, []}]
  end

  defp deps do
    []
  end
end
