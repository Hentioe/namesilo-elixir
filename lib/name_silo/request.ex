defmodule NameSilo.Request do
  @moduledoc false

  require Logger

  import Kernel, except: [send: 2]

  @type method :: :get | :post | :put | :delete
  @type httpoison_returns :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}

  alias NameSilo.Model.{ApiError, RequestError}

  def call_api(operation, queries \\ %{}) do
    query_str = queries |> rebuild_queries() |> URI.encode_query()

    endpoint = NameSilo.api_root(suffix: true) <> operation <> "?#{query_str}"

    endpoint |> send(:get) |> parse_response()
  end

  @doc """
    ## Examples

        iex> rebuild_queries(%{"key" => "12345"})
        %{"key" => "12345", "version" => "1", "type" => "xml"}
  """
  def rebuild_queries(queries) do
    rebuild_one = fn queries, {key, default} ->
      if queries[key] == nil,
        do: Map.put(queries, key, default),
        else: queries
    end

    queries =
      queries
      |> rebuild_one.({"key", Application.get_env(:name_silo, :api_key)})
      |> rebuild_one.({"version", "1"})
      |> rebuild_one.({"type", "xml"})

    queries
  end

  @spec send(binary, method, map) :: httpoison_returns
  def send(url, method, _data \\ %{}) do
    apply(HTTPoison, method, [url, []])
  end

  @spec parse_response(httpoison_returns) ::
          {:ok, any} | {:error, ApiError.t() | RequestError.t()}
  defp parse_response({:ok, resp}) when is_struct(resp, HTTPoison.Response) do
    try do
      %{code: code, detail: detail} = reply = parse_reply!(resp.body)

      if Enum.member?([300, 301, 302], reply[:code]) do
        {:ok, reply}
      else
        {:error, %ApiError{code: code, detail: detail}}
      end
    catch
      {:error, 'Malformed: Illegal character in prolog'} ->
        detail = "Illegal character in prolog, body: \"#{resp.body}\""
        Logger.error(detail)

        {:error, %ApiError{code: -1, detail: detail}}
    end
  end

  defp parse_response({:error, error}) when is_struct(error, HTTPoison.Error) do
    {:error, %RequestError{reason: error.reason}}
  end

  @doc """
  ## Examples

      iex> parse_reply!(~S'<?xml version="1.0"?><namesilo><request><operation>registerDomain</operation><ip>0.0.0.0</ip></request><reply><code>262</code><detail>This domain is already active within our system and therefore cannot be processed.</detail></reply></namesilo>')
      %{code: 262, detail: "This domain is already active within our system and therefore cannot be processed."}
  """
  def parse_reply!(xml_text) do
    %{"namesilo" => %{"reply" => reply = %{"code" => code}}} = XmlToMap.naive_map(xml_text)

    reply |> Map.put("code", String.to_integer(code)) |> AtomicMap.convert()
  end
end
