defmodule TypeChecker do
  @null :null
  @str :str
  @num :num
  @bool :bool

  def type_of([:null], _t_env), do: @null

  def type_of([:str, _x], _t_env), do: @str

  def type_of([:num, _x], _t_env), do: @num

  def type_of([:bool, _x], _t_env), do: @bool

  def type_of([:-, x], t_env), do: ensure_type_of(@num, x, t_env)

  def type_of([:!, x], t_env), do: ensure_type_of(@bool, x, t_env)

  def type_of([:+, x, y], t_env), do: Enum.map([x, y], &ensure_type_of(@num, &1, t_env)) |> hd()

  def type_of([:-, x, y], t_env), do: Enum.map([x, y], &ensure_type_of(@num, &1, t_env)) |> hd()

  def type_of([:*, x, y], t_env), do: Enum.map([x, y], &ensure_type_of(@num, &1, t_env)) |> hd()

  def type_of([:/, x, y], t_env), do: Enum.map([x, y], &ensure_type_of(@num, &1, t_env)) |> hd()

  def type_of([:print, x], t_env), do: ensure_type_of(@str, x, t_env)

  def type_of([:id, [:str, x]], t_env), do: TypeEnv.type_of(x, t_env)

  def type_of([:id, x], _t_env), do: raise("#{x} is not a valid identifier")

  def type_of([:let, [:str, x], y, z], t_env) do
    let_type = type_of(y, t_env)
    nested_t_env = TypeEnv.set_type_of(x, let_type, t_env)
    type_of(z, nested_t_env)
  end

  def type_of([:let, x, _y, _z], _t_env), do: raise("#{x} is not a valid identifier")

  def type_of([:if, x, y, z], t_env) do
    ensure_type_of(@bool, x, t_env)
    [type_of(y, t_env), type_of(z, t_env)]
  end

  def ensure_type_of(expected_type, ast, t_env) do
    case type_of(ast, t_env) do
      actual_types when is_list(actual_types) ->
        actual_types
        |> Enum.each(&if(&1 != expected_type, do: raise("expected #{expected_type} got #{&1}")))

        hd(actual_types)

      actual_type ->
        if expected_type != actual_type, do: raise("expected #{expected_type} got #{actual_type}")
        actual_type
    end
  end
end
