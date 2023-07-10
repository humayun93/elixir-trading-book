defmodule OrderBook.OrderBookStore.UpdateOrderBookEntryTest do
  use ExUnit.Case, async: true

  alias OrderBook.OrderBookStore.UpdateOrderBookEntry
  alias OrderBook.Models.{Event, AskEntry, BidEntry}

  doctest UpdateOrderBookEntry

  @order_book %{
    ask: %{1 => %AskEntry{ask_price: 20.0, ask_quantity: 20}},
    bid: %{1 => %BidEntry{bid_price: 20.0, bid_quantity: 20}}
  }

  setup do
    %{
      event: %Event{
        side: :bid,
        instruction: :update,
        price_level_index: 1,
        price: 40.0,
        quantity: 40
      }
    }
  end

  test "update_level/2 replaces the entry at the given level of the book on bid side", %{
    event: event
  } do
    assert %{
             ask: %{1 => %AskEntry{ask_price: 20.0, ask_quantity: 20}},
             bid: %{1 => %BidEntry{bid_price: 40.0, bid_quantity: 40}}
           } = UpdateOrderBookEntry.update_level(event, @order_book)
  end

  test "update_level/2 replaces the entry at the given level of the book on ask side", %{
    event: event
  } do
    new_event = %{event | side: :ask}

    assert %{
             ask: %{1 => %AskEntry{ask_price: 40.0, ask_quantity: 40}},
             bid: %{1 => %BidEntry{bid_price: 20.0, bid_quantity: 20}}
           } = UpdateOrderBookEntry.update_level(new_event, @order_book)
  end

  test "update_level/2 raises an error when non existing level is given", %{
    event: event
  } do
    new_event = %{event | price_level_index: 10}

    assert {:error, :price_level_not_found} =
             UpdateOrderBookEntry.update_level(new_event, @order_book)
  end
end
