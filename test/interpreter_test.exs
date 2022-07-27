defmodule InterpreterTest do
  use ExUnit.Case

  test "" do
    assert 1 = Interpreter.eval([:num, 1], [])
    assert "Test" = Interpreter.eval([:str, "Test"], [])
    assert true = Interpreter.eval([:bool, true], [])
    assert is_nil(Interpreter.eval([:null], []))
    assert 3 = Interpreter.eval([:+, [:num, 1], [:num, 2]], [])
    assert 5 = Interpreter.eval([:+, [:+, [:num, 1], [:num, 2]], [:num, 2]], [])

    body = [:let, [:str, "a"], [:num, 1], [:+, [:id, [:str, "a"]], [:num, 2]]]
    assert 3 = Interpreter.eval(body, [])

    a2_body = [:+, [:id, [:str, "a"]], [:num, 1]]
    a1_body = [:let, [:str, "a"], [:num, 1], a2_body]
    assert 2 = Interpreter.eval([:let, [:str, "a"], [:bool, false], a1_body], [])
  end
end
