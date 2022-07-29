defmodule TypeInferer do
  def infer(ast), do: ast |> tag_ast() |> generate_constraints() |> unify()

  def tag_ast([:null, _v] = ast), do: tag_ast(ast, "lit_null")
  def tag_ast([:num, _v] = ast), do: tag_ast(ast, "lit_num")
  def tag_ast([:str, _v] = ast), do: tag_ast(ast, "lit_str")
  def tag_ast([:bool, _v] = ast), do: tag_ast(ast, "lit_bool")
  def tag_ast([:id, _v] = ast), do: tag_ast(ast, "var_ref")
  def tag_ast([:let, binding, expr_ast] = _ast), do: [:let, binding, tag_ast(expr_ast), "var_def"]
  def tag_ast([monop, v] = _ast), do: tag_ast([monop, tag_ast(v)], "mon_op")
  def tag_ast([binop, lv, rv] = _ast), do: tag_ast([binop, tag_ast(lv), tag_ast(rv)], "bin_op")
  def tag_ast(ast, kind), do: {ast, "#{kind}_#{serial_number()}"}

  def generate_constraints({[:null, _], _} = ast), do: [eq_constraint(:c_lit, ast, :t_null)]
  def generate_constraints({[:num, _], _} = ast), do: [eq_constraint(:c_lit, ast, :t_num)]
  def generate_constraints({[:str, _], _} = ast), do: [eq_constraint(:c_lit, ast, :t_str)]
  def generate_constraints({[:bool, _], _} = ast), do: [eq_constraint(:c_lit, ast, :t_bool)]

  def generate_constraints({[:-, v_ast], _} = ast) do
    generate_constraints(v_ast) ++
      [
        eq_constraint(:c_op_arg, v_ast, :t_num),
        eq_constraint(:c_op_res, ast, :t_num)
      ]
  end

  def generate_constraints({[:!, v_ast], _} = ast) do
    generate_constraints(v_ast) ++
      [
        eq_constraint(:c_op_arg, v_ast, :t_bool),
        eq_constraint(:c_op_res, ast, :t_bool)
      ]
  end

  def generate_constraints({[math_binop, lv_ast, rv_ast], _} = ast)
      when math_binop in [:+, :-, :*, :/] do
    generate_constraints(lv_ast) ++
      generate_constraints(rv_ast) ++
      [
        eq_constraint(:c_op_arg, lv_ast, :t_num),
        eq_constraint(:c_op_arg, rv_ast, :t_num),
        eq_constraint(:c_op_res, ast, :t_num)
      ]
  end

  def unify_one(constraint, [substitution | substitutions]) do
    {_, _, constraint_ast, constraint_type} = constraint
    {_, _, substitution_ast, substitution_type} = substitution

    cond do
      constraint_ast == substitution_ast and constraint_type != substitution_type ->
        raise "type error"

      constraint_ast == substitution_ast ->
        unify_one(constraint, substitutions)

      true ->
        [substitution | unify_one(constraint, substitutions)]
    end
  end

  def unify_one(constraint, []), do: [constraint]

  def unify(_constraints, _substitutions \\ [])

  def unify([constraint | constraints], substitutions) do
    unify(constraints, unify_one(constraint, substitutions))
  end

  def unify([], substitutions), do: substitutions

  defp eq_constraint(constraint, ast, expected_type),
    do: {:eq_constraint, constraint, ast, expected_type}

  defp serial_number(), do: System.unique_integer([:positive, :monotonic])
end
