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

  def create_attrs_with_corpus_id() do
    {:ok, corpus} = Corpora.create_corpus(%{reference: "some reference"})
    Map.put(@create_attrs, :corpus_id, corpus.id)
  end

  def fixture(:text) do
    {:ok, text} =
      create_attrs_with_corpus_id()
      |> Corpora.create_text()

    text
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all texts", %{conn: conn} do
      conn = get(conn, Routes.text_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create text" do
    test "renders text when data is valid", %{conn: conn} do
      conn = post(conn, Routes.text_path(conn, :create), text: create_attrs_with_corpus_id())
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.text_path(conn, :show, id))

      assert %{
               "id" => id,
               "author" => "some author",
               "date" => "2010-04-17",
               "raw_text" => "some raw_text",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.text_path(conn, :create), text: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update text" do
    setup [:create_text]

    test "renders text when data is valid", %{conn: conn, text: %Text{id: id} = text} do
      conn = put(conn, Routes.text_path(conn, :update, text), text: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.text_path(conn, :show, id))

      assert %{
               "id" => id,
               "author" => "some updated author",
               "date" => "2011-05-18",
               "raw_text" => "some updated raw_text",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, text: text} do
      conn = put(conn, Routes.text_path(conn, :update, text), text: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete text" do
    setup [:create_text]

    test "deletes chosen text", %{conn: conn, text: text} do
      conn = delete(conn, Routes.text_path(conn, :delete, text))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.text_path(conn, :show, text))
      end
    end
  end

  defp create_text(_) do
    text = fixture(:text)
    %{text: text}
  end
end
