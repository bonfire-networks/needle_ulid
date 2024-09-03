if Code.ensure_loaded?(Uniq.UUID) do
defmodule Needle.ULID.ULIDSchemaTest do
  use ExUnit.Case, async: true

  alias Needle.ULID
  alias Uniq.UUID

  defmodule TestSchema do
    use Ecto.Schema

    @primary_key {:id, Needle.ULID, autogenerate: true} 
    @foreign_key_type Needle.ULID

    schema "test" do
      belongs_to :test, TestSchema
    end
  end

  @test_ulid "3J6ASQVZ0K8K08W6WTB83Y4J91"
  @test_uuid UUID.to_string("7232b37d-fc13-44c0-8e1b-9a5a07e24921", :raw)
  @test_ulid_with_leading_zero "3J6ASQVZ0K8K08W6WTB83Y4J91"
  @test_ulid_null "00000000000000000000000000"
  @test_uuid_null UUID.to_string("00000000-0000-0000-0000-000000000000", :raw)
  @test_ulid_invalid_characters String.duplicate(".", 32)
  @test_uuid_invalid_characters String.duplicate(".", 22)
  @test_ulid_invalid_format String.duplicate("x", 31)
  @test_uuid_invalid_format String.duplicate("x", 21)

  test "cast/2" do
    assert ULID.cast(@test_ulid) == {:ok, @test_ulid}
    assert ULID.cast(@test_ulid_null) == {:ok, @test_ulid_null}
    # assert ULID.cast(nil) == {:ok, nil}
    assert ULID.cast("someprefix" <> @test_ulid) == :error
    assert ULID.cast(@test_ulid_invalid_characters) == :error
    assert ULID.cast(@test_ulid_invalid_format) == :error
    assert ULID.cast(@test_ulid) == {:ok, @test_ulid}
  end

  test "load/3" do
    assert ULID.load(@test_uuid) == {:ok, @test_ulid}
    assert ULID.load(@test_uuid_null) == {:ok, @test_ulid_null}
    assert ULID.load(@test_uuid_invalid_characters) == :error
    assert ULID.load(@test_uuid_invalid_format) == :error
    assert ULID.load(@test_ulid) == :error
    # assert ULID.load(nil) == {:ok, nil}
    assert ULID.load(@test_uuid) == {:ok, @test_ulid}
  end

  test "dump/3" do
    assert ULID.dump(@test_ulid) == {:ok, @test_uuid}
    assert ULID.dump(@test_ulid_null) == {:ok, @test_uuid_null}
    assert ULID.dump(@test_uuid) == :error
    # assert ULID.dump(nil) == {:ok, nil}
    assert ULID.dump(@test_ulid) == {:ok, @test_uuid}
  end

end
end