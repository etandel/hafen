defmodule HafenWeb.TextController do
  use HafenWeb, :controller

  alias Hafen.Corpora
  alias Hafen.Corpora.Text

  action_fallback HafenWeb.FallbackController

  def index(conn, %{"corpus_id" => corpus_id}) do
    texts = Corpora.list_texts(corpus_id)
    render(conn, "index.json", texts: texts)
  end

  def create(conn, %{"text" => text_params, "corpus_id" => corpus_id}) do
    result =
      text_params
      |> Corpora.create_text(corpus_id)

    with {:ok, %Text{} = text} <- result do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.text_path(conn, :show, corpus_id, text))
      |> render("show.json", text: text)
    end
  end

  def show(conn, %{"id" => id, "corpus_id" => corpus_id}) do
    with {:ok, %Text{} = text} <- Corpora.get_text(id, corpus_id) do
      render(conn, "show.json", text: text)
    end
  end

  def update(conn, %{"id" => id, "text" => text_params, "corpus_id" => corpus_id}) do
    with {:ok, %Text{} = text} <- Corpora.get_text(id, corpus_id),
         {:ok, %Text{} = text} <- Corpora.update_text(text, text_params) do
      render(conn, "show.json", text: text)
    end
  end

  def delete(conn, %{"id" => id, "corpus_id" => corpus_id}) do
    with {:ok, %Text{} = text} <- Corpora.get_text(id, corpus_id),
         {:ok, %Text{}} <- Corpora.delete_text(text) do
      send_resp(conn, :no_content, "")
    end
  end
end
