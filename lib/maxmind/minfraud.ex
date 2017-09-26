defmodule Maxmind.Minfraud do
  @moduledoc """
  Designed to perform and parse requests to Maxmind's Minfraud API endpoint.
  """

  require Logger
  use HTTPoison.Base

  alias Maxmind.MinfraudStruct

  @required_fields [:i, :city, :region, :postal]
  @encryption_required_fields [:email, :username, :password]

  @field_format_map %{
    :bin_name => :binName,
    :cust_phone => :custPhone,
    :requested_type => :requested_type,
    :forwarded_ip => :forwardedIP,
    :email => :emailMD5,
    :username => :usernameMD5,
    :password => :passwordMD5,
    :shipping_address => :shipAddr,
    :shipping_city => :shipCity,
    :shipping_region => :shipRegion,
    :shipping_postal => :shipPostal,
    :shipping_country => :shipCountry,
    :transaction_id => :txnID,
    :session_id => :sessionID
  }

  @headers [
    {"Accept", "application/json"},
    {"User-Agent", "Maxmind Elixir/0.1"},
    {"Accept-Encoding", "gzip"},
    {"Content-Type", "application/x-www-form-urlencoded"}
  ]

  @doc "Send Minfraud request"
  @spec send_request(map(), list()) :: {:ok, String.t} | {:error, atom()}
  def send_request(params, options \\ []) do
    endpoint = Maxmind.minfraud_endpoint
    validate(params)

    :get
    |> request(endpoint, request_body(params), @headers, options)
    |> process_response
  end

  @doc false
  defp request_body(params) do
    params
    |> Map.merge(defaults())
    |> md5_hash_data
    |> remap_params
    |> URI.encode_query
  end

  @doc "Map of all default required params that are not provided in send_request."
  @spec defaults :: map
  defp defaults do
    %{
      :license_key => Maxmind.license
    }
  end

  @doc "Takes a response body map and returns a MinfraudStruct."
  @spec parse_response(String.t) :: %MinfraudStruct{}
  def parse_response(body) do
    body
    |> String.trim
    |> String.replace(";", "&")
    |> URI.decode_query
    |> create_struct
  end

  @doc false
  defp process_response({:ok, %{status_code: 200, body: body}}), do: {:ok, body}
  defp process_response({:ok, %{status_code: 401}}),
    do: {:error, :unauthorized}
  defp process_response({:ok, %{status_code: 404}}),
    do: {:error, :not_found}
  defp process_response({:ok, %{body: body}}),
    do: {:error, body}
  defp process_response({:error, %{reason: :timeout}}), do: {:error, :timeout}
  defp process_response({:error, %HTTPoison.Error{id: nil, reason: :econnrefused}}), do: {:error, :econnrefused}

  @doc """
    Takes URI decoded map and creates a MinfraudStruct.
    Minfraud Struct serves as a way to whitelist response params
    and convert field data to an appropriate format
  """
  defp create_struct(map) do
    map
    |> MinfraudStruct.new
    |> MinfraudStruct.clean_data
    |> MinfraudStruct.merge_fields
  end

  @doc false
  def md5_hash_data(params) do
    map = Enum.reduce params, %{}, fn {key, value}, new_map ->
      if Enum.member?(@encryption_required_fields, key) do
        Map.put(new_map, key, md5_hash_field(value))
      else
        Map.put(new_map, key, value)
      end
    end

    map
  end

  defp validate(params) do
    required = params |> Map.take(@required_fields)

    if Enum.count(required) != Enum.count(@required_fields) do
      err_msg = "missing required field. Be sure Client IP, City, Postal Code, Region and License Key are included"
      raise ArgumentError, message: err_msg
    end
  end

  defp md5_hash_field(field) do
    hashed_field = :crypto.hash(:md5, String.downcase(field))
    hashed_field |> Base.encode16 |> String.downcase
  end

  defp remap_params(params) do
    map = Enum.reduce params, %{}, fn {key, value}, new_map ->
      if Enum.member?(Map.keys(@field_format_map), key) do
        Map.put(new_map, @field_format_map[key], value)
      else
        Map.put(new_map, key, value)
      end
    end

    map
  end
end
