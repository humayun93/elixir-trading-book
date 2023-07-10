defmodule OrderBook.OrderBookStore.UpdateOrderBookEntry do
  @moduledoc """
  Replaces the entry from the Orderbook

  ## Examples

    iex> UpdateOrderBookEntry.update_level(
    ...>   %OrderBook.Models.Event{
    ...>     instruction: :update,
    ...>     side: :bid,
    ...>     price_level_index: 1,
    ...>     price: 20.0,
    ...>     quantity: 30
    ...>   },
    ...>   %{ask: %{}, bid: %{1 => %OrderBook.Models.BidEntry{bid_price: 10.0, bid_quantity: 20}}}
    ...> )
    %{ask: %{}, bid: %{1 => %OrderBook.Models.BidEntry{bid_price: 20.0, bid_quantity: 30}}}
  """

  alias OrderBook.Types
  alias OrderBook.Models.{AskEntry, BidEntry, Event}

  @spec update_level(Event.t(), Types.order_book()) :: Types.order_book() | {:error, any()}
  def update_level(
        %Event{
          side: :bid,
          price_level_index: price_level_index,
          price: price,
          quantity: quantity
        },
        %{bid: bid_list} = order_book
      ) do
    {:ok, book_entry} =
      %{bid_price: price, bid_quantity: quantity}
      |> BidEntry.build()

    new_bid_list =
      bid_list
      |> Map.replace!(price_level_index, book_entry)

    Map.replace(order_book, :bid, new_bid_list)
  rescue
    KeyError -> {:error, :price_level_not_found}
  end

  def update_level(
        %Event{
          side: :ask,
          price_level_index: price_level_index,
          price: price,
          quantity: quantity
        },
        %{ask: ask_list} = order_book
      ) do
    {:ok, book_entry} =
      %{ask_price: price, ask_quantity: quantity}
      |> AskEntry.build()

    new_ask_list =
      ask_list
      |> Map.replace!(price_level_index, book_entry)

    Map.replace(order_book, :ask, new_ask_list)
  rescue
    KeyError -> {:error, :price_level_not_found}
  end
end
