defmodule OrderBook.Exchange do
  @moduledoc """
    Exchange implementation that can respond to the start_link, send_instruction and order_book comamnds.

    ## Examples
      iex> {:ok, exchange_pid} = Exchange.start_link()
      iex> Exchange.send_instruction(exchange_pid, %{
      ...>  instruction: :new,
      ...>  side: :bid,
      ...>  price_level_index: 1,
      ...>  price: 50.0,
      ...>  quantity: 40
      ...> })
      :ok
      iex> Exchange.order_book(exchange_pid, 2)
      [
        %{ask_price: 0, ask_quantity: 0, bid_price: 50.0, bid_quantity: 40},
        %{ask_price: 0, ask_quantity: 0, bid_price: 0, bid_quantity: 0}
      ]
  """
  alias OrderBook.Handlers.EventHandler
  alias OrderBook.{Reader, Types}
  alias OrderBook.Models.Event

  use GenServer

  @initial_order_book %{ask: %{}, bid: %{}}

  @spec start_link(any()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_ \\ nil) do
    GenServer.start_link(__MODULE__, @initial_order_book)
  end

  @spec send_instruction(pid, map()) :: :ok | {:error, Ecto.Changeset.t()}
  def send_instruction(pid, instruction) do
    case Event.build(instruction) do
      {:ok, %Event{} = instruction} ->
        GenServer.call(pid, {:send_instruction, instruction})

      {:error, changeset} ->
        errors =
          Enum.map(changeset.errors, fn {field, detail} ->
            %{"#{field}" => render_error_detail(detail)}
          end)

        {:ok, "Invalud instruction: #{inspect(errors)}"}

      unexpected_error ->
        {:ok, "Unknwon error #{inspect(unexpected_error)}"}
    end
  end

  @spec order_book(pid, number()) :: Types.order_book_level()
  def order_book(pid, price_level) do
    GenServer.call(pid, {:order_book, price_level})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:order_book, price_level}, _, order_book) do
    {:reply, Reader.read(order_book, price_level), order_book}
  end

  @impl true
  def handle_call({:send_instruction, event}, _, order_book) do
    case EventHandler.handle(event, order_book) do
      {:error, error} -> {:reply, error, order_book}
      new_order_book -> {:reply, :ok, new_order_book}
    end
  end

  defp render_error_detail({message, values}) do
    Enum.reduce(values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end)
  end
end
