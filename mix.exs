defmodule Pointers.ULID.MixProject do
  use Mix.Project

  def project do
    [
      app: :pointers_ulid,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: "A maintained ULID datatype for Ecto",
      homepage_url: "https://github.com/commonspub/pointers_ulid",
      source_url: "https://github.com/commonspub/pointers_ulid",
      package: [
        licenses: ["MIT"],
        links: %{
          "Repository" => "https://github.com/commonspub/pointers_ulid",
          "Hexdocs" => "https://hexdocs.pm/pointers_ulid",
        },
      ],
      docs: [
        main: "readme", # The first page to display from the docs 
        extras: ["README.md"], # extra pages to include
      ],
      deps: deps(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.4"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
    ]
  end

end

