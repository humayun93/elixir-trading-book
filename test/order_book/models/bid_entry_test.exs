defmodule OrderBook.Models.BidEntryTest do
  use ExUnit.Case, async: true
  alias OrderBook.Models.BidEntry

  doctest BidEntry

  setup do
    %{
      valid_entry: %{
        bid_price: 1.0,
        bid_quantity: 1
      },
      invalid_entry: %{
        bid_price: -1,
        bid_quantity: -1
      }
    }
  end

  describe "build/1" do
    test "checks all numbers to be positive", %{invalid_entry: invalid_entry} do
      assert {:error, changeset} = BidEntry.build(invalid_entry)
      %{errors: errors} = changeset
      assert [:bid_quantity, :bid_price] = Keyword.keys(errors)
    end

    test "builds entry from valid event", %{valid_entry: valid_entry} do
      assert {:ok, _} = BidEntry.build(valid_entry)
    end

    test "returns default build when missing values" do
      assert {:ok, _} = BidEntry.build(%{})
    end
  end
end
