defmodule OrderBook.OrderBookStore.AddOrderBookEntry do
  @moduledoc """
  Adds new entry to the Orderbook

  ## Examples

    iex> AddOrderBookEntry.new_level(
    ...>   %OrderBook.Models.Event{
    ...>     instruction: :new,
    ...>     side: :bid,
    ...>     price_level_index: 1,
    ...>     price: 10.0,
    ...>     quantity: 20
    ...>   },
    ...>   %{ask: %{}, bid: %{}}
    ...> )
    %{
      ask: %{},
      bid: %{1 => %OrderBook.Models.BidEntry{bid_price: 10.0, bid_quantity: 20}}
    }
  """
  alias OrderBook.Types
  alias OrderBook.Models.{AskEntry, BidEntry, Event}

  @spec new_level(Event.t(), Types.order_book()) :: Types.order_book()
  def new_level(
        %Event{
          side: :ask,
          price_level_index: price_level_index,
          price: price,
          quantity: quantity
        },
        %{ask: ask_list} = order_book
      ) do
    {:ok, book_entry} = %{ask_price: price, ask_quantity: quantity} |> AskEntry.build()

    new_ask_list =
      ask_list
      |> shift_up(price_level_index, Map.get(ask_list, price_level_index))
      |> Map.put(price_level_index, book_entry)

    Map.replace(order_book, :ask, new_ask_list)
  end

  def new_level(
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
      |> shift_up(price_level_index, Map.get(bid_list, price_level_index))
      |> Map.put(price_level_index, book_entry)

    Map.replace(order_book, :bid, new_bid_list)
  end

  @spec shift_up(map(), integer(), any()) :: map()
  defp shift_up(map, _, nil), do: map

  defp shift_up(map, price_level_index, entry) do
    next_price_level = price_level_index + 1
    next_entry = Map.get(map, next_price_level)

    map
    |> Map.put(next_price_level, entry)
    |> shift_up(next_price_level, next_entry)
  end
end
