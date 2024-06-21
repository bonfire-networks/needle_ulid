defmodule Needle.ULID.PrefixedUUID do
  @doc """
  Generates prefixed base62 encoded UUIDv7.
  Based on https://danschultzer.com/posts/prefixed-base62-uuidv7-object-ids-with-ecto

  ## Examples

      @primary_key {:id, Needle.ULID.PrefixedUUID, prefix: "acct", autogenerate: true}
      @foreign_key_type Needle.ULID.PrefixedUUID
  """
  use Ecto.ParameterizedType

  @impl true
  @doc "Callback to convert the options specified in the field macro into parameters to be used in other callbacks.
  This function is called at compile time, and should raise if invalid values are specified. It is idiomatic that the parameters returned from this are a map. field and schema will be injected into the options automatically."
  def init(opts) do
    schema = Keyword.fetch!(opts, :schema)
    field = Keyword.fetch!(opts, :field)
    uniq = Uniq.UUID.init(schema: schema, field: field, version: 7, default: :raw, dump: :raw)

    case opts[:primary_key] do
      true ->
        prefix = Keyword.get(opts, :prefix) || raise "`:prefix` option is required"

        %{
          primary_key: true,
          schema: schema,
          prefix: prefix,
          uniq: uniq
        }

      _any ->
        %{
          schema: schema,
          field: field,
          uniq: uniq
        }
    end
  end

  @impl true
  def type(_params), do: :uuid

  @impl true
  @doc "Casts the given input to the ParameterizedType with the given parameters."
  def cast(nil, _params), do: {:ok, nil}

  def cast(data, params) do
    with {:ok, prefix, _uuid} <- slug_to_uuid(data, params),
         {prefix, prefix} <- {prefix, prefix(params)} do
      {:ok, data}
    else
      _ -> :error
    end
  end

  defp slug_to_uuid(string, _params) do
    with [prefix, slug] <- String.split(string, "_"),
         {:ok, uuid} <- Needle.ULID.Base62.UUID.decode_base62_uuid(slug) do
      {:ok, prefix, uuid}
    else
      _ -> :error
    end
  end

  defp prefix(%{primary_key: true, prefix: prefix}), do: prefix

  # If we deal with a belongs_to assocation we need to fetch the prefix from
  # the associations schema module
  defp prefix(%{schema: schema, field: field}) do
    %{related: schema, related_key: field} = schema.__schema__(:association, field)
    {:parameterized, __MODULE__, %{prefix: prefix}} = schema.__schema__(:type, field)

    prefix
  end

  @impl true
  @doc "Loads the given term into a ParameterizedType.
  It receives a loader function in case the parameterized type is also a composite type. In order to load the inner type, the loader must be called with the inner type and the inner value as argument."
  def load(data, loader, params) do
    case Uniq.UUID.load(data, loader, params.uniq) do
      {:ok, nil} -> {:ok, nil}
      {:ok, uuid} -> {:ok, uuid_to_slug(uuid, params)}
      :error -> :error
    end
  end

  defp uuid_to_slug(uuid, params) do
    "#{prefix(params)}_#{Needle.ULID.Base62.UUID.encode_base62_uuid(uuid)}"
  end

  @impl true
  @doc "Dumps the given term into an Ecto native type.
  It receives a dumper function in case the parameterized type is also a composite type. In order to dump the inner type, the dumper must be called with the inner type and the inner value as argument."
  def dump(nil, _, _), do: {:ok, nil}

  def dump(slug, dumper, params) do
    case slug_to_uuid(slug, params) do
      {:ok, _prefix, uuid} -> Uniq.UUID.dump(uuid, dumper, params.uniq)
      :error -> :error
    end
  end

  @impl true
  @doc "Generates a loaded version of the data."
  def autogenerate(params) do
    uuid_to_slug(Uniq.UUID.autogenerate(params.uniq), params)
  end

  @impl true
  def embed_as(format, params), do: Uniq.UUID.embed_as(format, params.uniq)

  @impl true
  def equal?(a, b, params), do: Uniq.UUID.equal?(a, b, params.uniq)


end