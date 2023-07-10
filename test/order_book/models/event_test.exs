defmodule OrderBook.Models.EventTest do
  use ExUnit.Case, async: true
  alias OrderBook.Models.Event

  doctest Event

  setup do
    %{
      valid_event: %{
        instruction: :new,
        side: :ask,
        price_level_index: 1,
        price: 80.0,
        quantity: 3
      },
      delete_event: %{
        instruction: :delete,
        side: :ask,
        price_level_index: 1
      }
    }
  end

  describe "build/1" do
    test "invalid event with invalid instruciton", %{valid_event: valid_event} do
      attrs = %{valid_event | instruction: :invalid}

      assert {:error, _} = Event.build(attrs)
    end

    test "checks all required fields" do
      assert {:error, changeset} = Event.build(%{})
      %{errors: errors} = changeset
      assert [:instruction, :side, :price_level_index, :price, :quantity] = Keyword.keys(errors)
    end

    test "checks all numbers to be positive", %{valid_event: valid_event} do
      attrs = %{valid_event | price_level_index: 0, price: -10, quantity: -1}
      assert {:error, changeset} = Event.build(attrs)
      %{errors: errors} = changeset
      assert [:quantity, :price, :price_level_index] = Keyword.keys(errors)
    end

    test "checks requried fields for delete event", %{delete_event: delete_event} do
      attrs = %{delete_event | side: :invalid, price_level_index: nil}

      assert {:error, changeset} = Event.build(attrs)
      %{errors: errors} = changeset
      assert [:price_level_index, :side] = Keyword.keys(errors)
    end

    test "builds event from valid event", %{valid_event: valid_event} do
      assert {:ok, _} = Event.build(valid_event)
    end

    test "builds event from valid delete_event", %{delete_event: delete_event} do
      assert {:ok, _} = Event.build(delete_event)
    end
  end
end
