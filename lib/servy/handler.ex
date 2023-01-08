defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests.
  """

  alias Servy.Conv

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  @doc """
  Transforms the request into the response.
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %Conv{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    %Conv{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    %Conv{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.htm")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    %Conv{conv | status: 201, resp_body: "Create a #{conv.params["type"]} bear named #{conv.params["name"]}"}
  end

  def route(%Conv{path: path} = conv) do
    %Conv{conv | status: 404, resp_body: "The #{path} is not exists"}
  end

  def handle_file({:ok, content}, %Conv{} = conv) do
    %Conv{conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, %Conv{} = conv) do
    %Conv{conv | status: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, %Conv{} = conv) do
    %Conv{conv | status: 500, resp_body: "File error: #{reason}"}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 Conv.full_status(conv)
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

#
# /wildthings
#
request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

#
# /bears
#
request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

#
# /bears/1
#
request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

#
# /undefined
#
request = """
GET /undefined HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

#
# POST
#
request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request)
IO.puts(response)