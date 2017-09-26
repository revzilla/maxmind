defmodule Maxmind do
  @moduledoc """
  Basic Maxmind module.
  """
  defmodule ConfigError do
    @moduledoc """
    Raised at runtime when a config variable is missing.
    """
    defexception [:message]

    @spec exception(atom()) :: Elixir.Exception.t()
    def exception(value) do
      message = "missing config for :#{value}"

      %ConfigError{message: message}
    end
  end

  def license, do: get_env(:license_key)
  def minfraud_endpoint, do: get_env(:minfraud_endpoint)

  @spec get_env(atom()) :: any()
  defp get_env(key), do: Application.get_env(:maxmind_minfraud, key) || raise ConfigError, key

  @doc "Takes a map of params and returns minfraud results in a struct"
  def minfraud(query) do
    case Maxmind.Minfraud.send_request(query) do
      {:ok, body} -> Maxmind.Minfraud.parse_response(body)
      {:error, reason} -> {:error, reason}
    end
  end
end
