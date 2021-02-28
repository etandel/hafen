defmodule Hafen.Corpora do
  @moduledoc """
  The Corpora context.
  """

  import Ecto.Query, warn: false
  alias Hafen.Repo

  alias Hafen.Corpora.Corpus

  @doc """
  Returns the list of corpora.

  ## Examples

      iex> list_corpora()
      [%Corpus{}, ...]

  """
  def list_corpora do
    Repo.all(Corpus)
  end

  @doc """
  Gets a single corpus.

  Raises `Ecto.NoResultsError` if the Corpus does not exist.

  ## Examples

      iex> get_corpus!(123)
      %Corpus{}

      iex> get_corpus!(456)
      ** (Ecto.NoResultsError)

  """
  def get_corpus!(id), do: Repo.get!(Corpus, id)

  @doc """
  Creates a corpus.

  ## Examples

      iex> create_corpus(%{field: value})
      {:ok, %Corpus{}}

      iex> create_corpus(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_corpus(attrs \\ %{}) do
    %Corpus{}
    |> Corpus.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a corpus.

  ## Examples

      iex> update_corpus(corpus, %{field: new_value})
      {:ok, %Corpus{}}

      iex> update_corpus(corpus, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_corpus(%Corpus{} = corpus, attrs) do
    corpus
    |> Corpus.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a corpus.

  ## Examples

      iex> delete_corpus(corpus)
      {:ok, %Corpus{}}

      iex> delete_corpus(corpus)
      {:error, %Ecto.Changeset{}}

  """
  def delete_corpus(%Corpus{} = corpus) do
    Repo.delete(corpus)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking corpus changes.

  ## Examples

      iex> change_corpus(corpus)
      %Ecto.Changeset{data: %Corpus{}}

  """
  def change_corpus(%Corpus{} = corpus, attrs \\ %{}) do
    Corpus.changeset(corpus, attrs)
  end
end
