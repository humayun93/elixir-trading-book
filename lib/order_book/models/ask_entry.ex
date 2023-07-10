defmodule OrderBook.Models.AskEntry do
  @moduledoc """
  Embedded schema for Ask Entry

  ## Examples

    iex> AskEntry.build(%{
    ...>    ask_price: 1.0,
    ...>    ask_quantity: 1
    ...>  }
    ...> )
    {:ok, %OrderBook.Models.AskEntry{ask_price: 1.0, ask_quantity: 1}}
  """

  use Ecto.Schema
  import Ecto.Changeset

  @permitted_attrs [:ask_price, :ask_quantity]

  @type t :: %__MODULE__{
          ask_price: number(),
          ask_quantity: pos_integer()
        }

  @primary_key false
  embedded_schema do
    field(:ask_price, :float, default: 0.0)
    field(:ask_quantity, :integer, default: 0)
  end

  def changeset(entry, attrs \\ %{}) do
    entry
    |> cast(attrs, @permitted_attrs)
    |> validate
  end

  defp validate(attrs) do
    attrs
    |> validate_number(:ask_price, greater_than: 0)
    |> validate_number(:ask_quantity, greater_than: 0)
  end

  def build(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:update)
  end
end
