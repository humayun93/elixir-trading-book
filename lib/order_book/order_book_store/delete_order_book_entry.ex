defmodule OrderBook.OrderBookStore.DeleteOrderBookEntry do
  @moduledoc """
  Removes entry from the Orderbook

  ## Examples

    iex> DeleteOrderBookEntry.delete_level(
    ...>   %OrderBook.Models.Event{
    ...>     instruction: :delete,
    ...>     side: :bid,
    ...>     price_level_index: 1,
    ...>     price: 10.0,
    ...>     quantity: 20
    ...>   },
    ...>   %{ask: %{}, bid: %{1 => %OrderBook.Models.BidEntry{bid_price: 10.0, bid_quantity: 20}}}
    ...> )
    %{
      ask: %{},
      bid: %{}
    }
  """
  alias OrderBook.Models.Event
  alias OrderBook.Types

  @spec delete_level(Event.t(), Types.order_book()) :: Types.order_book()
  def delete_level(
        %Event{
          side: :ask,
          price_level_index: price_level_index
        },
        %{ask: ask_list} = order_book
      ) do
    new_ask_list =
      ask_list
      |> Map.delete(price_level_index)
      |> shift_down(price_level_index, Map.get(ask_list, price_level_index + 1))

    Map.replace(order_book, :ask, new_ask_list)
  end

  def delete_level(
        %Event{
          side: :bid,
          price_level_index: price_level_index
        },
        %{bid: bid_list} = order_book
      ) do
    new_bid_list =
      bid_list
      |> Map.delete(price_level_index)
      |> shift_down(price_level_index + 1, Map.get(bid_list, price_level_index + 1))

    Map.replace(order_book, :bid, new_bid_list)
  end

  @spec shift_down(map(), integer(), any()) :: map()
  defp shift_down(map, index, nil), do: Map.delete(map, index - 1)

  defp shift_down(map, price_level_index, entry) do
    next_entry = Map.get(map, price_level_index + 1)

    map
    |> Map.put(price_level_index - 1, entry)
    |> shift_down(price_level_index + 1, next_entry)
  end
end
