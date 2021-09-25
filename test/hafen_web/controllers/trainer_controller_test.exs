defmodule HafenWeb.TrainerControllerTest do
  use HafenWeb.ConnCase

  alias Hafen.Corpora
  alias Hafen.Trainer

  @sentence_with_article "Das this sentence der contains articles at start, middle and end die"

  def fixture(:trainer) do
    {:ok, corpus} = Corpora.create_corpus(%{reference: "ref"})
    {:ok, text} = Corpora.create_text(%{corpus_id: corpus.id, raw_text: @sentence_with_article})
    {:ok, trainer} = Trainer.get_article_trainer(text)
    trainer
  end

  describe "article_question" do
    test "renders trainer's splitted questions", %{conn: conn} do
      fixture(:trainer)
      conn = get(conn, Routes.trainer_path(conn, :article_question))
      assert Phoenix.Controller.view_template(conn) == "article.html"
    end
  end
end
