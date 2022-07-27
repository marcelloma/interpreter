defmodule InterpreterTest do
  use ExUnit.Case

  import Interpreter

  test "" do
    assert 1 = eval([:num, 1], [])
    assert "Test" = eval([:str, "Test"], [])
    assert true = eval([:bool, true], [])
    assert is_nil(eval([:null], []))
    assert 3 = eval([:+, [:num, 1], [:num, 2]], [])
    assert 5 = eval([:+, [:+, [:num, 1], [:num, 2]], [:num, 2]], [])

    body = [:let, [:str, "a"], [:num, 1], [:+, [:id, [:str, "a"]], [:num, 2]]]
    assert 3 = eval(body, [])

    a2_body = [:+, [:id, [:str, "a"]], [:num, 1]]
    a1_body = [:let, [:str, "a"], [:num, 1], a2_body]
    assert 2 = eval([:let, [:str, "a"], [:bool, false], a1_body], [])

    assert 2 = eval([:+, [:if, [:bool, true], [:num, 1], [:num, 2]], [:num, 1]], [])
    assert 3 = eval([:+, [:if, [:bool, false], [:num, 1], [:num, 2]], [:num, 1]], [])
  end
end
