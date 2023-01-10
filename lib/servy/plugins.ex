defmodule Servy.Plugins do
  @moduledoc """
  Helper plugins.
  """

  alias Servy.Conv

  @doc """
  Rewrite path plugin.
  """
  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  @doc """
  Logs the conversation (parsed request).
  """
  def log(%Conv{} = conv) do
    if Mix.env == :dev do
      IO.inspect(conv)
    end
    conv
  end

  @doc """
  Log the specified status code errors.
  """
  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env !== :test do
      IO.puts("Warning, #{path} is on the loose")
    end
    conv
  end

  def track(%Conv{} = conv), do: conv
end
