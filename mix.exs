defmodule Pointers.ULID.MixProject do
  use Mix.Project

  def project do
    [
      app: :pointers_ulid,
      version: "0.2.2",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: "A maintained ULID datatype for Ecto",
      homepage_url: "https://github.com/bonfire-networks/pointers_ulid",
      source_url: "https://github.com/bonfire-networks/pointers_ulid",
      package: [
        licenses: ["MIT"],
        links: %{
          "Repository" => "https://github.com/bonfire-networks/pointers_ulid",
          "Hexdocs" => "https://hexdocs.pm/pointers_ulid"
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
