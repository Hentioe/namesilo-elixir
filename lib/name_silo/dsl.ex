defmodule NameSilo.DSL do
  @moduledoc false

  @queries_arg_ast {:\\, [], [{:queries, [], Elixir}, {:%{}, [], []}]}

  defmacro def_api(name, options \\ []) when is_binary(name) do
    {args_ast, pa_mapping} =
      if required = Keyword.get(options, :required) do
        pa_mapping =
          required
          |> Enum.map(fn param_name ->
            arg_name = param_name |> Macro.underscore() |> String.to_atom()

            {param_name, arg_name}
          end)

        args_ast = pa_mapping |> Enum.map(fn {_, arg_name} -> {arg_name, [], Elixir} end)
        args_ast = args_ast ++ [@queries_arg_ast]

        {args_ast, pa_mapping}
      else
        {[@queries_arg_ast], []}
      end

    pa_mapping_ast =
      pa_mapping
      |> Enum.map(fn {param_name, arg_name} ->
        {param_name, {arg_name, [], Elixir}}
      end)

    fun_name = name |> Macro.underscore() |> String.to_atom()
    fun_sign_ast = {fun_name, [], args_ast}

    ast =
      quote do
        def unquote(fun_sign_ast) do
          queries =
            Map.merge(unquote({:queries, [], Elixir}), Enum.into(unquote(pa_mapping_ast), %{}))

          NameSilo.Request.call_api(unquote(name), queries)
        end
      end

    ast
  end
end
