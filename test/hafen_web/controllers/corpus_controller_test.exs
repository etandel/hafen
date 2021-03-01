defmodule HafenWeb.CorpusControllerTest do
  use HafenWeb.ConnCase

  alias Hafen.Corpora
  alias Hafen.Corpora.Corpus

  @create_attrs %{
    reference: "some reference"
  }
  @update_attrs %{
    reference: "some updated reference"
  }
  @invalid_attrs %{reference: nil}

  def fixture(:corpus) do
    {:ok, corpus} = Corpora.create_corpus(@create_attrs)
    corpus
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all corpora", %{conn: conn} do
      conn = get(conn, Routes.corpus_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create corpus" do
    test "renders corpus when data is valid", %{conn: conn} do
      conn = post(conn, Routes.corpus_path(conn, :create), corpus: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.corpus_path(conn, :show, id))

      assert %{
               "id" => id,
               "reference" => "some reference"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.corpus_path(conn, :create), corpus: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update corpus" do
    setup [:create_corpus]

    test "renders corpus when data is valid", %{conn: conn, corpus: %Corpus{id: id} = corpus} do
      conn = put(conn, Routes.corpus_path(conn, :update, corpus), corpus: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.corpus_path(conn, :show, id))

      assert %{
               "id" => id,
               "reference" => "some updated reference"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, corpus: corpus} do
      conn = put(conn, Routes.corpus_path(conn, :update, corpus), corpus: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete corpus" do
    setup [:create_corpus]

    test "deletes chosen corpus", %{conn: conn, corpus: corpus} do
      conn = delete(conn, Routes.corpus_path(conn, :delete, corpus))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.corpus_path(conn, :show, corpus))
      end
    end
  end

  defp create_corpus(_) do
    corpus = fixture(:corpus)
    %{corpus: corpus}
  end
end
