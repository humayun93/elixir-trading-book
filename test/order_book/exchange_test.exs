defmodule OrderBook.ExchangeTest do
  use ExUnit.Case, async: true

  alias OrderBook.Exchange

  doctest Exchange

  setup do
    %{
      exchange: start_supervised!(Exchange),
      valid_instruction: %{
        side: :bid,
        instruction: :new,
        price_level_index: 1,
        price: 20.0,
        quantity: 20
      },
      invalid_instruction: %{
        instruction: :new,
        price_level_index: 1,
        price: 20.0,
        quantity: 20
      }
    }
  end

  describe "send_instruction/2" do
    test "send_instruction/2 responds to valid instruction", %{
      exchange: exchange,
      valid_instruction: valid_instruction
    } do
      assert :ok = Exchange.send_instruction(exchange, valid_instruction)
    end

    test "send_instruction/2 responds with graceful error when the invalud price level is given",
         %{
           exchange: exchange,
           valid_instruction: valid_instruction
         } do
      instruction = %{valid_instruction | instruction: :update, price_level_index: 2}
      assert :price_level_not_found = Exchange.send_instruction(exchange, instruction)
    end

    test "send_instruction/2 returns validation errors", %{
      exchange: exchange,
      invalid_instruction: invalid_instruction
    } do
      assert {:ok, "Invalud instruction: [%{\"side\" => \"can't be blank\"}]"} =
               Exchange.send_instruction(exchange, invalid_instruction)
    end
  end

  describe "order_book/2" do
    test "returns proper order_book/2 returns valid order book entries", %{exchange: exchange} do
      assert [%{ask_price: 0, ask_quantity: 0, bid_price: 0, bid_quantity: 0}] =
               Exchange.order_book(exchange, 1)
    end

    test "order_book/2", %{exchange: exchange} do
      assert [%{ask_price: 0, ask_quantity: 0, bid_price: 0, bid_quantity: 0}] =
               Exchange.order_book(exchange, 1)
    end

    test "order_book/2 returns updated order book entries", %{
      exchange: exchange,
      valid_instruction: valid_instruction
    } do
      Exchange.send_instruction(exchange, valid_instruction)

      assert [
               %{ask_price: 0, ask_quantity: 0, bid_price: 20.0, bid_quantity: 20},
               %{ask_price: 0, ask_quantity: 0, bid_price: 0, bid_quantity: 0}
             ] = Exchange.order_book(exchange, 2)
    end

    test "order_book/2 returns error when ivalid level is given", %{
      exchange: exchange,
      valid_instruction: valid_instruction
    } do
      Exchange.send_instruction(exchange, valid_instruction)

      assert {:error, :argument_error} = Exchange.order_book(exchange, -2)
    end
  end
end
