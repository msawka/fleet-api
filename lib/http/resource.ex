#
# == resource.ex
#
# This module contains reusable methods for creating httpc requests to the openaperture_manager.
#
require Logger

defmodule FleetApi.Http.Resource do
	alias FleetApi.Http.Response

  @moduledoc """
  This module contains reusable methods for creating httpc requests to the openaperture_manager.
  """

  @doc """
  Method to execute a GET httpc request

  ## Option Values

  The `path` option represents the relative url path

  The `headers` option represents a KeyWord list of headers

  The `options` option represents a KeyWord list of HTTP options

  ## Return values

  FleetApi.Http.Response
  """ 
  @spec get(String.t(), List, List) :: Response.t
  def get(url, headers, options) do
    Logger.debug "[FleetApi.Http.Request] GET #{url}"

    execute_request(:get, {'#{url}', merge_headers(headers)}, merge_options(options))
      |> Response.from_httpc_response
  end

  @spec get(String.t) :: Response.t
  def get(url) do
    get(url, [], [])
  end

  @doc """
  Method to execute a POST httpc request

  ## Option Values

  The `path` option represents the relative url path

  The `object` option represents the payload of the post request

  The `headers` option represents a KeyWord list of headers

  The `options` option represents a KeyWord list of HTTP options

  ## Return values

  FleetApi.Http.Response
  """ 
  @spec post(String.t(), term, List, List) :: Response.t
  def post(url, object, headers, options) do
    Logger.debug "[FleetApi.Http.Request] Encoding POST body..."
    encoded_object = '#{object}'
    Logger.debug "[FleetApi.Http.Request] Executing POST #{url}"
    execute_request(:post, {'#{url}', merge_headers(headers), 'application/json', encoded_object}, merge_options(options))
      |> Response.from_httpc_response
  end

  @spec post(String.t, any) :: Response.t
  def post(path, body) do
    post(path, body, [], [])
  end

  @doc """
  Method to execute a PUT httpc request

  ## Option Values

  The `url` option represents the relative url path

  The `object` option represents the payload of the post request

  The `headers` option represents a KeyWord list of headers

  The `options` option represents a KeyWord list of HTTP options

  ## Return values

  FleetApi.Http.Response
  """ 
  @spec put(String.t(), term, List, List) :: Response.t
  def put(url, object, headers, options) do
    Logger.debug "[FleetApi.Http.Request] Encoding PUT body..."
    encoded_object = '#{object}'
    Logger.debug "[FleetApi.Http.Request] Executing PUT #{url}"

    execute_request(:put, {'#{url}', merge_headers(headers), 'application/json', encoded_object}, merge_options(options))
      |> Response.from_httpc_response
  end

  @spec put(String.t, any) :: Response.t
  def put(url, body) do
    put(url, body, [], [])
  end

  @doc """
  Method to execute a POST httpc request

  ## Option Values

  The `api` option defines the ManagerApi pid

  The `path` option represents the relative url path

  The `headers` option represents a KeyWord list of headers

  The `options` option represents a KeyWord list of HTTP options

  ## Return values

  FleetApi.Http.Response
  """ 
  @spec delete(String.t(), List, List) :: Response.t
  def delete(url, headers, options) do
    Logger.debug "[FleetApi.Http.Request] DELETE #{url}"
    execute_request(:delete, {'#{url}', merge_headers(headers)}, merge_options(options))
      |> Response.from_httpc_response
  end

  @spec delete(String.t) :: Response.t
  def delete(path) do
    delete(path, [], [])
  end

  @doc """
  Method to generate an relative path, including query params

  ## Option Values

  The `default_path` option represents the relative url

  The `query_params` option represents map of query param names to values

  ## Return values

  Absolute URL
  """ 
  @spec get_path(pid, Map) :: String.t()
  def get_path(default_path, query_params) do
    case build_query_string_from_params(query_params) do
      "" ->
        default_path
      querystring ->
        default_path <> querystring
    end
  end

  @spec get_path(String.t) :: String.t
  def get_path(default_path) do
    get_path(default_path, %{})
  end

  @doc """
  Method to generate a query param string

  ## Option Values

  The `query_params` option represents map of query param names to values

  ## Return values

  Query string
  """ 
  @spec build_query_string_from_params(Map) :: String.t()
  def build_query_string_from_params(query_params) do
    Enum.reduce(
      Map.keys(query_params),
      "",
      fn(key, acc) ->
        if String.length(acc) == 0 do
          acc = "?"
        else
          acc = acc <> "&"
        end
        acc <> "#{key}=#{query_params[key]}"
      end
    )
  end

  @doc false
  # Method to merge custom HTTP options
  #
  ## Options
  #
  # The `options` option represents the list of HTTP options
  #
  ## Return Value
  #
  # List
  #
  @spec merge_options(List) :: List
  defp merge_options(options) do
    options ++ []
  end

  # Method to load the default headers
  @spec default_headers() :: List
  defp default_headers() do
    []
  end

  # Method to merge custom headers
  @spec merge_headers(List) :: List
  defp merge_headers(headers) do
    if headers != nil && length(headers) > 0 do
      default_headers_map = Enum.reduce default_headers(), %{}, fn (header, default_headers_map) ->
        Map.put(default_headers_map, '#{elem(header, 0)}', '#{elem(header, 1)}')
      end

      new_headers_map = Enum.reduce headers, default_headers_map, fn(header, new_headers_map) ->
        Map.put(new_headers_map, '#{elem(header, 0)}', '#{elem(header, 1)}')
      end

      Map.to_list(new_headers_map)
    else
      default_headers()
    end
  end

  @doc false
  # Method to execute an httpc request
  #
  ## Options
  #
  # The `method` option represents an atom of the HTTP options
  #
  # The `request` option represents the httpc request
  #
  # The `http_options` option represents the HTTP options
  #
  ## Return Value
  #
  # httpc response tuple
  #
  @spec execute_request(term, term, List) :: term
  defp execute_request(method, request, http_options) do
    httpc_options = []
    :httpc.request(method, request, http_options, httpc_options)
  end  
end