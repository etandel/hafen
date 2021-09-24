defmodule HafenWeb.TrainerController do
  use HafenWeb, :controller

  alias Hafen.Trainer
  require Logger

  def article_question(conn, _params) do
    trainer = Trainer.get_article_trainer()

    Logger.debug(trainer)

    render(conn, "question.html", splitted_sentence: trainer.splitted_sentence, conn: conn)
  end

  def article_answer(conn, params) do
    answers = params["answers"]
    Logger.debug(answers)
    conn
  end
end
