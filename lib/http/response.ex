#
# == response.ex
#
# This module contains the ManagerApi response struct and reusable methods for processing responses from the openaperture_manager.
#
require Logger

defmodule FleetApi.Http.Response do
  defstruct body: nil, success?: nil, raw_body: nil, status: nil, headers: nil

  @moduledoc """
  This module contains the ManagerApi response struct and reusable methods for processing responses from the openaperture_manager.
  """ 

  @doc """
  Method to process an incoming http response into a FleetApi.Http.Response

  ## Option Values

  The `request` option defines the http request to be processed

  ## Return values

  FleetApi.Http.Response
  """ 
  @spec process(term) :: term
  def process(request) do
    try do
      process_response request.()
    catch
      kind, error -> FleetApi.Http.Error.process(kind, error)
    end
  end

  @doc """
  Method to process an incoming httpc response into a FleetApi.Http.Response

  ## Option Values

  The `response` option defines the httpc response to be processed

  ## Return values

  FleetApi.Http.Response
  """ 
  @spec from_httpc_response(term) :: term
  def from_httpc_response(response) do
    case response do
      {:ok, {{_http_ver,return_code, _return_code_desc}, headers, body}} -> 
        process_response({:ok, %{status_code: return_code, headers: headers, body: "#{body}"}})
      {:error, {failure_reason, _}} -> 
        process_response({:error, %{reason: "#{inspect failure_reason}"}})
    end
  end

  @doc """
  Method to extract an identifier from the Location header of a response

  ## Option Values

  The `response` option defines the FleetApi.Http.Response

  ## Return values

  String identifier
  """ 
  @spec extract_identifier_from_location_header(term) :: String.t()
  def extract_identifier_from_location_header(response) do
    case extract_location_header(response) do
      nil -> ""
      "" -> ""
      location_header ->
        url = Regex.replace(~r/\/$/, location_header, "")
        uri = URI.parse(url)
        uri_path = String.split(uri.path, "/")
        List.last(uri_path)
    end
  end

  @doc """
  Method to extract an the Location header of a response

  ## Option Values

  The `response` option defines the FleetApi.Http.Response

  ## Return values

  String
  """ 
  @spec extract_location_header(term) :: String.t()
  def extract_location_header(response) do
    if response.headers == nil || length(response.headers) == 0 do
      ""
    else
      Enum.reduce response.headers, nil, fn({header, value}, location_header) ->
        if header != nil && String.downcase(header) == "location" do
          value
        else
          location_header
        end
      end
    end    
  end

  @doc false
  # Method to process an incoming httpc :ok response into a FleetApi.Http.Response
  #
  ## Options
  #
  # The `response` option represents the httpc response
  #
  ## Return Value
  #
  # FleetApi.Http.Response
  #
  @spec process_response({:ok, term}) :: term
  defp process_response({:ok, response}) do
    %__MODULE__{
      body: parse_body(response),
      success?: response[:status_code] in 200..299,
      status: response[:status_code],
      headers: process_headers(response[:headers]),
      raw_body: response[:body]
    }
  end

  @doc false
  # Method to process an incoming httpc :error response into a FleetApi.Http.Response
  #
  ## Options
  #
  # The `response` option represents the httpc response
  #
  ## Return Value
  #
  # FleetApi.Http.Response
  #
  @spec process_response({:error, term}) :: term
  defp process_response({:error, response}) do
    %__MODULE__{
      body: response[:reason],
      success?: false,
      status: 0,
      headers: process_headers(response[:headers]),
      raw_body: nil
    }    
  end

  @doc false
  # Method to parse out a JSON body for a FleetApi.Http.Response
  #
  ## Options
  #
  # The `response` option represents the httpc response
  #
  ## Return Value
  #
  # String
  #
  @spec parse_body(term) :: term
  defp parse_body(response) do
    try do
      response[:body]
        |> String.strip
        |> process_body
    rescue e in _ ->
      Logger.debug "[FleetApi.Http.Response] An error occurred processing response body:  #{inspect e}"
      nil
    end    
  end

  @doc false
  # Method to process the body from an incoming httpc response into JSON
  #
  ## Options
  #
  # The `body` option represents the httpc response
  #
  ## Return Value
  #
  # Object
  #
  @spec process_body(term) :: term
  defp process_body(body) when byte_size(body) == 0, do: %{}
  defp process_body(body), do: Poison.decode!(body)

  @doc false
  # Method to process the headers from an incoming httpc response into JSON
  #
  ## Options
  #
  # The `headers` option represents the httpc headers
  #
  ## Return Value
  #
  # List
  #
  @spec process_headers(term) :: List
  defp process_headers(headers) do
    if headers == nil || length(headers) == 0 do
      []
    else
      Enum.reduce headers, [], fn(header, new_headers) ->
        new_headers ++ [{"#{elem(header, 0)}", "#{elem(header, 1)}"}]
      end  
    end
  end
end
