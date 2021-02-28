defmodule Hafen.Corpora.Corpus do
  use Ecto.Schema
  import Ecto.Changeset

  schema "corpus" do
    field :reference, :string

    timestamps()
  end

  @doc false
  def changeset(corpus, attrs) do
    corpus
    |> cast(attrs, [:reference])
    |> validate_required([:reference])
  end
end
