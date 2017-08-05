defmodule JsonLogicTest do
  use ExUnit.Case
  doctest JsonLogic

  test "apply" do
    assert JsonLogic.apply(nil) == nil
    assert JsonLogic.apply(%{}) == %{}
  end

  describe "var" do
    test "returns from array inside hash" do
      assert JsonLogic.apply(%{"var" => "key.1"}, %{"key" => %{"1" => "a"}}) == "a"
      assert JsonLogic.apply(%{"var" => "key.1"}, %{"key" => ~w{a b}}) == "b"
    end
  end

  describe "==" do
    test "nested true" do
      assert JsonLogic.apply(%{"==" => [true, %{"==" => [1, 1]}]})
    end

    test "nested false" do
      assert JsonLogic.apply(%{"==" => [false, %{"==" => [0, 1]}]})
    end
  end

  describe "!=" do
    test "nested true" do
      assert JsonLogic.apply(%{"!=" => [false, %{"!=" => [0, 1]}]})
    end

    test "nested false" do
      assert JsonLogic.apply(%{"!=" => [true, %{"!=" => [1, 1]}]})
    end
  end

  describe "===" do
    test "nested true" do
      assert JsonLogic.apply(%{"===" => [true, %{"===" => [1, 1]}]})
    end

    test "nested false" do
      assert JsonLogic.apply(%{"===" => [false, %{"===" => [1, 1.0]}]})
    end
  end

  describe "!==" do
    test "nested true" do
      assert JsonLogic.apply(%{"!==" => [false, %{"!==" => [1, 1.0]}]})
    end

    test "nested false" do
      assert JsonLogic.apply(%{"!==" => [true, %{"!==" => [1, 1]}]})
    end
  end

  describe "!" do
    test "returns true with [false]" do
      assert JsonLogic.apply(%{"!" => [false]}) == true
    end

    test "returns false with [true]" do
      assert JsonLogic.apply(%{"!" => [true]}) == false
    end

    test "returns true with [false] from data" do
      assert JsonLogic.apply(%{"!" => [%{"var" => "key"}]}, %{"key" => false}) == true
    end
  end

  describe "if" do
    test "returns var when true" do
      assert JsonLogic.apply(%{"if" => [true, %{"var" => "key"}, "unexpected" ]}, %{"key" => "yes"}) == "yes"
    end

    test "returns var when false" do
      assert JsonLogic.apply(%{"if" => [false, "unexpected", %{"var" => "key"} ]}, %{"key" => "no"}) == "no"
    end

    test "returns var with multiple branches" do
      assert JsonLogic.apply(%{"if" => [false, "unexpected", false, "unexpected", %{"var" => "key"} ]}, %{"key" => "default"}) == "default"
    end
  end
end
