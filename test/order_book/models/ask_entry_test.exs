defmodule OrderBook.Models.AskEntryTest do
  use ExUnit.Case, async: true
  alias OrderBook.Models.AskEntry

  doctest AskEntry

  setup do
    %{
      valid_entry: %{
        ask_price: 1.0,
        ask_quantity: 1
      },
      invalid_entry: %{
        ask_price: -1,
        ask_quantity: -1
      }
    }
  end

  describe "build/1" do
    test "checks all numbers to be positive", %{invalid_entry: invalid_entry} do
      assert {:error, changeset} = AskEntry.build(invalid_entry)
      %{errors: errors} = changeset
      assert [:ask_quantity, :ask_price] = Keyword.keys(errors)
    end

    test "builds entry from valid event", %{valid_entry: valid_entry} do
      assert {:ok, _} = AskEntry.build(valid_entry)
    end

    test "returns default build when missing values" do
      assert {:ok, _} = AskEntry.build(%{})
    end
  end
end
