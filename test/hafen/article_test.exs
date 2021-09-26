defmodule Hafen.ArticleText do
  use ExUnit.Case

  alias Hafen.Article

  describe "split_on_articles" do
    test "split_on_articles/1 with empty string returns list with single empty string" do
      assert Article.split_on_articles("") == [""]
    end

    test "split_on_articles/1 with sentence without articles returns list with the whole sentence" do
      s = "Ich liebe dich"
      assert Article.split_on_articles(s) == [s]
    end

    test "split_on_articles/1 should not break words that contain the article inside" do
      s = "denx xder xdas diex xdem desx"
      assert Article.split_on_articles(s) == [s]
    end

    test "split_on_articles/1 with sentence with articles returns splitted sentence" do
      s = "den b der c das d die e dem f des"
      assert Article.split_on_articles(s) == ["", " b ", " c ", " d ", " e ", " f ", ""]
    end

    test "split_on_articles/1 with sentence consisting of exactly one article returns two empty strings" do
      for article <- Article.articles() do
        assert Article.split_on_articles(article) == ["", ""]
      end
    end

    test "split_on_articles/1 with article preceding punctuation should split correctly" do
      s = "foo den."
      assert Article.split_on_articles(s) == ["foo ", "."]
    end
  end
end
