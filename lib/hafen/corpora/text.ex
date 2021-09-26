defmodule Hafen.Corpora.Text do
  @moduledoc "Text entity"

  use Ecto.Schema
  import Ecto.Changeset

  alias Hafen.Corpora.Corpus

  schema "text" do
    field :author, :string, default: ""
    field :date, :date
    field :raw_text, :string
    field :title, :string, default: ""

    belongs_to :corpus, Corpus

    timestamps()
  end

  @doc false
  def changeset(text, attrs) do
    text
    |> cast(attrs, [:title, :author, :date, :raw_text, :corpus_id])
    |> validate_required([:raw_text, :corpus_id])
  end
end
