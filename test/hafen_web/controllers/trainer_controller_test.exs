defmodule HafenWeb.TrainerControllerTest do
  use HafenWeb.ConnCase

  alias Hafen.Corpora
  alias Hafen.Trainer

  @sentence_with_article "Das this sentence der contains articles at start, middle and end die"
  @correct_answer ["das", "der", "die"]

  def fixture(:trainer) do
    {:ok, corpus} = Corpora.create_corpus(%{reference: "ref"})
    {:ok, text} = Corpora.create_text(%{corpus_id: corpus.id, raw_text: @sentence_with_article})
    {:ok, trainer} = Trainer.get_article_trainer(text)
    trainer
  end

  describe "article" do
    test "article_question/2 renders correctly", %{conn: conn} do
      fixture(:trainer)
      conn = get(conn, Routes.trainer_path(conn, :article_question))
      assert Phoenix.Controller.view_template(conn) == "article.html"
    end

    test "article_answer/2 with correct answer renders correctly", %{conn: conn} do
      trainer = fixture(:trainer)

      answer_parts =
        @correct_answer
        |> Enum.with_index()
        |> Enum.map(fn {part, idx} -> {"answer_#{idx}", part} end)
        |> Map.new()

      answers =
        Map.merge(answer_parts, %{
          "text_id" => trainer.sentence.text.id |> to_string(),
          "sentence_id" => trainer.sentence.id |> to_string()
        })

      conn = post(conn, Routes.trainer_path(conn, :article_answer), %{"answers" => answers})

      assert html_response(conn, 200) =~ trainer.sentence.value
      assert Phoenix.Controller.view_template(conn) == "article.html"
      assert Phoenix.Controller.get_flash(conn, :info) =~ "Correct"
    end

    test "article_answer/2 with wrong answer renders correctly", %{conn: conn} do
      trainer = fixture(:trainer)

      answers = %{
        "text_id" => trainer.sentence.text.id |> to_string(),
        "sentence_id" => trainer.sentence.id |> to_string(),
        "answer_0" => "a",
        "answer_1" => "a",
        "answer_2" => "a"
      }

      conn = post(conn, Routes.trainer_path(conn, :article_answer), %{"answers" => answers})

      assert html_response(conn, 200) =~ trainer.sentence.value
      assert Phoenix.Controller.view_template(conn) == "article.html"
      assert Phoenix.Controller.get_flash(conn, :error) =~ "Sorry"
    end
  end
end
