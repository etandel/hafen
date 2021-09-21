defmodule Hafen.Trainer do
  @moduledoc """
  Trainers
  """

  alias Hafen.Corpora
  alias Hafen.Corpora.Text
  alias Hafen.Article

  @enforce_keys [:text, :sentence_index, :splitted_sentence]
  defstruct [:text, :sentence_index, :splitted_sentence]

  @type t() :: %__MODULE__{
          text: %Text{},
          sentence_index: integer(),
          splitted_sentence: list(String.t())
        }

  @spec get_article_trainer(%Text{}) :: {:ok, t()} | {:error, String.t()}
  def get_article_trainer(%Text{raw_text: raw_text} = text) do
    splitted =
      raw_text
      |> String.split(".")
      |> Stream.with_index()
      |> Enum.shuffle()
      |> Stream.map(fn {sentence, idx} ->
        splitted = Article.split_on_articles(sentence)

        if length(splitted) == 1 or Enum.all?(splitted, &(String.trim(&1) == "")) do
          nil
        else
          {splitted, idx}
        end
      end)
      |> Stream.filter(&(&1 != nil))
      |> Enum.at(0)

    case splitted do
      nil ->
        {:error, "Cannot get trainer for text"}

      {splitted_sentence, idx} ->
        tr = %__MODULE__{
          text: text,
          sentence_index: idx,
          splitted_sentence: splitted_sentence
        }

        {:ok, tr}
    end
  end

  @spec get_random_article_trainer() :: t()
  def get_random_article_trainer() do
    trainer = Corpora.get_random_text() |> get_article_trainer()

    case trainer do
      {:error, _} ->
        get_random_article_trainer()

      {:ok, trainer} ->
        trainer
    end
  end
end
