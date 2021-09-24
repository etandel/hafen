defmodule Hafen.TrainerText do
  use Hafen.DataCase

  alias Hafen.Article
  alias Hafen.Corpora.Text
  alias Hafen.Trainer

  defp make_expected(expected_text, expected_splitted, expected_index \\ 0) do
    %Trainer{
      text: expected_text,
      splitted_sentence: expected_splitted,
      sentence_index: expected_index
    }
  end

  describe "get_article_trainer/1" do
    defp assert_ok(raw_text, expected_splitted, expected_index \\ 0) do
      t = %Text{raw_text: raw_text}

      expected = make_expected(t, expected_splitted, expected_index)
      assert Trainer.get_article_trainer(t) == {:ok, expected}
    end

    test "with empty string error" do
      t = %Text{raw_text: ""}
      assert {:error, _} = Trainer.get_article_trainer(t)
    end

    test "with only articles returns error" do
      t = %Text{raw_text: "die"}
      assert {:error, _} = Trainer.get_article_trainer(t)

      t = %Text{raw_text: "die der"}
      assert {:error, _} = Trainer.get_article_trainer(t)

      t = %Text{raw_text: "die der das"}
      assert {:error, _} = Trainer.get_article_trainer(t)
    end

    test "with sentence with no articles returns error" do
      t = %Text{raw_text: "ich liebe dich"}
      assert {:error, _} = Trainer.get_article_trainer(t)
    end

    test "with sentence with article and one word returns ok" do
      assert_ok("die frau", ["", " frau"])
      assert_ok("frau die", ["frau ", ""])
    end

    test "with sentence with multiple articles returns ok" do
      assert_ok("die frau der", ["", " frau ", ""])
    end

    test "with only bad sentences returns error" do
      t = %Text{raw_text: ". die. ich liebe dich."}
      assert {:error, _} = Trainer.get_article_trainer(t)
    end

    test "with 1 bad and 1 good sentence returns ok" do
      assert_ok("die. die frau", [" ", " frau"], 1)
      assert_ok("die frau. die.", ["", " frau"], 0)
    end

    test "with 2 good sentences returns ok" do
      t = %Text{raw_text: "die frau. der man."}
      {:ok, got} = Trainer.get_article_trainer(t)
      assert got in [make_expected(t, ["", " frau"], 0), make_expected(t, [" ", " man"], 1)]
    end
  end

  describe "get_article_trainer/2" do
    test "ok" do
      t = %Text{raw_text: "der foo. das bar."}

      assert {:ok, got} = Trainer.get_article_trainer(t, 0)
      assert got == %Trainer{text: t, sentence_index: 0, splitted_sentence: ["", " foo"]}

      assert {:ok, got} = Trainer.get_article_trainer(t, 1)
      assert got == %Trainer{text: t, sentence_index: 1, splitted_sentence: [" ", " bar"]}

      assert {:error, _} = Trainer.get_article_trainer(t, 3)
      assert {:error, _} = Trainer.get_article_trainer(t, -10)
    end
  end

  describe "get_article_trainer/0" do
    alias Hafen.Corpora

    test "gets random text" do
      {:ok, corpus} = Corpora.create_corpus(%{reference: "x"})
      {:ok, t} = Corpora.create_text(%{raw_text: "die frau.", corpus_id: corpus.id})

      assert Trainer.get_article_trainer() == make_expected(t, ["", " frau"])
    end

    test "retries until a trainer is generated" do
      {:ok, corpus} = Corpora.create_corpus(%{reference: "x"})
      {:ok, _bad_t} = Corpora.create_text(%{raw_text: ".", corpus_id: corpus.id})
      {:ok, t} = Corpora.create_text(%{raw_text: "die frau.", corpus_id: corpus.id})

      assert Trainer.get_article_trainer() == make_expected(t, ["", " frau"])
    end
  end

  describe "merge_answers_with_text" do
    defp assert_merge_ok(raw_text, answers) do
      got = raw_text |> Article.split_on_articles() |> Trainer.merge_text_with_answers(answers)
      assert got == raw_text
    end

    test "merge_answers_with_text/2" do
      assert_merge_ok("No article", [])
      assert_merge_ok("Der article", ["Der"])
      assert_merge_ok("Article die", ["die"])
      assert_merge_ok("foo des bar", ["des"])
    end
  end

  describe "correct?" do
    test "with only one sentence" do
      trainer = %Trainer{
        text: %Text{raw_text: "der foo"},
        splitted_sentence: ["", " foo"],
        sentence_index: 0
      }

      assert Trainer.correct?(trainer, ["der"])
      assert Trainer.correct?(trainer, ["Der"])
      assert Trainer.correct?(trainer, ["DER"])

      assert not Trainer.correct?(trainer, ["das"])
    end

    test "with only two sentences" do
      trainer = %Trainer{
        text: %Text{raw_text: "der foo. das bar"},
        splitted_sentence: [" ", " bar"],
        sentence_index: 1
      }

      assert Trainer.correct?(trainer, ["das"])
      assert Trainer.correct?(trainer, ["Das"])
      assert Trainer.correct?(trainer, ["DAS"])

      assert not Trainer.correct?(trainer, ["der"])
    end
  end
end
