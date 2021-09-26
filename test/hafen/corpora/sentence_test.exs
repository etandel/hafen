defmodule Hafen.Corpora.SentenceTest do
  use ExUnit.Case

  alias Hafen.Corpora.Sentence
  alias Hafen.Corpora.Text

  defp assert_split_with_string(raw_text, expected_splitted) do
    assert Sentence.split(raw_text) == expected_splitted
  end

  defp assert_split_with_text(raw_text, expected_splitted) do
    text = %Text{raw_text: raw_text}
    got = Sentence.split(text)

    expected =
      expected_splitted
      |> Stream.with_index()
      |> Enum.map(fn {s, id} -> %Sentence{text: text, id: id, value: s} end)

    assert got == expected
  end

  describe "split/1 with raw_text" do
    setup do
      %{split_asserters: [&assert_split_with_string/2, &assert_split_with_text/2]}
    end

    test "with raw string returns empty list", context do
      for asserter <- context.split_asserters do
        asserter.("", [])
      end
    end

    test "with punctuation inn the beginning returns empty list", context do
      for asserter <- context.split_asserters do
        asserter.(".", [])
        asserter.("?", [])
        asserter.("!", [])
      end
    end

    test "with one sentence without punctuation returns the sentence without punctuation",
         context do
      for asserter <- context.split_asserters do
        asserter.("foo bar", ["foo bar"])
        asserter.(" foo bar ", ["foo bar"])
      end
    end

    test "with one sentence with punctuation returns the sentence with punctuation", context do
      for asserter <- context.split_asserters do
        asserter.("foo bar.", ["foo bar."])
        asserter.(" foo bar .", ["foo bar ."])

        asserter.("foo bar.", ["foo bar."])
        asserter.(" foo bar .", ["foo bar ."])

        asserter.("foo bar?", ["foo bar?"])
        asserter.(" foo bar ?", ["foo bar ?"])
      end
    end

    test "with two sentences returns ok", context do
      for asserter <- context.split_asserters do
        asserter.("foo bar. boo baz", ["foo bar.", "boo baz"])
        asserter.(" foo bar . boo baz", ["foo bar .", "boo baz"])
        asserter.(" foo bar . boo baz.", ["foo bar .", "boo baz."])
      end
    end

    test "does not split dates", context do
      for asserter <- context.split_asserters do
        asserter.("10.02.2020", ["10.02.2020"])
      end
    end

    test "does not split acronyms", context do
      for asserter <- context.split_asserters do
        asserter.("foo z.B bar", ["foo z.B bar"])
      end
    end

    test "tnc", context do
      s = ". die. ich liebe dich."

      for asserter <- context.split_asserters do
        asserter.(s, ["die.", "ich liebe dich."])
      end
    end
  end

  describe "punctuation_only?/1" do
    test "ok" do
      assert Sentence.punctuation_only?(".")
      assert Sentence.punctuation_only?("?")
      assert Sentence.punctuation_only?("!")

      assert not Sentence.punctuation_only?(" .")
      assert not Sentence.punctuation_only?(" ?")
      assert not Sentence.punctuation_only?(" !")

      assert not Sentence.punctuation_only?(". ")
      assert not Sentence.punctuation_only?("? ")
      assert not Sentence.punctuation_only?("! ")

      assert not Sentence.punctuation_only?("foo.")
      assert not Sentence.punctuation_only?("foo?")
      assert not Sentence.punctuation_only?("foo!")
    end
  end
end
