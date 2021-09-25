defmodule Hafen.Corpora.Sentence do
  @moduledoc """
  Sentence entity
  """

  alias Hafen.Corpora.Text

  @enforce_keys [:text, :id, :value]
  defstruct [:text, :id, :value]

  @type t() :: %__MODULE__{
          text: %Text{},
          id: integer(),
          value: String.t()
        }

  @splitter_regex ~r/(?<punc>\.|\?|!)(\s|$)/

  def punctuation_only?(s) do
    s == "." or s == "?" or s == "!"
  end

  @spec split(%Text{}) :: list(t())
  def split(%Text{raw_text: raw_text} = text) do
    raw_text
    |> split()
    |> Stream.with_index()
    |> Stream.map(fn {s, id} -> %__MODULE__{text: text, id: id, value: s} end)
    |> Enum.to_list()
  end

  @spec split(String.t()) :: list(String.t())
  def split(raw_text) when is_bitstring(raw_text) do
    splitted =
      Regex.split(@splitter_regex, raw_text, include_captures: true, trim: true, on: [:punc])

    stream =
      if splitted |> Enum.at(0) |> punctuation_only?() do
        Enum.slice(splitted, 1..-1)
      else
        splitted
      end

    stream
    |> Stream.chunk_every(2)
    |> Stream.map(&Enum.join/1)
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(not punctuation_only?(&1)))
    |> Enum.to_list()
  end
end
