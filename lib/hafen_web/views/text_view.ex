defmodule HafenWeb.TextView do
  use HafenWeb, :view

  alias HafenWeb.TextView
  alias HafenWeb.CorpusView

  def render("index.json", %{texts: texts}) do
    %{data: render_many(texts, TextView, "text.json")}
  end

  def render("show.json", %{text: text}) do
    %{data: render_one(text, TextView, "text.json")}
  end

  def render("text.json", %{text: text}) do
    %{
      id: text.id,
      title: text.title,
      author: text.author,
      date: text.date,
      raw_text: text.raw_text,
      corpus: CorpusView.render("corpus.json", text)
    }
  end
end
