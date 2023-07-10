# OrderBook

An order book simulation that can take price level insturctions and respond with the updated order book upto a given depth.

## Assumptions
- There will be only single instance of exchange running at any given moment. This assumption was made in order to make the choice between in memory order book, or a to keep the order book on a shared node with amnesia.

## Requisites

- Elixir (1.14.3)

## To demo

```
iex -S mix
```

```elixir
iex(1)> alias OrderBook.Exchange
OrderBook.Exchange
iex(2)> {:ok, exchange_pid} = Exchange.start_link()
{:ok, #PID<0.262.0>}
iex(3)> Exchange.send_instruction(exchange_pid, %{
...(3)>  instruction: :new,
...(3)>  side: :bid,
...(3)>  price_level_index: 1, 
...(3)>  price: 50.0,
...(3)>  quantity: 30
...(3)>  })
:ok
iex(4)> Exchange.order_book(exchange_pid, 2)
[
  %{ask_price: 0, ask_quantity: 0, bid_price: 50.0, bid_quantity: 30},
  %{ask_price: 0, ask_quantity: 0, bid_price: 0, bid_quantity: 0}
]
```

# To read module docs and examples

```
iex(1) h OrderBook.Exchange
```

