defmodule TypeCheckerTest do
  use ExUnit.Case

  test "" do
    assert :num = TypeChecker.type_of([:num, 1], [])
    assert :str = TypeChecker.type_of([:str, "Test"], [])
    assert :bool = TypeChecker.type_of([:bool, true], [])
    assert :null = TypeChecker.type_of([:null], [])
    assert :num = TypeChecker.type_of([:+, [:num, 1], [:num, 2]], [])
    assert :num = TypeChecker.type_of([:+, [:+, [:num, 1], [:num, 2]], [:num, 2]], [])

    assert :num =
             TypeChecker.type_of(
               [:let, [:str, "a"], [:num, 1], [:+, [:id, [:str, "a"]], [:num, 2]]],
               []
             )

    a2_body = [:+, [:id, [:str, "a"]], [:num, 1]]
    a1_body = [:let, [:str, "a"], [:num, 1], a2_body]
    assert :num = TypeChecker.type_of([:let, [:str, "a"], [:bool, 1], a1_body], [])

    assert_raise RuntimeError, "expected num got bool", fn ->
      TypeChecker.type_of(
        [:let, [:str, "a"], [:bool, true], [:+, [:id, [:str, "a"]], [:num, 2]]],
        []
      )
    end

    assert_raise RuntimeError, "expected num got bool", fn ->
      TypeChecker.type_of([:+, [:bool, 1], [:num, 2]], [])
    end

    assert_raise RuntimeError, "expected num got bool", fn ->
      TypeChecker.type_of([:+, [:!, [:bool, true]], [:num, 2]], [])
    end
  end
end
