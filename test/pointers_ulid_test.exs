defmodule Needle.UlidTest do
  use ExUnit.Case, async: true
  alias Needle.ULID

  @binary <<1, 95, 194, 60, 108, 73, 209, 114, 136, 236, 133, 115, 106, 195, 145, 22>>
  @encoded "01BZ13RV29T5S8HV45EDNC748P"

  # generate/0

  test "generate/1 encodes milliseconds in first 10 characters" do
    # test case from ULID README: https://github.com/ulid/javascript#seed-time
    timestamp = ULID.encoded_timestamp(ULID.generate(1_469_918_176_385))

    assert timestamp == "01ARYZ6S41"
  end

  test "generate/1 encodes a timestamp" do
    {:ok, utc_date, _} = DateTime.from_iso8601("2015-02-10T15:00:00Z")

    timestamp = DateTime.to_unix(utc_date)

    ulid = Needle.ULID.generate(timestamp)

    {:ok, encoded_ts} = Needle.ULID.timestamp(ulid)

    assert encoded_ts == timestamp
  end

  test "generate/0 generates unique identifiers" do
    ulid1 = Needle.ULID.generate()
    ulid2 = Needle.ULID.generate()

    assert ulid1 != ulid2
  end

  # bingenerate/0

  test "bingenerate/0 encodes milliseconds in first 48 bits" do
    now = System.system_time(:millisecond)
    <<time::48, _random::80>> = Needle.ULID.bingenerate()

    assert_in_delta now, time, 10
  end

  test "bingenerate/0 generates unique identifiers" do
    ulid1 = Needle.ULID.bingenerate()
    ulid2 = Needle.ULID.bingenerate()

    assert ulid1 != ulid2
  end

  # cast/1

  test "cast/1 returns valid ULID" do
    {:ok, ulid} = Needle.ULID.cast(@encoded)
    assert ulid == @encoded
  end

  test "cast/1 returns ULID for encoding of correct length" do
    {:ok, ulid} = Needle.ULID.cast("00000000000000000000000000")
    assert ulid == "00000000000000000000000000"
  end

  test "cast/1 returns error when encoding is too short" do
    assert Needle.ULID.cast("0000000000000000000000000") == :error
  end

  test "cast/1 returns error when encoding is too long" do
    assert Needle.ULID.cast("000000000000000000000000000") == :error
  end

  test "cast/1 returns error when encoding contains letter I" do
    assert Needle.ULID.cast("I0000000000000000000000000") == :error
  end

  test "cast/1 returns error when encoding contains letter L" do
    assert Needle.ULID.cast("L0000000000000000000000000") == :error
  end

  test "cast/1 returns error when encoding contains letter O" do
    assert Needle.ULID.cast("O0000000000000000000000000") == :error
  end

  test "cast/1 returns error when encoding contains letter U" do
    assert Needle.ULID.cast("U0000000000000000000000000") == :error
  end

  test "cast/1 returns error for invalid encoding" do
    assert Needle.ULID.cast("$0000000000000000000000000") == :error
  end

  # dump/1

  test "dump/1 dumps valid ULID to binary" do
    {:ok, bytes} = Needle.ULID.dump(@encoded)
    assert bytes == @binary
  end

  test "dump/1 dumps encoding of correct length" do
    {:ok, bytes} = Needle.ULID.dump("00000000000000000000000000")
    assert bytes == <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
  end

  test "dump/1 returns error when encoding is too short" do
    assert Needle.ULID.dump("0000000000000000000000000") == :error
  end

  test "dump/1 returns error when encoding is too long" do
    assert Needle.ULID.dump("000000000000000000000000000") == :error
  end

  test "dump/1 returns error when encoding contains letter I" do
    assert Needle.ULID.dump("I0000000000000000000000000") == :error
  end

  test "dump/1 returns error when encoding contains letter L" do
    assert Needle.ULID.dump("L0000000000000000000000000") == :error
  end

  test "dump/1 returns error when encoding contains letter O" do
    assert Needle.ULID.dump("O0000000000000000000000000") == :error
  end

  test "dump/1 returns error when encoding contains letter U" do
    assert Needle.ULID.dump("U0000000000000000000000000") == :error
  end

  test "dump/1 returns error for invalid encoding" do
    assert Needle.ULID.dump("$0000000000000000000000000") == :error
  end

  # load/1

  test "load/1 encodes binary as ULID" do
    {:ok, encoded} = Needle.ULID.load(@binary)
    assert encoded == @encoded
  end

  test "load/1 encodes binary of correct length" do
    {:ok, encoded} = Needle.ULID.load(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>)

    assert encoded == "00000000000000000000000000"
  end

  test "load/1 returns error when data is too short" do
    assert Needle.ULID.load(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>) ==
             :error
  end

  test "load/1 returns error when data is too long" do
    assert Needle.ULID.load(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>) == :error
  end
end
