defmodule OrderBook.Types do
  @moduledoc """
    type definations for the OrderBook and order book level types
  """
  @type order_book :: %{ask: map(), bid: map()}
  @type order_book_level :: [
          %{
            ask_price: float() | nil,
            ask_quantity: number() | nil,
            bid_price: float() | nil,
            bid_quantity: number() | nil
          }
        ]
end
