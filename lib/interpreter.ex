defmodule Interpreter do
  def eval([:null], _env), do: nil

  def eval([:str, x], _env), do: x

  def eval([:num, x], _env), do: x

  def eval([:bool, x], _env), do: x

  def eval([:-, x], env), do: -eval(x, env)

  def eval([:!, x], env), do: !eval(x, env)

  def eval([:+, x, y], env), do: eval(x, env) + eval(y, env)

  def eval([:-, x, y], env), do: eval(x, env) - eval(y, env)

  def eval([:*, x, y], env), do: eval(x, env) * eval(y, env)

  def eval([:/, x, y], env), do: eval(x, env) / eval(y, env)

  def eval([:print, x], env), do: IO.puts(eval(x, env))

  def eval([:let, [:str, x], y, z], env) do
    value = eval(y, env)
    nested_env = Env.set_value_of(x, value, env)
    eval(z, nested_env)
  end

  def eval([:id, [:str, x]], env), do: Env.value_of(x, env)

  def eval([:if, x, y, z], env) do
    if eval(x, env),
      do: eval(y, env),
      else: eval(z, env)
  end
end
