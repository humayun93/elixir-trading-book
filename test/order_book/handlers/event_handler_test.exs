defmodule OrderBook.Handlers.EventHandlerTest do
  use ExUnit.Case, async: true

  alias OrderBook.Handlers.EventHandler
  alias OrderBook.Models.{AskEntry, BidEntry, Event}

  doctest EventHandler

  @order_book %{ask: %{}, bid: %{}}
  @filled_order_book %{
    ask: %{1 => %AskEntry{ask_price: 40.0, ask_quantity: 4}},
    bid: %{1 => %BidEntry{bid_price: 40.0, bid_quantity: 4}}
  }

  setup do
    %{
      new_event: %Event{
        instruction: :new,
        side: :ask,
        price_level_index: 1,
        price: 40.0,
        quantity: 4
      },
      update_event: %Event{
        instruction: :update,
        side: :ask,
        price_level_index: 1,
        price: 20.0,
        quantity: 2
      },
      delete_event: %Event{
        instruction: :delete,
        side: :ask,
        price_level_index: 1
      }
    }
  end

  describe "new" do
    test "handle/2 with ask event updates the ask side of the order book", %{new_event: new_event} do
      assert %{
               bid: %{},
               ask: %{1 => %AskEntry{ask_price: 40.0, ask_quantity: 4}}
             } = EventHandler.handle(new_event, @order_book)
    end

    test "handle/2 with bid event updates the bid side of the order book", %{new_event: new_event} do
      bid_event = %{new_event | side: :bid}

      assert %{
               bid: %{1 => %BidEntry{bid_price: 40.0, bid_quantity: 4}},
               ask: %{}
             } = EventHandler.handle(bid_event, @order_book)
    end

    test "handle/2 increases the level of the book by shifting the conflicting entry at new level",
         %{
           new_event: new_event
         } do
      new_price_level = %{new_event | price_level_index: 2, price: 80.0}

      assert %{
               bid: _,
               ask: %{
                 1 => %AskEntry{ask_price: 40.0, ask_quantity: 4},
                 2 => %AskEntry{ask_price: 80.0, ask_quantity: 4}
               }
             } = EventHandler.handle(new_price_level, @filled_order_book)
    end

    test "handle/2 increases the level of the book by adding the entry at middle price level ", %{
      new_event: new_event
    } do
      new_price_level = %{new_event | price_level_index: 2, price: 80.0}
      updated_book = EventHandler.handle(new_event, @filled_order_book)

      assert %{
               bid: _,
               ask: %{
                 1 => %AskEntry{ask_price: 40.0, ask_quantity: 4},
                 2 => %AskEntry{ask_price: 80.0, ask_quantity: 4},
                 3 => %AskEntry{ask_price: 40.0, ask_quantity: 4}
               }
             } = EventHandler.handle(new_price_level, updated_book)
    end
  end

  describe "update" do
    test "handle/2 with ask", %{update_event: update_event} do
      assert %{
               bid: _,
               ask: %{1 => %AskEntry{ask_price: 20.0, ask_quantity: 2}}
             } = EventHandler.handle(update_event, @filled_order_book)
    end

    test "handle/2 with bid", %{update_event: update_event} do
      bid_event = %{update_event | side: :bid}

      assert %{
               bid: %{1 => %BidEntry{bid_price: 20.0, bid_quantity: 2}},
               ask: _
             } = EventHandler.handle(bid_event, @filled_order_book)
    end
  end

  describe "delete" do
    test "handle/2 with ask event delete the entry from ask side of the order book", %{
      delete_event: delete_event
    } do
      assert %{
               bid: _,
               ask: %{}
             } = EventHandler.handle(delete_event, @filled_order_book)
    end

    test "handle/2 with bid event updates the bid side of the order book", %{
      delete_event: delete_event
    } do
      updated_book = %{
        @filled_order_book
        | ask: %{
            1 => %AskEntry{ask_price: 40.0, ask_quantity: 4},
            2 => %AskEntry{ask_price: 80.0, ask_quantity: 4}
          }
      }

      assert %{
               bid: %{1 => %BidEntry{bid_price: 40.0, bid_quantity: 4}},
               ask: %{1 => %AskEntry{ask_price: 80.0, ask_quantity: 4}}
             } = EventHandler.handle(delete_event, updated_book)
    end
  end
end
