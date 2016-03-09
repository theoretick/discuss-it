defmodule DiscussIt.Router do
  use DiscussIt.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DiscussIt do
    pipe_through :browser # Use the default browser stack

    get "/",       PageController, :index
    get "/about",  PageController, :about
    get "/submit", PageController, :submit
  end

  # Other scopes may use custom stacks.
  # scope "/api", DiscussIt do
  #   pipe_through :api
  # end
end
