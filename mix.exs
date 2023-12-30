defmodule Needle.ULID.MixProject do
  use Mix.Project

  def project do
    [
      app: :needle_ulid,
      version: "0.3.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: "Provides an ULID datatype for Ecto (using ex_ulid) and related helpers",
      homepage_url: "https://github.com/bonfire-networks/needle_ulid",
      source_url: "https://github.com/bonfire-networks/needle_ulid",
      package: [
        licenses: ["MIT"],
        links: %{
          "Repository" => "https://github.com/bonfire-networks/needle_ulid",
          "Hexdocs" => "https://hexdocs.pm/needle_ulid"
        }
      ],
      docs: [
        # The first page to display from the docs
        main: "readme",
        # extra pages to include
        extras: ["README.md"]
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  defp deps do
    [
      {:ecto, "~> 3.4"},
      # you might just want it for in-memory use
      {:ecto_sql, "~> 3.8", optional: true},
      # let someone else worry about it.
      {:ex_ulid, "~> 0.1"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end
