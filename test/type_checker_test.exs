defmodule TypeCheckerTest do
  use ExUnit.Case

  import TypeChecker

  test "" do
    assert :num = type_of([:num, 1], [])
    assert :str = type_of([:str, "Test"], [])
    assert :bool = type_of([:bool, true], [])
    assert :null = type_of([:null], [])
    assert :num = type_of([:+, [:num, 1], [:num, 2]], [])
    assert :num = type_of([:+, [:+, [:num, 1], [:num, 2]], [:num, 2]], [])

    assert :num =
             type_of(
               [:let, [:str, "a"], [:num, 1], [:+, [:id, [:str, "a"]], [:num, 2]]],
               []
             )

    a2_body = [:+, [:id, [:str, "a"]], [:num, 1]]
    a1_body = [:let, [:str, "a"], [:num, 1], a2_body]
    assert :num = type_of([:let, [:str, "a"], [:bool, 1], a1_body], [])

    assert_raise RuntimeError, "expected num got bool", fn ->
      type_of(
        [:let, [:str, "a"], [:bool, true], [:+, [:id, [:str, "a"]], [:num, 2]]],
        []
      )
    end

    assert_raise RuntimeError, "expected num got bool", fn ->
      type_of([:+, [:bool, 1], [:num, 2]], [])
    end

    assert_raise RuntimeError, "expected num got bool", fn ->
      type_of([:+, [:!, [:bool, true]], [:num, 2]], [])
    end

    assert :num = type_of([:+, [:if, [:bool, true], [:num, 1], [:num, 2]], [:num, 1]], [])

    assert_raise RuntimeError, "expected num got bool", fn ->
      type_of([:+, [:if, [:bool, true], [:bool, false], [:num, 2]], [:num, 1]], [])
    end

    assert_raise RuntimeError, "expected num got bool", fn ->
      type_of([:+, [:if, [:bool, true], [:num, 2], [:bool, false]], [:num, 1]], [])
    end
  end
end
