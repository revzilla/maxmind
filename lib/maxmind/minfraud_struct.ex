defmodule Maxmind.MinfraudStruct do
  @moduledoc """
  An ExConstructor struct used to parse and clean Maxmind Minfraud API response data
  """
  defstruct order_id: nil,
            client_ip: nil,
            city: nil,
            region: nil,
            postal: nil,
            domain: nil,
            country: nil,
            bin: nil,
            cust_phone: nil,
            requested_type: nil,
            forwarded_ip: nil,
            email: nil,
            session_id: nil,
            shipping_address: nil,
            shipping_city: nil,
            shipping_region: nil,
            shipping_postal: nil,
            shipping_country: nil,
            user_agent: nil,
            accept_language: nil,
            country_match: false,
            country_code: nil,
            high_risk_country: false,
            distance: nil,
            ip_region: nil,
            ip_city: nil,
            ip_latitude: nil,
            ip_longitude: nil,
            ip_isp: nil,
            ip_org: nil,
            anonymous_proxy: false,
            proxy_score: nil,
            is_transparent_proxy: false,
            free_mail: false,
            carder_email: false,
            high_risk_username: false,
            high_risk_password: false,
            bin_match: false,
            bin_country: nil,
            bin_name_match: false,
            bin_name: nil,
            bin_phone_match: false,
            bin_phone: nil,
            phone_in_billing_location: false,
            ship_forward: false,
            city_postal_match: false,
            ship_city_postal_match: false,
            score: nil,
            explanation: nil,
            risk_score: nil,
            spam_score: nil,
            queries_remaining: nil,
            maxmind_id: nil,
            error: nil,
            err: nil,
            cust_phone_in_billing_loc: false,
            maxmind_i_d: nil,
            is_trans_proxy: false,
            country_code: nil
  use ExConstructor

  @doc false
  def clean_data(minfraud_struct) do
    map = Enum.reduce Map.from_struct(minfraud_struct), %{}, fn {key, value}, new_map ->
      {k, v} =
        {key, value}
        |> convert_to_utf8
        |> empty_string_to_nil
        |> convert_string
        |> clean_boolean_data

      Map.put(new_map, k, v)
    end

    __MODULE__.new(map)
  end

  @doc false
  def merge_fields(minfraud_struct) do
    fields_to_merge = %{
      :error => minfraud_struct.err,
      :phone_in_billing_location => minfraud_struct.cust_phone_in_billing_loc,
      :maxmind_id => minfraud_struct.maxmind_i_d,
      :is_transparent_proxy => minfraud_struct.is_trans_proxy,
      :country => minfraud_struct.country_code,
      :region => minfraud_struct.ip_region,
      :city => minfraud_struct.ip_city
    }

    new_map = Map.merge(Map.from_struct(minfraud_struct), fields_to_merge)
    __MODULE__.new(new_map)
  end

  defp empty_string_to_nil({key, ""}), do: {key, nil}
  defp empty_string_to_nil({key, nil}), do: {key, nil}
  defp empty_string_to_nil({key, v}), do: {key, v}

  defp clean_boolean_data({key, "Yes"}), do: {key, true}
  defp clean_boolean_data({key, "NA"}), do: {key, false}
  defp clean_boolean_data({key, "No"}), do: {key, false}
  defp clean_boolean_data({key, v}), do: {key, v}

  defp convert_string({key, value}) do
    cond do
      key in float_fields() -> convert_float({key, value})
      key in integer_fields() -> convert_integer({key, value})
      key -> {key, value}
    end
  end

  defp convert_integer({key, nil}), do: {key, nil}
  defp convert_integer({key, value}) do
    new_value = case Integer.parse(String.replace(value, ~r/[^0-9]/, "")) do
      :error -> nil
      {val, _} -> val
    end

    {key, new_value}
   end

  defp convert_float({key, nil}), do: {key, nil}
  defp convert_float({key, value}) do
    new_value = case Float.parse(String.replace(value, ~r/[^0-9.]/, "")) do
      :error -> nil
      {val, _} -> val
    end

    {key, new_value}
  end

  defp convert_to_utf8({key, value}) do
    cond do
      key in float_fields() -> {key, value}
      key in integer_fields() -> {key, value}
      value == true || value == false -> {key, value}
      is_nil(value) -> {key, value}
      key -> {key, :iconv.convert("ISO-8859-1", "UTF-8", value)}
    end
  end

  defp float_fields do
    [:ip_latitude, :ip_longitude, :proxy_score, :score, :risk_score, :spam_score]
  end

  defp integer_fields do
    [:order_id, :distance, :queries_remaining]
  end
end
