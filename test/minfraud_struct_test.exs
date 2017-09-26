defmodule Maxmind.MinfraudStructTest do
  use ExUnit.Case, async: false
  alias Maxmind.MinfraudStruct

  test "Can create minfraud struct from map of data" do
    map = %{:city => "test", :region => "test"}
    minfraud_struct = MinfraudStruct.new(map)
    assert minfraud_struct.city == "test"
  end

  test "Can convert bad data to appropriate value" do
    map = %{:country_match => "NA", :risk_score => "0.23", :queries_remaining => "221", :high_risk_country => "Yes"}
    minfraud_struct =
      map
      |> MinfraudStruct.new
      |> MinfraudStruct.clean_data

    assert minfraud_struct.country_match == false
    assert minfraud_struct.queries_remaining == 221
    assert minfraud_struct.risk_score == 0.23
    assert minfraud_struct.high_risk_country == true
  end

  test "Normalizes field mappings" do
    map = %{
      :err => "test err",
      :custPhoneInBillingLoc => "Yes",
      :maxmindID => "bfh287",
      :isTransProxy => "Yes"
    }

    minfraud_struct =
      map
      |> MinfraudStruct.new
      |> MinfraudStruct.clean_data
      |> MinfraudStruct.merge_fields

    assert minfraud_struct.error == "test err"
    assert minfraud_struct.phone_in_billing_location == true
    assert minfraud_struct.maxmind_id == "bfh287"
    assert minfraud_struct.is_transparent_proxy == true
  end

  test "Can convert non UTF8 string fields" do
    map = %{
      :err => "test err",
      :custPhoneInBillingLoc => "Yes",
      :maxmindID => "bfh287",
      :isTransProxy => "Yes",
      :explanation => "âabcd"
    }

    minfraud_struct =
      map
      |> MinfraudStruct.new
      |> MinfraudStruct.clean_data

    assert minfraud_struct.explanation == "Ã¢abcd"
  end

  test "Does not fail on invalid float or integer" do
    map = %{
      :score => "12.3ham",
      :risk_score => "arthur",
      :queries_remaining => "z",
      :order_id => "40q",
      :spam_score => "10"
    }

    minfraud_struct =
      map
      |> MinfraudStruct.new
      |> MinfraudStruct.clean_data

    assert minfraud_struct.score == 12.3
    assert minfraud_struct.risk_score == nil
    assert minfraud_struct.queries_remaining == nil
    assert minfraud_struct.order_id == 40
    assert minfraud_struct.spam_score == 10.0
  end
end
