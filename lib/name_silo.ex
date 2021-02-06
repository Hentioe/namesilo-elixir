defmodule NameSilo do
  @moduledoc """
  Documentation for `NameSilo`.
  """

  @doc """
  ## Examples

    ### Default usage
      iex> NameSilo.api_root() # Read the `sandbox` in the configuration by default.
      "https://sandbox.namesilo.com/api"

    ### Use options
      iex> NameSilo.api_root(sandbox: false, suffix: true)
      "https://www.namesilo.com/api/"

  """
  def api_root(options \\ []) do
    sandbox =
      if sandbox = Keyword.get(options, :sandbox) == nil do
        Application.get_env(:name_silo, :sandbox)
      else
        sandbox
      end

    suffix = Keyword.get(options, :suffix)

    root =
      if sandbox == true do
        "https://sandbox.namesilo.com"
      else
        "https://www.namesilo.com"
      end

    path = "/api"
    path = if suffix, do: path <> "/", else: path

    root <> path
  end
end
