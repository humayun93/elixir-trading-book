defmodule OrderBook.OrderBookStore.DeleteOrderBookEntryTest do
  use ExUnit.Case, async: true

  alias OrderBook.OrderBookStore.DeleteOrderBookEntry
  alias OrderBook.Models.{Event, BidEntry}

  doctest DeleteOrderBookEntry

  @order_book %{ask: %{}, bid: %{1 => %BidEntry{bid_price: 20.0, bid_quantity: 20}}}

  setup do
    %{
      event: %Event{
        side: :bid,
        instruction: :delete,
        price_level_index: 1,
        price: 20.0,
        quantity: 20
      }
    }
  end

  test "delete_level/2 deletes the given level from the list", %{
    event: event
  } do
    assert %{ask: %{}, bid: %{}} = DeleteOrderBookEntry.delete_level(event, @order_book)
  end

  test "delete_level/2 shifts down the order book entry when an entry is deleted", %{
    event: event
  } do
    bids = %{
      1 => %BidEntry{bid_price: 20.0, bid_quantity: 20},
      2 => %BidEntry{bid_price: 30.0, bid_quantity: 30},
      3 => %BidEntry{bid_price: 40.0, bid_quantity: 40}
    }

    new_order_book = %{@order_book | bid: bids}

    assert %{
             ask: %{},
             bid: %{
               1 => %BidEntry{bid_price: 30.0, bid_quantity: 30},
               2 => %BidEntry{bid_price: 40.0, bid_quantity: 40}
             }
           } = DeleteOrderBookEntry.delete_level(event, new_order_book)
  end
end
