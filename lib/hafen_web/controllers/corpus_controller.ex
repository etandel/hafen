defmodule HafenWeb.CorpusController do
  use HafenWeb, :controller

  alias Hafen.Corpora
  alias Hafen.Corpora.Corpus

  action_fallback HafenWeb.FallbackController

  def index(conn, _params) do
    corpora = Corpora.list_corpora()
    render(conn, "index.json", corpora: corpora)
  end

  def create(conn, %{"corpus" => corpus_params}) do
    with {:ok, %Corpus{} = corpus} <- Corpora.create_corpus(corpus_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.corpus_path(conn, :show, corpus))
      |> render("show.json", corpus: corpus)
    end
  end

  def show(conn, %{"id" => id}) do
    corpus = Corpora.get_corpus!(id)
    render(conn, "show.json", corpus: corpus)
  end

  def update(conn, %{"id" => id, "corpus" => corpus_params}) do
    corpus = Corpora.get_corpus!(id)

    with {:ok, %Corpus{} = corpus} <- Corpora.update_corpus(corpus, corpus_params) do
      render(conn, "show.json", corpus: corpus)
    end
  end

  def delete(conn, %{"id" => id}) do
    corpus = Corpora.get_corpus!(id)

    with {:ok, %Corpus{}} <- Corpora.delete_corpus(corpus) do
      send_resp(conn, :no_content, "")
    end
  end
end
