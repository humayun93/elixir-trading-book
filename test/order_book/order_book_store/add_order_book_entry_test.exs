defmodule OrderBook.OrderBookStore.AddOrderBookEntryTest do
  use ExUnit.Case, async: true

  alias OrderBook.OrderBookStore.AddOrderBookEntry
  alias OrderBook.Models.{Event, BidEntry}

  doctest AddOrderBookEntry

  @order_book %{ask: %{}, bid: %{}}

  setup do
    %{
      event: %Event{
        side: :bid,
        instruction: :new,
        price_level_index: 1,
        price: 20.0,
        quantity: 20
      }
    }
  end

  test "new_level/2 adds new book entry to the order book", %{
    event: event
  } do
    assert %{ask: %{}, bid: %{1 => %BidEntry{bid_price: 20.0, bid_quantity: 20}}} =
             AddOrderBookEntry.new_level(event, @order_book)
  end

  test "new_level/2 shifts up the order book entry when conflicted level is added", %{
    event: event
  } do
    bids = %{
      1 => %BidEntry{bid_price: 30.0, bid_quantity: 30},
      3 => %BidEntry{bid_price: 40.0, bid_quantity: 40}
    }

    new_order_book = %{@order_book | bid: bids}

    assert %{
             ask: %{},
             bid: %{
               1 => %BidEntry{bid_price: 20.0, bid_quantity: 20},
               3 => %BidEntry{bid_price: 40.0, bid_quantity: 40},
               2 => %BidEntry{bid_price: 30.0, bid_quantity: 30}
             }
           } = AddOrderBookEntry.new_level(event, new_order_book)
  end
end
