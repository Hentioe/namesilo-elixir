defmodule NameSilo do
  @moduledoc """
  Documentation for `NameSilo`.
  """

  require NameSilo.DSL
  import NameSilo.DSL

  @doc """
  ## Examples

    Default usage
      iex> NameSilo.api_root() # Read the `sandbox` in the configuration by default.
      "https://sandbox.namesilo.com/api"

    Use options
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

  def_api("registerDomain", required: ["domain", "years"])
  def_api("listRegisteredNameServers", required: ["domain"])

  # TODO: 待上报。
  # 此 API 疑似有 BUG，无法将域名作为 ip 参数的值。
  # 相关错误："IPv6 is not properly formatted or not in a publicly routable address space"。
  def_api("addRegisteredNameServer", required: ["domain", "new_host", "ip1"])
  # TODO: 待上报，同 `addRegisteredNameServer` API。
  def_api("modifyRegisteredNameServer",
    required: ["domain", "current_host", "new_host", "ip1"]
  )

  def_api("deleteRegisteredNameServer", required: ["domain", "current_host"])
  def_api("dnsListRecords", required: ["domain"])
  def_api("dnsAddRecord", required: ["domain", "rrtype", "rrhost", "rrvalue"])
  def_api("dnsUpdateRecord", required: ["domain", "rrid", "rrhost", "rrvalue"])
  def_api("dnsDeleteRecord", required: ["domain", "rrid"])
  def_api("configureEmailForward", required: ["domain", "email", "forward1"])
  def_api("deleteEmailForward", required: ["domain", "email"])
  def_api("getAccountBalance")
end
