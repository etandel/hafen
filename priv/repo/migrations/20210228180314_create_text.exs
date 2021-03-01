defmodule Hafen.Repo.Migrations.CreateText do
  use Ecto.Migration

  def change do
    create table(:text) do
      add :title, :text, null: false, default: ""
      add :author, :text, null: false, default: ""
      add :date, :date
      add :raw_text, :text, null: false, default: ""
      add :corpus_id, references(:corpus, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:text, [:corpus_id])
  end
end
