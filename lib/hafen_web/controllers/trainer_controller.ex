defmodule HafenWeb.TrainerController do
  use HafenWeb, :controller

  alias Hafen.Corpora
  alias Hafen.Trainer
  require Logger

  def article_question(conn, _params) do
    trainer = Trainer.get_article_trainer()

    Logger.debug(trainer)

    render(conn, "article.html",
      conn: conn,
      trainer: trainer,
      state: :question
    )
  end

  defp get_answer_list(%{} = answers) do
    answers
    |> Stream.filter(fn {k, _} -> String.starts_with?(k, "answer_") end)
    |> Stream.map(fn {k, v} -> {k |> String.split("_") |> Enum.at(1), v} end)
    |> Enum.sort_by(fn {k, _} -> k end)
    |> Stream.map(fn {_, v} -> v end)
    |> Enum.to_list()
  end

  def article_answer(conn, %{
        "answers" => %{"text_id" => text_id, "sentence_index" => sentence_id} = raw_answers
      }) do
    answers = get_answer_list(raw_answers)
    text = %Corpora.Text{} = Corpora.get_text!(String.to_integer(text_id))
    {:ok, trainer} = Trainer.get_article_trainer(text, String.to_integer(sentence_id))

    correct = Trainer.correct?(trainer, answers)

    conn =
      case correct do
        true -> put_flash(conn, :info, "Correct!")
        false -> put_flash(conn, :error, "Sorry, wrong answer.")
      end

    render(conn, "article.html",
      conn: conn,
      trainer: trainer,
      state: :answer,
      correct: correct
    )
  end
end
