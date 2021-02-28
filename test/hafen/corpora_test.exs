defmodule Hafen.CorporaTest do
  use Hafen.DataCase

  alias Hafen.Corpora

  describe "corpora" do
    alias Hafen.Corpora.Corpus

    @valid_attrs %{reference: "some reference"}
    @update_attrs %{reference: "some updated reference"}
    @invalid_attrs %{reference: nil}

    def corpus_fixture(attrs \\ %{}) do
      {:ok, corpus} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Corpora.create_corpus()

      corpus
    end

    test "list_corpora/0 returns all corpora" do
      corpus = corpus_fixture()
      assert Corpora.list_corpora() == [corpus]
    end

    test "get_corpus!/1 returns the corpus with given id" do
      corpus = corpus_fixture()
      assert Corpora.get_corpus!(corpus.id) == corpus
    end

    test "create_corpus/1 with valid data creates a corpus" do
      assert {:ok, %Corpus{} = corpus} = Corpora.create_corpus(@valid_attrs)
      assert corpus.reference == "some reference"
    end

    test "create_corpus/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Corpora.create_corpus(@invalid_attrs)
    end

    test "update_corpus/2 with valid data updates the corpus" do
      corpus = corpus_fixture()
      assert {:ok, %Corpus{} = corpus} = Corpora.update_corpus(corpus, @update_attrs)
      assert corpus.reference == "some updated reference"
    end

    test "update_corpus/2 with invalid data returns error changeset" do
      corpus = corpus_fixture()
      assert {:error, %Ecto.Changeset{}} = Corpora.update_corpus(corpus, @invalid_attrs)
      assert corpus == Corpora.get_corpus!(corpus.id)
    end

    test "delete_corpus/1 deletes the corpus" do
      corpus = corpus_fixture()
      assert {:ok, %Corpus{}} = Corpora.delete_corpus(corpus)
      assert_raise Ecto.NoResultsError, fn -> Corpora.get_corpus!(corpus.id) end
    end

    test "change_corpus/1 returns a corpus changeset" do
      corpus = corpus_fixture()
      assert %Ecto.Changeset{} = Corpora.change_corpus(corpus)
    end
  end
end
