defmodule OrderBook.Handlers.EventHandler do
  @moduledoc """
  Handle events of :new, :update and :delete types.

  ## Examples

    iex> EventHandler.handle(
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
      bid: %{ 1 => %OrderBook.Models.BidEntry{bid_price: 10.0, bid_quantity: 20} }
    }
  """

  alias OrderBook.Types
  alias OrderBook.Models.Event
  alias OrderBook.OrderBookStore.{AddOrderBookEntry, DeleteOrderBookEntry, UpdateOrderBookEntry}

  @spec handle(Event.t(), Types.order_book()) :: Types.order_book() | {:error, any()}
  def handle(
        %Event{instruction: :new} = event,
        order_book
      ) do
    AddOrderBookEntry.new_level(event, order_book)
  end

  def handle(
        %Event{instruction: :update} = event,
        order_book
      ) do
    UpdateOrderBookEntry.update_level(event, order_book)
  end

  def handle(
        %Event{instruction: :delete} = event,
        order_book
      ) do
    DeleteOrderBookEntry.delete_level(event, order_book)
  end
end
