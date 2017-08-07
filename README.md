# Resolver

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add resolver to your list of dependencies in `mix.exs`:

        def deps do
          [{:resolver, "~> 0.0.1"}]
        end

  2. Ensure resolver is started before your application:

        def application do
          [applications: [:resolver]]
        end

## Usage

```
Resolver.resolve("www.upyun.com")

# {:ok, "115.231.100.108"}
```
