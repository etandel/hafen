defmodule HafenWeb.CorpusView do
  use HafenWeb, :view
  alias HafenWeb.CorpusView

  def render("index.json", %{corpora: corpora}) do
    %{data: render_many(corpora, CorpusView, "corpus.json")}
  end

  def render("show.json", %{corpus: corpus}) do
    %{data: render_one(corpus, CorpusView, "corpus.json")}
  end

  def render("corpus.json", %{corpus: corpus}) do
    %{id: corpus.id,
      reference: corpus.reference}
  end
end
