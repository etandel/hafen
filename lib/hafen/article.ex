defmodule Hafen.Article do
  @moduledoc """
  Article helpers
  """

  @articles_regex ~r/\b(der|das|die|den|dem|des)\b/i

  def articles() do
    String.split("der das die den dem des")
  end

  def split_on_articles(sentence) do
    String.split(sentence, @articles_regex)
  end
end
