defmodule Hafen.TrainerText do
  use Hafen.DataCase

  alias Hafen.Article
  alias Hafen.Corpora.Sentence
  alias Hafen.Corpora.Text
  alias Hafen.Trainer

  defp make_sentence(value) do
    t = %Text{raw_text: value}
    %Sentence{id: 0, text: t, value: value}
  end

  defp make_expected(sentence, expected_splitted) do
    %Trainer{sentence: sentence, splitted_sentence: expected_splitted}
  end

  describe "new/1" do
    defp assert_new_ok(raw_sentence, expected_splitted) do
      s = make_sentence(raw_sentence)
      expected = make_expected(s, expected_splitted)
      assert Trainer.new(s) == {:ok, expected}
    end

    defp assert_new_error(raw_sentence) do
      s = make_sentence(raw_sentence)
      {ok?, _} = Trainer.new(s)
      assert ok? == :error
    end

    test "with empty sentences returns error" do
      assert_new_error("")
      assert_new_error(".")
      assert_new_error("?")
    end

    test "with only articles returns error" do
      assert_new_error("die")
      assert_new_error("die der")
      assert_new_error("die der das")
    end

    test "with sentence with no articles returns error" do
      assert_new_error("ich liebe dich")
      assert_new_error("ich liebe dich.")
    end

    test "with sentence with article and one word returns ok" do
      assert_new_ok("die frau.", ["", " frau."])
      assert_new_ok("frau die.", ["frau ", "."])
    end

    test "with sentence with multiple articles returns ok" do
      assert_new_ok("die frau der.", ["", " frau ", "."])
    end
  end

  describe "get_article_trainer/1" do
    defp assert_get_article_trainer_ok(raw_text, expected_splitted, expected_sentence_id \\ 0) do
      t = %Text{raw_text: raw_text}

      expected =
        t
        |> Sentence.split()
        |> Enum.at(expected_sentence_id)
        |> make_expected(expected_splitted)

      assert Trainer.get_article_trainer(t) == {:ok, expected}
    end

    test "with one bad sentence returns error" do
      t = %Text{raw_text: "ich liebe dich"}
      assert {:error, _} = Trainer.get_article_trainer(t)
    end

    test "with one good sentence returns ok" do
      assert_get_article_trainer_ok("die frau", ["", " frau"])
    end

    test "with only bad sentences returns error" do
      t = %Text{raw_text: ". die. ich liebe dich."}
      assert {:error, _} = Trainer.get_article_trainer(t)
    end

    test "with 1 bad and 1 good sentence returns ok" do
      assert_get_article_trainer_ok("die. die frau", ["", " frau"], 1)
      assert_get_article_trainer_ok("die frau. die.", ["", " frau."], 0)
    end

    test "with 2 good sentences returns ok" do
      t = %Text{raw_text: "die frau. der man."}

      expected_options =
        Sentence.split(t)
        |> Enum.zip([["", " frau."], ["", " man."]])
        |> Enum.map(fn {s, splitted} -> %Trainer{sentence: s, splitted_sentence: splitted} end)

      {:ok, got} = Trainer.get_article_trainer(t)
      assert got in expected_options
    end
  end

  describe "get_article_trainer/0" do
    alias Hafen.Corpora

    test "gets random text" do
      {:ok, corpus} = Corpora.create_corpus(%{reference: "x"})
      {:ok, t} = Corpora.create_text(%{raw_text: "die frau.", corpus_id: corpus.id})
      s = %Sentence{} = Sentence.split(t) |> Enum.at(0)
      assert Trainer.get_article_trainer() == make_expected(s, ["", " frau."])
    end

    test "retries until a trainer is generated" do
      {:ok, corpus} = Corpora.create_corpus(%{reference: "x"})
      {:ok, _bad_t} = Corpora.create_text(%{raw_text: ".", corpus_id: corpus.id})
      {:ok, t} = Corpora.create_text(%{raw_text: "die frau.", corpus_id: corpus.id})

      s = %Sentence{} = Sentence.split(t) |> Enum.at(0)
      assert Trainer.get_article_trainer() == make_expected(s, ["", " frau."])
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
        sentence: make_sentence("der foo"),
        splitted_sentence: ["", " foo"]
      }

      assert Trainer.correct?(trainer, ["der"])
      assert Trainer.correct?(trainer, ["Der"])
      assert Trainer.correct?(trainer, ["DER"])

      assert not Trainer.correct?(trainer, ["das"])
    end
  end
end
