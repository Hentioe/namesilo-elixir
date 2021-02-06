defmodule NameSilo.RequestTest do
  use ExUnit.Case
  doctest NameSilo.Request, import: true

  import Kernel, except: [send: 2]
  import NameSilo.Request

  test "send/3" do
    endpoint =
      "#{NameSilo.api_root(sandbox: false)}/getAccountBalance?version=1&type=xml&key=12345"

    {:ok, resp} = send(endpoint, :get)
    assert resp.body == "Invalid Request: invalid key"

    assert key = Application.get_env(:name_silo, :api_key)

    endpoint =
      "#{NameSilo.api_root()}/registerDomain?version=1&type=xml&key=#{key}&domain=elixir-namesilo.com&years=2&private=1&auto_renew=1"

    {:ok, resp} = send(endpoint, :get)

    assert resp.status_code == 200
  end

  test "call_api/2" do
    {:ok, %{balance: balance, code: code}} = call_api("getAccountBalance")

    assert code == 300
    assert String.to_float(balance) >= 0

    {:error, _} = call_api("getAccountBalance", %{"key" => "12345"})

    {:ok, _} =
      call_api("getAccountBalance", %{"key" => Application.get_env(:name_silo, :api_key)})

    {:error, %{code: 103, detail: "Invalid API version"}} =
      call_api("getAccountBalance", %{"version" => "2"})

    {:error, %{code: 105, detail: "Invalid API type"}} =
      call_api("getAccountBalance", %{"type" => "json"})
  end
end
