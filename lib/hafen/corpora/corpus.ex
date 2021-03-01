defmodule Hafen.Corpora.Corpus do
  use Ecto.Schema
  import Ecto.Changeset

  alias Hafen.Corpora.Text

  schema "corpus" do
    field :reference, :string

    has_many :text, Text

    timestamps()
  end

  @doc false
  def changeset(corpus, attrs) do
    corpus
    |> cast(attrs, [:reference])
    |> validate_required([:reference])
  end
end
