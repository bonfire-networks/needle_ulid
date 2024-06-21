defmodule Needle.ULID.Base62.UUID do
  @doc """
  UUID Base62 encoder/decoder
  """
  
  @base62_uuid_length 22
  @uuid_length 32

  def encode_base62_uuid(uuid) do
    uuid
    |> String.replace("-", "")
    |> String.to_integer(16)
    |> Needle.ULID.Base62.base62_encode()
    |> String.pad_leading(@base62_uuid_length, "0")
  end

  def decode_base62_uuid(string) do
    with {:ok, number} <- Needle.ULID.Base62.base62_decode(string) do
      number_to_uuid(number)
    end
  end

  def number_to_uuid(number) do
    number
    |> Integer.to_string(16)
    |> String.downcase()
    |> String.pad_leading(@uuid_length, "0")
    |> case do
      <<g1::binary-size(8), g2::binary-size(4), g3::binary-size(4), g4::binary-size(4), g5::binary-size(12)>> ->
        {:ok, "#{g1}-#{g2}-#{g3}-#{g4}-#{g5}"}

      other ->
        {:error, "got invalid base62 uuid; #{inspect other}"}
    end
  end
end