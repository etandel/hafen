defmodule HafenWeb.TextControllerTest do
  use HafenWeb.ConnCase

  alias Hafen.Corpora
  alias Hafen.Corpora.Text

  @create_attrs %{
    author: "some author",
    date: ~D[2010-04-17],
    raw_text: "some raw_text",
    title: "some title"
  }
  @update_attrs %{
    author: "some updated author",
    date: ~D[2011-05-18],
    raw_text: "some updated raw_text",
    title: "some updated title"
  }
  @invalid_attrs %{author: nil, date: nil, raw_text: nil, title: nil}

  def create_attrs_with_corpus_id(%{id: corpus_id}) do
    Map.put(@create_attrs, :corpus_id, corpus_id)
  end

  def fixture(:text, %{} = corpus) do
    {:ok, text} =
      create_attrs_with_corpus_id(corpus)
      |> Corpora.create_text()

    text
  end

  setup %{conn: conn} do
    {:ok, corpus} = Corpora.create_corpus(%{reference: "some reference"})
    {:ok, conn: put_req_header(conn, "accept", "application/json"), corpus: corpus}
  end

  describe "index" do
    test "lists all texts empty", %{conn: conn, corpus: corpus} do
      conn = get(conn, Routes.text_path(conn, :index, corpus.id))
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all texts nonempty", %{conn: conn, corpus: corpus1} do
      {:ok, corpus2} = Corpora.create_corpus(%{reference: "another ref"})

      text_corpus1_1 = fixture(:text, corpus1)
      text_corpus1_2 = fixture(:text, corpus1)

      text_corpus2_1 = fixture(:text, corpus2)
      text_corpus2_2 = fixture(:text, corpus2)

      expected_1 = %{
        "data" => [
          %{
            "author" => "some author",
            "corpus" => %{"id" => corpus1.id, "reference" => "some reference"},
            "date" => "2010-04-17",
            "id" => text_corpus1_1.id,
            "raw_text" => "some raw_text",
            "title" => "some title"
          },
          %{
            "author" => "some author",
            "corpus" => %{"id" => corpus1.id, "reference" => "some reference"},
            "date" => "2010-04-17",
            "id" => text_corpus1_2.id,
            "raw_text" => "some raw_text",
            "title" => "some title"
          }
        ]
      }

      expected_2 = %{
        "data" => [
          %{
            "author" => "some author",
            "corpus" => %{"id" => corpus2.id, "reference" => "another ref"},
            "date" => "2010-04-17",
            "id" => text_corpus2_1.id,
            "raw_text" => "some raw_text",
            "title" => "some title"
          },
          %{
            "author" => "some author",
            "corpus" => %{"id" => corpus2.id, "reference" => "another ref"},
            "date" => "2010-04-17",
            "id" => text_corpus2_2.id,
            "raw_text" => "some raw_text",
            "title" => "some title"
          }
        ]
      }

      conn = get(conn, Routes.text_path(conn, :index, corpus1.id))
      assert json_response(conn, 200) == expected_1

      conn = get(conn, Routes.text_path(conn, :index, corpus2.id))
      assert json_response(conn, 200) == expected_2
    end
  end

  describe "create text" do
    test "renders text when data is valid", %{conn: conn, corpus: corpus} do
      conn =
        post(conn, Routes.text_path(conn, :create, corpus.id),
          text: create_attrs_with_corpus_id(corpus)
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.text_path(conn, :show, corpus.id, id))

      assert %{
               "id" => id,
               "author" => "some author",
               "date" => "2010-04-17",
               "raw_text" => "some raw_text",
               "title" => "some title",
               "corpus" => %{"id" => corpus.id, "reference" => corpus.reference},
             } == json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, corpus: corpus} do
      conn = post(conn, Routes.text_path(conn, :create, corpus.id), text: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show text" do
    setup [:create_text]

    test "show 404s when text does not belong to corpus", %{
      conn: conn,
      text: %Text{} = text,
    } do
      {:ok, wrong_corpus} = Corpora.create_corpus(%{reference: "another ref"})

      conn = get(conn, Routes.text_path(conn, :show, wrong_corpus.id, text.id))
      assert json_response(conn, 404)
    end
  end

  describe "update text" do
    setup [:create_text]

    test "renders text when data is valid", %{
      conn: conn,
      text: %Text{id: id} = text,
      corpus: corpus
    } do
      conn = put(conn, Routes.text_path(conn, :update, corpus.id, text), text: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.text_path(conn, :show, corpus.id, id))

      assert %{
               "id" => id,
               "author" => "some updated author",
               "date" => "2011-05-18",
               "raw_text" => "some updated raw_text",
               "title" => "some updated title",
               "corpus" => %{"id" => corpus.id, "reference" => corpus.reference},
             } == json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, text: text, corpus: corpus} do
      conn = put(conn, Routes.text_path(conn, :update, corpus.id, text), text: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "update 404s when text does not belong to corpus", %{
      conn: conn,
      text: %Text{} = text,
    } do
      {:ok, wrong_corpus} = Corpora.create_corpus(%{reference: "another ref"})

      conn =
        put(conn, Routes.text_path(conn, :update, wrong_corpus.id, text), text: @update_attrs)

      assert json_response(conn, 404)
    end
  end

  describe "delete text" do
    setup [:create_text]

    test "deletes chosen text", %{conn: conn, text: text, corpus: corpus} do
      conn = delete(conn, Routes.text_path(conn, :delete, corpus.id, text))
      assert response(conn, 204)

      conn = get(conn, Routes.text_path(conn, :show, corpus.id, text))
      assert json_response(conn, 404)
    end

    test "delete 404s when text does not belong to corpus", %{
      conn: conn,
      text: %Text{} = text,
    } do
      {:ok, wrong_corpus} = Corpora.create_corpus(%{reference: "another ref"})

      conn = delete(conn, Routes.text_path(conn, :delete, wrong_corpus.id, text))
      assert json_response(conn, 404)
    end
  end

  defp create_text(%{corpus: corpus}) do
    text = fixture(:text, corpus)
    %{text: text}
  end
end
