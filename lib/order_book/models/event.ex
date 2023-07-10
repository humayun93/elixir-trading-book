defmodule OrderBook.Models.Event do
  @moduledoc """
  Embedded schema for Event

  ## Examples

    iex> Event.build(%{
    ...>    instruction: :new,
    ...>    side: :ask,
    ...>    price_level_index: 1,
    ...>    price: 80.0,
    ...>    quantity: 3
    ...>  }
    ...> )
    {:ok, %OrderBook.Models.Event{instruction: :new, side: :ask, price_level_index: 1, price: 80.0, quantity: 3}}
  """

  use Ecto.Schema
  import Ecto.Changeset

  @instruction_options [:new, :update, :delete]
  @side_options [:bid, :ask]

  @permitted_attrs [:instruction, :side, :price_level_index, :price, :quantity]

  @type t :: %__MODULE__{
          instruction: atom(),
          side: atom(),
          price_level_index: number(),
          price: float(),
          quantity: number()
        }

  @primary_key false
  embedded_schema do
    field(:instruction, Ecto.Enum, values: @instruction_options)
    field(:side, Ecto.Enum, values: @side_options)
    field(:price_level_index, :integer)
    field(:price, :float)
    field(:quantity, :integer)
  end

  def changeset(instruction, attrs \\ %{}) do
    instruction
    |> cast(attrs, @permitted_attrs)
    |> validate()
  end

  defp validate(%Ecto.Changeset{changes: %{instruction: :delete}} = changeset) do
    changeset
    |> validate_required([:price_level_index, :side])
  end

  defp validate(changeset) do
    changeset
    |> validate_required(@permitted_attrs)
    |> validate_number(:price_level_index, greater_than: 0)
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:quantity, greater_than: 0)
  end

  def build(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:update)
  end
end
