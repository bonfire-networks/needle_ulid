defmodule Needle.ULID do
  @moduledoc "./README.md" |> File.stream!() |> Enum.drop(1) |> Enum.join()
  use Ecto.Type
  require Logger

  @doc "translates alphanumerics into a sentinel ulid value"
  def synthesise!(x) when is_binary(x) do
    x = Regex.replace(~r/[^a-zA-Z0-9]/, x, "")

    cond do
      byte_size(x) > 26 ->
        Logger.warning("Too long, chopping off last #{byte_size(x) - 26} chars")
        synthesise!(String.slice(x, 0, 26))

      byte_size(x) < 26 ->
        Logger.error("Too short, need #{26 - byte_size(x)} chars.")

      true ->
        deform_first(synth(x))
    end
  end

  defp synth(""), do: ""

  defp synth(<<c::bytes-size(1), rest::binary>>),
    do: synth_letter(c) <> synth(rest)

  defp synth_letter("0"), do: "0"
  defp synth_letter("1"), do: "1"
  defp synth_letter("2"), do: "2"
  defp synth_letter("3"), do: "3"
  defp synth_letter("4"), do: "4"
  defp synth_letter("5"), do: "5"
  defp synth_letter("6"), do: "6"
  defp synth_letter("7"), do: "7"
  defp synth_letter("8"), do: "8"
  defp synth_letter("9"), do: "9"
  defp synth_letter("a"), do: "A"
  defp synth_letter("b"), do: "B"
  defp synth_letter("c"), do: "C"
  defp synth_letter("d"), do: "D"
  defp synth_letter("e"), do: "E"
  defp synth_letter("f"), do: "F"
  defp synth_letter("g"), do: "G"
  defp synth_letter("h"), do: "H"
  defp synth_letter("i"), do: "1"
  defp synth_letter("j"), do: "J"
  defp synth_letter("k"), do: "K"
  defp synth_letter("l"), do: "1"
  defp synth_letter("m"), do: "M"
  defp synth_letter("n"), do: "N"
  defp synth_letter("o"), do: "0"
  defp synth_letter("p"), do: "P"
  defp synth_letter("q"), do: "Q"
  defp synth_letter("r"), do: "R"
  defp synth_letter("s"), do: "S"
  defp synth_letter("t"), do: "T"
  defp synth_letter("u"), do: "V"
  defp synth_letter("v"), do: "V"
  defp synth_letter("w"), do: "W"
  defp synth_letter("x"), do: "X"
  defp synth_letter("y"), do: "Y"
  defp synth_letter("z"), do: "Z"
  defp synth_letter("A"), do: "A"
  defp synth_letter("B"), do: "B"
  defp synth_letter("C"), do: "C"
  defp synth_letter("D"), do: "D"
  defp synth_letter("E"), do: "E"
  defp synth_letter("F"), do: "F"
  defp synth_letter("G"), do: "G"
  defp synth_letter("H"), do: "H"
  defp synth_letter("I"), do: "1"
  defp synth_letter("J"), do: "J"
  defp synth_letter("K"), do: "K"
  defp synth_letter("L"), do: "1"
  defp synth_letter("M"), do: "M"
  defp synth_letter("N"), do: "N"
  defp synth_letter("O"), do: "0"
  defp synth_letter("P"), do: "P"
  defp synth_letter("Q"), do: "Q"
  defp synth_letter("R"), do: "R"
  defp synth_letter("S"), do: "S"
  defp synth_letter("T"), do: "T"
  defp synth_letter("U"), do: "V"
  defp synth_letter("V"), do: "V"
  defp synth_letter("W"), do: "W"
  defp synth_letter("X"), do: "X"
  defp synth_letter("Y"), do: "Y"
  defp synth_letter("Z"), do: "Z"
  defp synth_letter(other), do: throw({:bad_letter, other})

  defp deform_first(input = "0" <> _rest), do: input
  defp deform_first(input = "1" <> _rest), do: input
  defp deform_first(input = "2" <> _rest), do: input
  defp deform_first(input = "3" <> _rest), do: input
  defp deform_first(input = "4" <> _rest), do: input
  defp deform_first(input = "5" <> _rest), do: input
  defp deform_first(input = "6" <> _rest), do: input
  defp deform_first(input = "7" <> _rest), do: input

  defp deform_first(<<_::8, rest::binary>>) do
    Logger.warning("First character must be a digit in the range 0-7, replacing with 7")

    "7" <> rest
  end

  @doc "Returns the timestamp portion of the encoded ulid"
  def encoded_timestamp(<<ts::bytes-size(10), _::bytes-size(16)>>), do: ts

  @doc "Returns the randomness portion of the encoded ulid"
  def encoded_randomness(<<_::bytes-size(10), r::bytes-size(16)>>), do: r

  @doc "Returns the timestamp of an encoded or unencoded ULID"
  def timestamp(<<_::bytes-size(26)>> = encoded) do
    with {:ok, decoded} <- decode(encoded), do: {:ok, bintimestamp(decoded)}
  end

  def bintimestamp(<<timestamp::unsigned-size(48), _::binary>>), do: timestamp

  @doc """
  The underlying schema type.
  """
  def type, do: :uuid

  @doc """
  Casts a 26-byte encoded string to ULID or a 16-byte binary unchanged
  """
  def cast(<<_::bytes-size(16)>> = value), do: {:ok, value}

  def cast(<<_::bytes-size(26)>> = value) do
    if valid?(value) do
      {:ok, value}
    else
      :error
    end
  end

  def cast(_), do: :error

  @doc """
  Same as `cast/1` but raises `Ecto.CastError` on invalid arguments.
  """
  def cast!(value) do
    case cast(value) do
      {:ok, ulid} -> ulid
      :error -> raise Ecto.CastError, type: __MODULE__, value: value
    end
  end

  @doc """
  Converts a Crockford Base32 encoded ULID into a binary.
  """
  def dump(<<_::bytes-size(26)>> = encoded), do: decode(encoded)
  def dump(_), do: :error

  def dump!(encoded) do
    case dump(encoded) do
      {:ok, ulid} -> ulid
      _ -> raise Ecto.CastError, type: __MODULE__, value: encoded
    end
  end

  @doc """
  Converts a binary ULID into a Crockford Base32 encoded string.
  """
  def load(<<0::size(16)>>), do: {:ok, "00000000000000000000000000"}

  def load(bytes) when is_binary(bytes) and byte_size(bytes) == 16,
    do: encode(bytes)

  def load(_), do: :error

  # called by ecto when autogenerate is enabled
  @doc false
  def autogenerate, do: generate()

  defp random(), do: :crypto.strong_rand_bytes(10)

  @doc """
  Generates a Crockford Base32 encoded ULID.

  If a value is provided for `timestamp`, the generated ULID will be for the provided timestamp.
  Otherwise, a ULID will be generated for the current time.

  Arguments:

  * `timestamp`: A Unix timestamp with millisecond precision.
  """

  def generate(timestamp \\ System.system_time(:millisecond))
  def generate(%DateTime{} = date), do: DateTime.to_unix(date, :millisecond) |> generate()

  def generate(timestamp) when is_integer(timestamp),
    do: ExULID.ULID.generate(timestamp)

  @doc """
  Generates a binary ULID.

  If a value is provided for `timestamp`, the generated ULID will be for the provided timestamp.
  Otherwise, a ULID will be generated for the current time.

  Arguments:

  * `timestamp`: A Unix timestamp with millisecond precision.
  """
  def bingenerate(timestamp \\ System.system_time(:millisecond))
  def bingenerate(%DateTime{} = date), do: DateTime.to_unix(date, :millisecond) |> bingenerate()

  def bingenerate(timestamp),
    do: <<timestamp::size(48), random()::binary>>

  def encode(bytes, leading_zeroes? \\ true) do
    with {:ok, encoded} <- ExULID.Crockford.encode32(bytes) do
      padded = if leading_zeroes?, do: add_leading_zeroes(encoded), else: encoded

      {:ok, padded}
    end
  end

  defp add_leading_zeroes(bytes) when byte_size(bytes) >= 26, do: bytes
  defp add_leading_zeroes(bytes), do: add_leading_zeroes("0" <> bytes)

  def decode(bytes) do
    case ExULID.ULID.decode(bytes) do
      {:error, _} ->
        :error

      {time, randomness} ->
        {:ok, wat} = ExULID.Crockford.decode32(randomness)
        {:ok, <<time::48, wat::binary>>}
    end
  end

  def valid?(
        <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, c7::8, c8::8, c9::8, c10::8, c11::8, c12::8,
          c13::8, c14::8, c15::8, c16::8, c17::8, c18::8, c19::8, c20::8, c21::8, c22::8, c23::8,
          c24::8, c25::8, c26::8>>
      ) do
    v(c1) && v(c2) && v(c3) && v(c4) && v(c5) && v(c6) && v(c7) && v(c8) &&
      v(c9) && v(c10) && v(c11) && v(c12) && v(c13) &&
      v(c14) && v(c15) && v(c16) && v(c17) && v(c18) && v(c19) && v(c20) &&
      v(c21) && v(c22) && v(c23) && v(c24) && v(c25) && v(c26)
  end

  def valid?(_), do: false

  @compile {:inline, v: 1}

  defp v(?0), do: true
  defp v(?1), do: true
  defp v(?2), do: true
  defp v(?3), do: true
  defp v(?4), do: true
  defp v(?5), do: true
  defp v(?6), do: true
  defp v(?7), do: true
  defp v(?8), do: true
  defp v(?9), do: true
  defp v(?A), do: true
  defp v(?B), do: true
  defp v(?C), do: true
  defp v(?D), do: true
  defp v(?E), do: true
  defp v(?F), do: true
  defp v(?G), do: true
  defp v(?H), do: true
  defp v(?J), do: true
  defp v(?K), do: true
  defp v(?M), do: true
  defp v(?N), do: true
  defp v(?P), do: true
  defp v(?Q), do: true
  defp v(?R), do: true
  defp v(?S), do: true
  defp v(?T), do: true
  defp v(?V), do: true
  defp v(?W), do: true
  defp v(?X), do: true
  defp v(?Y), do: true
  defp v(?Z), do: true
  defp v(_), do: false
end
