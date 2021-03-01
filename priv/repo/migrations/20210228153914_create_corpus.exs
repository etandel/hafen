defmodule Hafen.Repo.Migrations.CreateCorpus do
  use Ecto.Migration

  def change do
    create table(:corpus) do
      add :reference, :text, null: false, default: ""

      timestamps()
    end

  end
end
