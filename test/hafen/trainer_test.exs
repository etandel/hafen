defmodule Hafen.TrainerText do
  use ExUnit.Case

  alias Hafen.Corpora.Text
  alias Hafen.Trainer

  describe "get_article_trainer" do
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
      t = %Text{raw_text: "die frau"}
      assert {:ok, ["", " frau"]} = Trainer.get_article_trainer(t)

      t = %Text{raw_text: "frau die"}
      assert {:ok, ["frau ", ""]} = Trainer.get_article_trainer(t)
    end

    test "get_article_trainer/1 with sentence with multiple articles returns ok" do
      t = %Text{raw_text: "die frau der"}
      assert {:ok, ["", " frau ", ""]} = Trainer.get_article_trainer(t)
    end

    test "get_article_trainer/1 with only bad sentences returns error" do
      t = %Text{raw_text: ". die. ich liebe dich."}
      assert {:error, _} = Trainer.get_article_trainer(t)
    end

    test "get_article_trainer/1 with 1 bad and 1 good sentence returns ok" do
      t = %Text{raw_text: "die. die frau"}
      assert {:ok, [" ", " frau"]} = Trainer.get_article_trainer(t)

      t = %Text{raw_text: "die frau. die."}
      assert {:ok, ["", " frau"]} = Trainer.get_article_trainer(t)
    end

    test "get_article_trainer/1 with 2 good sentences returns ok" do
      t = %Text{raw_text: "die frau. der man."}
      got = Trainer.get_article_trainer(t)
      assert got == {:ok, ["", " frau"]} or got == {:ok, [" ", " man"]}
    end
  end
end
