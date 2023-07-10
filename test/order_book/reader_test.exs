defmodule OrderBook.ReaderTest do
  use ExUnit.Case, async: true

  alias OrderBook.Reader
  alias OrderBook.Models.{AskEntry, BidEntry}

  doctest Reader

  @order_book %{ask: %{1 => %AskEntry{ask_price: 20, ask_quantity: 40}}, bid: %{}}

  test "read/2 gives valid output on given depth" do
    assert [
             %{ask_price: 20, ask_quantity: 40, bid_price: 0, bid_quantity: 0},
             %{ask_price: 0, ask_quantity: 0, bid_price: 0, bid_quantity: 0}
           ] = Reader.read(@order_book, 2)
  end

  test "read/2 gives valid output when ask and bid levels are different" do
    updated_order_book = %{@order_book | bid: %{2 => %BidEntry{bid_price: 20, bid_quantity: 40}}}

    assert [
             %{ask_price: 20, ask_quantity: 40, bid_price: 0, bid_quantity: 0},
             %{ask_price: 0, ask_quantity: 0, bid_price: 20, bid_quantity: 40}
           ] = Reader.read(updated_order_book, 2)
  end
end
