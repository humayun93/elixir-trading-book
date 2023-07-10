defmodule OrderBook.Models.BidEntry do
  @moduledoc """
  Embedded schema for Bid Entry

  ## Examples
    iex> BidEntry.build(%{
    ...>    bid_price: 1.0,
    ...>    bid_quantity: 1
    ...>  }
    ...> )
    {:ok, %OrderBook.Models.BidEntry{bid_price: 1.0, bid_quantity: 1}}
  """

  use Ecto.Schema
  import Ecto.Changeset

  @permitted_attrs [:bid_price, :bid_quantity]

  @type t :: %__MODULE__{
          bid_price: number(),
          bid_quantity: pos_integer()
        }

  # for in memory objects
  @primary_key false
  embedded_schema do
    field(:bid_price, :float, default: 0.0)
    field(:bid_quantity, :integer, default: 0)
  end

  def changeset(entry, attrs \\ %{}) do
    entry
    |> cast(attrs, @permitted_attrs)
    |> validate()
  end

  defp validate(attrs) do
    attrs
    |> validate_number(:bid_price, greater_than: 0)
    |> validate_number(:bid_quantity, greater_than: 0)
  end

  def build(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:update)
  end
end
