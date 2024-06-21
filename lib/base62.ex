defmodule Needle.ULID.Base62 do
  @doc """
  Base62 encoder/decoder
  """
  
  @base62_alphabet '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

  for {digit, idx} <- Enum.with_index(@base62_alphabet) do
    def base62_encode(unquote(idx)), do: unquote(<<digit>>)
  end

  def base62_encode(number) do
    base62_encode(div(number, unquote(length(@base62_alphabet)))) <>
      base62_encode(rem(number, unquote(length(@base62_alphabet))))
  end

  def base62_decode(string) do
    string
    |> String.split("", trim: true)
    |> Enum.reverse()
    |> Enum.reduce_while({:ok, {0, 0}}, fn char, {:ok, {acc, step}} ->
      case decode_base62_char(char) do
        {:ok, number} -> {:cont, {:ok, {acc + number * Integer.pow(unquote(length(@base62_alphabet)), step), step + 1}}}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
    |> case do
      {:ok, {number, _step}} -> {:ok, number}
      {:error, error} -> {:error, error}
    end
  end

  for {digit, idx} <- Enum.with_index(@base62_alphabet) do
    defp decode_base62_char(unquote(<<digit>>)), do: {:ok, unquote(idx)}
  end

  defp decode_base62_char(char), do: {:error, "got invalid base62 character; #{inspect char}"}
end