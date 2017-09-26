defmodule Maxmind.MinfraudTest do
  use ExUnit.Case
  import Maxmind.TestHelpers

  setup context do
    {:ok,
      license_key: Application.put_env(:maxmind_minfraud, :license_key, "fake"),
      minfraud_bypass: (if context[:skip_minfraud_bypass], do: nil, else: build_minfraud_bypass()),
      test_data: %{:i => "108.52.186.193", :city => "Philadelphia", :region => "PA", :postal => "19130"}
    }
  end

  @tag :skip_minfraud_bypass
  test """
  minfraud/1
  when the endpoint configuration is not set
  raises an error
  """ do
    Application.put_env(:maxmind_minfraud, :minfraud_endpoint, nil)

    assert_raise Maxmind.ConfigError, "missing config for :minfraud_endpoint", fn ->
      Maxmind.minfraud(%{})
    end
  end

  @tag :skip_minfraud_bypass
  test "minfraud/1 throws required field error when missing params" do
    err_msg = "missing required field. Be sure Client IP, City, Postal Code, Region and License Key are included"
    Application.put_env(:maxmind_minfraud, :minfraud_endpoint, "fake")

    assert_raise ArgumentError, err_msg, fn ->
      Maxmind.minfraud(%{})
    end
  end

  test """
  minfraud/1
  when the service endpoint is down
  returns an error
  """, %{minfraud_bypass: minfraud_bypass, test_data: test_data} do
    minfraud_bypass
    |> simulate_service_down

    result = Maxmind.minfraud(test_data)

    assert result == {:error, :econnrefused}
  end

  test "Can pass map of fields to Maxmind minfraud function",
    %{
      minfraud_bypass: minfraud_bypass,
      test_data: test_data
    } do
      response = generic_response_body(0.23)

      minfraud_bypass
      |> simulate_service_response(:ok, response, fn(conn) -> conn.method == "GET" end)

      assert Maxmind.minfraud(test_data).risk_score == 0.23
  end

  test "Can take additional params", %{minfraud_bypass: minfraud_bypass, test_data: test_data} do
    test_data = Map.merge(test_data, %{:user_agent => "Mozilla/5.0", :accept_language => "en-US,en;q=0.8"})
    response = generic_response_body(0.12)

    minfraud_bypass
    |> simulate_service_response(:ok, response, fn(conn) -> conn.method == "GET" end)

    assert Maxmind.minfraud(test_data).risk_score == 0.12
  end

  @tag :skip_minfraud_bypass
  test "Will encrypt fields that need to be encrypted" do
    test_data = %{
      :email => "tyler@email.test",
      :password => "notrealpassword",
      :username => "tcain"
    }

    hashed = Maxmind.Minfraud.md5_hash_data(test_data)
    assert hashed[:email] != "tyler@email.test"
    assert hashed[:password] != "notrealpassword"
    assert hashed[:username] != "tcain"
  end
end
