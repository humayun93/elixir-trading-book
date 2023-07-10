defmodule OrderBook.Reader do
  @moduledoc """
  Reads the entry book levels up to the given depth, given depth must be a positive integer. Else it will raise an error.

  ## Examples

    iex> Reader.read(
    ...>   %{
    ...>     ask: %{},
    ...>     bid: %{1 => %OrderBook.Models.BidEntry{bid_price: 50.0, bid_quantity: 30}}
    ...>   },
    ...>   3
    ...> )
    [
      %{ask_price: 0, ask_quantity: 0, bid_price: 50.0, bid_quantity: 30},
      %{ask_price: 0, ask_quantity: 0, bid_price: 0, bid_quantity: 0},
      %{ask_price: 0, ask_quantity: 0, bid_price: 0, bid_quantity: 0}
    ]
  """

  alias OrderBook.Types

  @spec read(Types.order_book(), pos_integer()) :: Types.order_book_level()
  def read(_, nil), do: {:error, :argument_error}

  def read(%{ask: ask_list, bid: bid_list}, price_level)
      when is_integer(price_level) and price_level > 0 do
    Enum.map(1..price_level, fn current_level ->
      %{
        ask_price: read_entry(ask_list, current_level, :ask_price),
        ask_quantity: read_entry(ask_list, current_level, :ask_quantity),
        bid_price: read_entry(bid_list, current_level, :bid_price),
        bid_quantity: read_entry(bid_list, current_level, :bid_quantity)
      }
    end)
  end

  def read(_, _), do: {:error, :argument_error}

  defp read_entry(ask_list, index, key) do
    case Map.get(ask_list, index) do
      nil -> 0
      entry -> Map.get(entry, key)
    end
  end
end
