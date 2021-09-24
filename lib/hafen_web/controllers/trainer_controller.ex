defmodule HafenWeb.TrainerController do
  use HafenWeb, :controller

  alias Hafen.Corpora
  alias Hafen.Trainer
  require Logger

  def article_question(conn, _params) do
    trainer = Trainer.get_article_trainer()

    Logger.debug(trainer)

    render(conn, "question.html",
      text_id: trainer.text.id,
      sentence_index: trainer.sentence_index,
      splitted_sentence: trainer.splitted_sentence,
      conn: conn
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
    conn = case correct do
      true -> put_flash(conn, :info, "Congrats!")
      false -> put_flash(conn, :error, "Oops")
    end

    render(conn, "answer.html",
      splitted_sentence: trainer.splitted_sentence,
      conn: conn,
      correct: correct,
      answers: raw_answers,
      raw_text: trainer.text.raw_text
    )
  end
end
