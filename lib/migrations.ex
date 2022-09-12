if Code.ensure_loaded?(Ecto.Migration) do
  defmodule Pointers.ULID.Migration do
    import Ecto.Migration

    # Based on answers to this SO thread, tweaked.
    # https://stackoverflow.com/questions/49227572/function-minuuid-does-not-exist-in-postgresql

    defp create_agg(op) do
      """
      create or replace aggregate #{op}(uuid) (
        sfunc = #{op}_uuid,
        stype = uuid,
        combinefunc = #{op}_uuid,
        sortop = operator (<),
        parallel = safe
      )
      """
    end

    defp drop_agg(name), do: "drop aggregate if exists #{name}(uuid)"

    @min_uuid """
    create or replace function min_uuid(uuid, uuid)
    returns uuid as $$
    begin
      if $1 is null then return $2; end if;
      if $2 is null then return $1; end if;
      if $2 > $1 then return $1; end if;
      return $2;
    end;
    $$ LANGUAGE plpgsql
    """

    @max_uuid """
    create or replace function max_uuid(uuid, uuid)
    returns uuid as $$
    begin
       if $1 is null then return $2; end if;
       if $2 is null then return $1; end if;
       if $1 > $2 then return $1; end if;
       return $2;
    end;
    $$ LANGUAGE plpgsql
    """

    defp drop_fun(name),
      do: "drop function if exists #{name}(uuid, uuid) cascade"

    defp min_uuid(), do: execute(@min_uuid, drop_fun("min_uuid"))

    defp max_uuid(), do: execute(@max_uuid, drop_fun("max_uuid"))

    defp min(), do: execute(create_agg("min"), drop_agg("min"))

    defp max(), do: execute(create_agg("max"), drop_agg("max"))

    defp functions() do
      min_uuid()
      max_uuid()
    end

    defp aggregates() do
      min()
      max()
    end

    def init_pointers_ulid_extra() do
      init_pointers_ulid_extra(direction())
    end

    def init_pointers_ulid_extra(:up) do
      functions()
      aggregates()
    end

    def init_pointers_ulid_extra(:down) do
      aggregates()
      functions()
    end
  end
end
