defmodule TypeInfererTest do
  use ExUnit.Case

  import TypeInferer

  test "" do
    assert [{:eq_constraint, :c_lit, {[:num, 1], "lit_num_" <> _}, :t_num}] = infer([:num, 1])

    assert [
             {:eq_constraint, :c_op_arg, {[:num, 1], "lit_num_" <> _}, :t_num},
             {:eq_constraint, :c_op_arg, {[:num, 2], "lit_num_" <> _}, :t_num},
             {:eq_constraint, :c_op_res,
              {[:+, {[:num, 1], "lit_num_" <> _}, {[:num, 2], "lit_num_" <> _}], "bin_op_" <> _},
              :t_num}
           ] = infer([:+, [:num, 1], [:num, 2]])

    assert_raise RuntimeError, fn ->
      infer([:+, [:bool, false], [:num, 2]])
    end
  end
end
