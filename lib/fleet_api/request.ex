defmodule FleetApi.Request do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      require Logger

      alias FleetApi.Http.Resource, as: HttpResource
      alias FleetApi.Http.Response, as: HttpResponse


      # Issue a request to the specified url, optionally passing a list of header
      # tuples and a body. The method argument specifies the HTTP method in the
      # form of an atom, e.g. :get, :post, :delete, etc.
      @spec request(atom, String.t, [tuple], String.t, [integer], boolean) :: {:ok, any} | {:error, any}
      defp request(method, url, headers \\ [], body \\ "", expected_status \\ [200], parse_response \\ true) do
        options = case Application.get_env(:fleet_api, :proxy) do
          nil -> []
          proxy_opts -> [hackney: [proxy: proxy_opts]]
        end

        request_id = UUID.uuid1()
                     |> String.slice(0..7)

        Logger.debug "[FleetApi] issuing a #{inspect method} request #{request_id} to #{url}"
        response = case method do
          :get -> HttpResource.get(url, headers, options)
          :post -> HttpResource.post(url, body, headers, options)
          :put -> HttpResource.put(url, body, headers, options)
          :delete -> HttpResource.delete(url, headers, options)
          _ ->     
            %HttpResponse{
              body: nil,
              success?: false,
              status: -1,
              headers: [],
              raw_body: nil
            }
        end

        if response != nil && response.success? do
          if response.status in expected_status do
            Logger.debug "[FleetApi] request to #{url} succeeded with status code #{inspect response.status}"
            if response.body != nil && parse_response do
              {:ok, response.body}
            else
              {:ok, response}
            end
          else
            Logger.error "[FleetApi] request #{request_id} to #{url} returned status code #{inspect response.status}"
            {:error, %{reason: "Expected response status in #{inspect expected_status} but got #{response.status}."}}
          end
        else
          Logger.error "[FleetApi] request #{request_id} issuing a #{inspect method} to #{url} returned status code #{inspect response.status}"

          if response.body != nil && response.raw_body != nil && String.length(response.raw_body) > 0 do
            error = response.body
                    |> FleetApi.Error.from_map
            {:error, %{reason: error}}
          else
            {:error, %{reason: "Received #{response.status} response."}}
          end          
        end        
      end
    end
  end
end