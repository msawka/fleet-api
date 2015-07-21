defmodule FleetApi.Http.ResponseTest do
  use ExUnit.Case

  alias FleetApi.Http.Response

  test "process a successful request" do
    api_response = {:ok, %{status_code: 200, headers: [{'Content-Type', 'application/json'}], body: "{\"cool\": \"a cool response\"}"}}
    response = Response.process(fn -> api_response end)

    assert response.success? == true
    assert response.status == 200
    assert response.body["cool"] == "a cool response"
  end

  test "process a complex JSON object" do
    api_response = {:ok, %{status_code: 200, headers: [{'Content-Type', 'application/json'}], body: "{\"node\": {\"id\": 1, \"name\": \"test\"}}"}}
    response = Response.process(fn -> api_response end)

    assert response.body["node"] == %{"id" => 1, "name" => "test"}
  end

  test "process retains raw body" do
    api_response = {:ok, %{status_code: 200, headers: [{'Content-Type', 'application/json'}], body: "{\"node\": {\"id\": 1, \"name\": \"test\"}}"}}
    response = Response.process(fn -> api_response end)

    assert response.raw_body == "{\"node\": {\"id\": 1, \"name\": \"test\"}}"
  end

  test "process headers with multiple values" do
    api_response = {:ok, %{status_code: 200, headers: [{'cont', '[]'}], body: "{\"cool\": \"a cool response\"}"}}
    response = Response.process(fn -> api_response end)

    assert response.success? == true
    assert response.status == 200
    assert response.body["cool"] == "a cool response"
  end

  # =====================
  # extract_identifier_from_location_header tests

  test "extract_identifier_from_location_header - absolute path" do
    api_response = {:ok, %{status_code: 201, headers: [{'location', 'https://openaperture-mgr.host.co/messsaging/brokers/1'}], body: ""}}
    response = Response.process(fn -> api_response end)

    assert Response.extract_identifier_from_location_header(response) == "1"
  end

  test "extract_identifier_from_location_header - relative path" do
    api_response = {:ok, %{status_code: 201, headers: [{'location', '/messsaging/brokers/1'}], body: ""}}
    response = Response.process(fn -> api_response end)

    assert Response.extract_identifier_from_location_header(response) == "1"
  end  

  test "extract_identifier_from_location_header - relative path with ending slash" do
    api_response = {:ok, %{status_code: 201, headers: [{'location', '/messsaging/brokers/1/'}], body: ""}}
    response = Response.process(fn -> api_response end)

    assert Response.extract_identifier_from_location_header(response) == "1"
  end

  test "extract_identifier_from_location_header - no location header" do
    api_response = {:ok, %{status_code: 201, headers: [{'cont', '[]'}], body: ""}}
    response = Response.process(fn -> api_response end)

    assert Response.extract_identifier_from_location_header(response) == ""
  end

  test "extract_identifier_from_location_header - empty location header" do
    api_response = {:ok, %{status_code: 201, headers: [{'location', ''}], body: ""}}
    response = Response.process(fn -> api_response end)

    assert Response.extract_identifier_from_location_header(response) == ""
  end  
end
