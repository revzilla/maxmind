# Maxmind Minfraud

A simple client for the [Maxmind Minfraud API](https://www.maxmind.com/en/minfraud-services).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add maxmind to your list of dependencies in `mix.exs`:

        def deps do
          [{:maxmind_minfraud, "~> 1.0.0"}]
        end

  2. Ensure maxmind is started before your application:

        def application do
          [applications: [:maxmind_minfraud]]
        end

## Configuration

You must configure two values: `license_key` and `minfraud_endpoint`. Add the following to your `config/config.exs`:

```
config :maxmind_minfraud,
  license_key: YOUR_LICENSE_KEY,
  minfraud_endpoint: MINFRAUD_API_URL
```

## Usage

```
fraud_data = %{
  :i => "108.52.186.193",
  :city => "Philadelphia",
  :region => "PA",
  :postal => "19130"
}
{:ok, response} = Maxmind.query(fraud_data)
```