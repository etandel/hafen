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

  describe "texts" do
    alias Hafen.Corpora.Text

    @valid_attrs %{
      author: "some author",
      date: ~D[2010-04-17],
      raw_text: "some raw_text",
      title: "some title"
    }
    @update_attrs %{
      author: "some updated author",
      date: ~D[2011-05-18],
      raw_text: "some updated raw_text",
      title: "some updated title"
    }
    @invalid_attrs %{author: nil, date: nil, raw_text: nil, title: nil}

    def valid_attrs_with_corpus() do
      corpus = corpus_fixture()
      Map.put(@valid_attrs, :corpus_id, corpus.id)
    end

    def text_fixture(attrs \\ %{}) do
      corpus = corpus_fixture()

      {:ok, text} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:corpus_id, corpus.id)
        |> Corpora.create_text()

      text
    end

    test "list_texts/0 returns all texts" do
      text = text_fixture()
      assert Corpora.list_texts() == [text]
    end

    test "get_text!/1 returns the text with given id" do
      text = text_fixture()
      assert Corpora.get_text!(text.id) == text
    end

    test "get_random_text/0 returns a random text if one exists" do
      text = text_fixture()
      assert Corpora.get_random_text() == text
    end

    test "get_random_text/0 returns nil if none exists" do
      assert Corpora.get_random_text() == nil
    end

    test "create_text/1 with valid data creates a text" do
      assert {:ok, %Text{} = text} = Corpora.create_text(valid_attrs_with_corpus())
      assert text.author == "some author"
      assert text.date == ~D[2010-04-17]
      assert text.raw_text == "some raw_text"
      assert text.title == "some title"
    end

    test "create_text/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Corpora.create_text(@invalid_attrs)
    end

    test "update_text/2 with valid data updates the text" do
      text = text_fixture()
      assert {:ok, %Text{} = text} = Corpora.update_text(text, @update_attrs)
      assert text.author == "some updated author"
      assert text.date == ~D[2011-05-18]
      assert text.raw_text == "some updated raw_text"
      assert text.title == "some updated title"
    end

    test "update_text/2 with invalid data returns error changeset" do
      text = text_fixture()
      assert {:error, %Ecto.Changeset{}} = Corpora.update_text(text, @invalid_attrs)
      assert text == Corpora.get_text!(text.id)
    end

    test "delete_text/1 deletes the text" do
      text = text_fixture()
      assert {:ok, %Text{}} = Corpora.delete_text(text)
      assert_raise Ecto.NoResultsError, fn -> Corpora.get_text!(text.id) end
    end

    test "change_text/1 returns a text changeset" do
      text = text_fixture()
      assert %Ecto.Changeset{} = Corpora.change_text(text)
    end
  end
end
