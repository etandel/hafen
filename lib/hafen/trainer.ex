defmodule Hafen.Trainer do
  @moduledoc """
  Trainers
  """

  alias Hafen.Corpora
  alias Hafen.Corpora.Text
  alias Hafen.Corpora.Sentence
  alias Hafen.Article

  @enforce_keys [:sentence, :splitted_sentence]
  defstruct [:sentence, :splitted_sentence]

  @type t() :: %__MODULE__{
          sentence: %Sentence{},
          splitted_sentence: list(String.t())
        }

  defp valid?(splitted) do
    validators = [
      fn sp -> length(sp) > 1 end,
      fn sp ->
        not (sp
             |> Stream.map(&String.trim/1)
             |> Enum.all?(fn part -> part == "" or Sentence.punctuation_only?(part) end))
      end
    ]

    validators |> Enum.all?(fn v -> v.(splitted) end)
  end

  @spec new(%Sentence{}) :: {:error, String.t()} | {:ok, t}
  def new(%Sentence{value: raw_sentence} = sentence) do
    splitted = Article.split_on_articles(raw_sentence)

    if valid?(splitted) do
      {:ok, %__MODULE__{sentence: sentence, splitted_sentence: splitted}}
    else
      {:error, "Could not get article trainer from sentence #{sentence.text.id}_#{sentence.id}"}
    end
  end

  @spec get_article_trainer(%Text{}) :: {:ok, t} | {:error, String.t()}
  def get_article_trainer(%Text{} = text) do
    trainer =
      text
      |> Sentence.split()
      |> Enum.shuffle()
      |> Stream.map(&new/1)
      |> Stream.filter(fn {ok, _} -> ok == :ok end)
      |> Enum.at(0)

    case trainer do
      nil -> {:error, "Cannot get trainer for text"}
      trainer -> trainer
    end
  end

  @spec get_article_trainer() :: t
  def get_article_trainer() do
    trainer = Corpora.get_random_text() |> get_article_trainer()

    case trainer do
      {:error, _} ->
        get_article_trainer()

      {:ok, trainer} ->
        trainer
    end
  end

  @spec merge_text_with_answers(list(String.t()), list(String.t())) :: String.t()
  def merge_text_with_answers(splitted_text, answers) do
    Stream.zip(splitted_text, answers)
    |> Stream.concat([{Enum.at(splitted_text, -1), ""}])
    |> Enum.map_join("", &(&1 |> Tuple.to_list() |> Enum.join()))
  end

  def correct?(%__MODULE__{} = trainer, answers) do
    got = merge_text_with_answers(trainer.splitted_sentence, answers) |> String.downcase()
    expected = trainer.sentence.value |> String.downcase()
    got == expected
  end
end
