#
# == error.ex
#
# This module contains the standard error definition for FleetApi.Http
#
defmodule FleetApi.Http.Error do
  @moduledoc """
  This module contains the standard error definition for FleetApi.Http
  """  

  defstruct stacktrace: nil, kind: nil, error: nil

  @doc """
  Method to generate a standardized error

  ## Options
  The `kind` option defines the error type

  The `error` option defines the actual error

  ## Return Values

  FleetApi.Http.Error
  """
  @spec process(term, term) :: term
  def process(kind, error) do
    %__MODULE__{
      stacktrace: Exception.format(kind, error),
      kind: kind,
      error: error
    }
  end
end
