defmodule Maxmind.TestHelpers do
  @moduledoc "Bypass helpers for testing service interaction"

  @doc "Creates a Bypass listener to act as a double for the actual Maxmind Minfraud API endpoint"
  @spec build_minfraud_bypass :: any
  def build_minfraud_bypass do
    bypass = Bypass.open
    Application.put_env(:maxmind_minfraud, :minfraud_endpoint, "http://localhost:#{bypass.port}")
    bypass
  end

  @doc "Simulates that the provided Bypass listener is not accepting connections"
  @spec simulate_service_down(any) :: nil
  def simulate_service_down(bypass) do
    Bypass.down(bypass)
    nil
  end

  @spec simulate_service_response(
    any, Plug.Conn.status, String.t, (Plug.Conn.t -> boolean)) :: no_return
  def simulate_service_response(bypass, status, body, fun) when is_function(fun) do
    Bypass.expect(bypass, fn(conn) ->
      if fun.(conn |> Plug.Conn.fetch_query_params) do
        Plug.Conn.resp(conn, status, body)
      end
    end)
  end

  def generic_response_body(risk_score) do
    # credo:disable-for-next-line Credo.Check.Readability.MaxLineLength
    ~s(distance=0;countryMatch=;countryCode=US;freeMail=No;anonymousProxy=No;binMatch=NA;binCountry=;err=;proxyScore=0.00;ip_region=PA;ip_city=Philadelphia;ip_latitude=39.9494;ip_longitude=-75.1457;binName=;ip_isp=Verizon Fios;ip_org=Verizon Fios;binNameMatch=NA;binPhoneMatch=NA;binPhone=;custPhoneInBillingLoc=;highRiskCountry=No;queriesRemaining=1082;cityPostalMatch=;shipCityPostalMatch=;maxmindID=FODJ6EEG;ip_asnum=AS701 MCI Communications Services, Inc. d/b/a Verizon Business;ip_userType=residential;ip_countryConf=99;ip_regionConf=97;ip_cityConf=87;ip_postalCode=19106;ip_postalConf=42;ip_accuracyRadius=2;ip_netSpeedCell=Cable/DSL;ip_metroCode=504;ip_areaCode=215;ip_timeZone=America/New_York;ip_regionName=Pennsylvania;ip_domain=verizon.net;ip_countryName=United States;ip_continentCode=NA;ip_corporateProxy=No;riskScore=#{risk_score};prepaid=;minfraud_version=1.3;service_level=premium)
  end

  def response_body_from_order(risk_score) do
    # credo:disable-for-next-line Credo.Check.Readability.MaxLineLength
    ~s(distance=6;countryMatch=Yes;countryCode=US;freeMail=No;anonymousProxy=No;binMatch=NA;binCountry=;err=;proxyScore=0.00;ip_region=PA;ip_city=Philadelphia;ip_latitude=39.8950;ip_longitude=-75.1671;binName=;ip_isp=Verizon Fios;ip_org=Verizon Fios;binNameMatch=NA;binPhoneMatch=NA;binPhone=;custPhoneInBillingLoc=No;highRiskCountry=No;queriesRemaining=1079;cityPostalMatch=Yes;shipCityPostalMatch=Yes;maxmindID=M164MZS7;ip_asnum=AS701 MCI Communications Services, Inc. d/b/a Verizon Business;ip_userType=residential;ip_countryConf=99;ip_regionConf=91;ip_cityConf=60;ip_postalCode=19112;ip_postalConf=20;ip_accuracyRadius=11;ip_netSpeedCell=Cable/DSL;ip_metroCode=504;ip_areaCode=215;ip_timeZone=America/New_York;ip_regionName=Pennsylvania;ip_domain=verizon.net;ip_countryName=United States;ip_continentCode=NA;ip_corporateProxy=No;carderEmail=No;shipForward=No;riskScore=#{risk_score};prepaid=;minfraud_version=1.3;service_level=premium)
  end
end
