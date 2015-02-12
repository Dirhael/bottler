defmodule Bottler.Mixfile do
  use Mix.Project

  def project do
    [app: :bottler,
     version: "0.4.0",
     elixir: "~> 1.0.0",
     package: package,
     description: """
        Bottler is a collection of tools that aims to help you
        generate releases, ship them to your servers, install them there, and
        get them live on production.
      """,
     deps: deps]
  end

  def application do
    [ applications: [:logger, :crypto],
      included_applications: [:public_key, :asn1] ]
  end

  defp package do
    [contributors: ["Rubén Caro"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/elpulgardelpanda/bottler"}]
  end

  defp deps do
    [{:sshex, "1.0.0"}]
  end
end
