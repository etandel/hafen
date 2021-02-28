defmodule HafenWeb.TextController do
  use HafenWeb, :controller

  alias Hafen.Corpora
  alias Hafen.Corpora.Text

  action_fallback HafenWeb.FallbackController

  def index(conn, _params) do
    texts = Corpora.list_texts()
    render(conn, "index.json", texts: texts)
  end

  def create(conn, %{"text" => text_params}) do
    with {:ok, %Text{} = text} <- Corpora.create_text(text_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.text_path(conn, :show, text))
      |> render("show.json", text: text)
    end
  end

  def show(conn, %{"id" => id}) do
    text = Corpora.get_text!(id)
    render(conn, "show.json", text: text)
  end

  def update(conn, %{"id" => id, "text" => text_params}) do
    text = Corpora.get_text!(id)

    with {:ok, %Text{} = text} <- Corpora.update_text(text, text_params) do
      render(conn, "show.json", text: text)
    end
  end

  def delete(conn, %{"id" => id}) do
    text = Corpora.get_text!(id)

    with {:ok, %Text{}} <- Corpora.delete_text(text) do
      send_resp(conn, :no_content, "")
    end
  end
end
