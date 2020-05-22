defmodule PointerUlid.MixProject do
  use Mix.Project

  def project do
    [
      app: :pointer_ulid,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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

