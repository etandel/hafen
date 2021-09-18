defmodule Hafen.TrainerText do
  use Hafen.DataCase

  alias Hafen.Corpora.Text
  alias Hafen.Trainer

  defp make_expected(expected_text, expected_splitted, expected_index \\ 0) do
    %Trainer{
      text: expected_text,
      splitted_sentence: expected_splitted,
      sentence_index: expected_index
    }
  end

  describe "get_article_trainer" do
    defp assert_ok(raw_text, expected_splitted, expected_index \\ 0) do
      t = %Text{raw_text: raw_text}

      expected = make_expected(t, expected_splitted, expected_index)
      assert Trainer.get_article_trainer(t) == {:ok, expected}
    end

    test "get_article_trainer/1 with empty string error" do
      t = %Text{raw_text: ""}
      assert {:error, _} = Trainer.get_article_trainer(t)
    end

    test "get_article_trainer/1 with only articles returns error" do
      t = %Text{raw_text: "die"}
      assert {:error, _} = Trainer.get_article_trainer(t)

      t = %Text{raw_text: "die der"}
      assert {:error, _} = Trainer.get_article_trainer(t)

      t = %Text{raw_text: "die der das"}
      assert {:error, _} = Trainer.get_article_trainer(t)
    end

    test "get_article_trainer/1 with sentence with no articles returns error" do
      t = %Text{raw_text: "ich liebe dich"}
      assert {:error, _} = Trainer.get_article_trainer(t)
    end

    test "get_article_trainer/1 with sentence with article and one word returns ok" do
      assert_ok("die frau", ["", " frau"])
      assert_ok("frau die", ["frau ", ""])
    end

    test "get_article_trainer/1 with sentence with multiple articles returns ok" do
      assert_ok("die frau der", ["", " frau ", ""])
    end

    test "get_article_trainer/1 with only bad sentences returns error" do
      t = %Text{raw_text: ". die. ich liebe dich."}
      assert {:error, _} = Trainer.get_article_trainer(t)
    end

    test "get_article_trainer/1 with 1 bad and 1 good sentence returns ok" do
      assert_ok("die. die frau", [" ", " frau"], 1)
      assert_ok("die frau. die.", ["", " frau"], 0)
    end

    test "get_article_trainer/1 with 2 good sentences returns ok" do
      t = %Text{raw_text: "die frau. der man."}
      {:ok, got} = Trainer.get_article_trainer(t)
      assert got in [make_expected(t, ["", " frau"], 0), make_expected(t, [" ", " man"], 1)]
    end
  end

  describe "get_random_article_trainer" do
    alias Hafen.Corpora

    test "get_random_article_trainer/0 gets random text" do
      {:ok, corpus} = Corpora.create_corpus(%{reference: "x"})
      {:ok, t} = Corpora.create_text(%{raw_text: "die frau.", corpus_id: corpus.id})

      assert Trainer.get_random_article_trainer() == make_expected(t, ["", " frau"])
    end

    test "get_random_article_trainer/0 retries until a trainer is generated" do
      {:ok, corpus} = Corpora.create_corpus(%{reference: "x"})
      {:ok, _bad_t} = Corpora.create_text(%{raw_text: ".", corpus_id: corpus.id})
      {:ok, t} = Corpora.create_text(%{raw_text: "die frau.", corpus_id: corpus.id})

      assert Trainer.get_random_article_trainer() == make_expected(t, ["", " frau"])
    end
  end
end
