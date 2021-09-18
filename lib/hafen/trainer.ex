defmodule Hafen.Trainer do
  @moduledoc """
  Trainers
  """

  alias Hafen.Corpora.Text
  alias Hafen.Article

  def get_article_trainer(%Text{raw_text: raw_text}) do
    splitted =
      raw_text
      |> String.split(".")
      |> Enum.shuffle()
      |> Stream.map(fn sentence ->
        splitted = Article.split_on_articles(sentence)

        if length(splitted) == 1 or Enum.all?(splitted, &(String.trim(&1) == "")) do
          nil
        else
          splitted
        end
      end)
      |> Stream.filter(&(&1 != nil))
      |> Enum.at(0)

    case splitted do
      nil -> {:error, "Cannot get trainer for text"}
      s -> {:ok, s}
    end
  end
end
