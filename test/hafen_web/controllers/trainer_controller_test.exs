defmodule HafenWeb.TrainerControllerTest do
  use HafenWeb.ConnCase

  alias Hafen.Corpora
  alias Hafen.Trainer

  import Phoenix.View

  @sentence_with_article "Das this sentence der contains articles at start, middle and end die"

  def fixture(:trainer) do
    {:ok, corpus} = Corpora.create_corpus(%{reference: "ref"})
    {:ok, text} = Corpora.create_text(%{corpus_id: corpus.id, raw_text: @sentence_with_article})
    {:ok, trainer} = Trainer.get_article_trainer(text)
    trainer
  end

  describe "article_question" do
    test "renders trainer's splitted questions", %{conn: conn} do
      trainer = fixture(:trainer)

      conn = get(conn, Routes.trainer_path(conn, :article_question))

      got = html_response(conn, 200)

      expected =
        render_to_string(HafenWeb.TrainerView, "question.html",
          splitted_sentence: trainer.splitted_sentence
        )

      assert got =~ expected
    end
  end
end
