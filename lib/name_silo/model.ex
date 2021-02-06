defmodule NameSilo.Model do
  @moduledoc false

  use TypedStruct

  typedstruct module: ApiError do
    field :code, integer, enforce: true
    field :detail, any
  end

  typedstruct module: RequestError do
    field :reason, any, enforce: true
  end
end
