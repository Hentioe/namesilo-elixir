defmodule NameSilo.Config do
  @moduledoc false

  @spec timeout :: integer | nil
  def timeout, do: get(:timeout)

  @spec recv_timeout :: integer | nil
  def recv_timeout, do: get(:recv_timeout)

  @spec get(atom(), any()) :: any()
  defp get(key, default \\ nil) do
    Application.get_env(:name_silo, key, default)
  end
end
