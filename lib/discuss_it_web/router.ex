defmodule DiscussItWeb.Router do
  use DiscussItWeb, :router

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

  scope "/", DiscussItWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/about", PageController, :about
  end

  # Other scopes may use custom stacks.
  scope "/api", DiscussItWeb do
    pipe_through :api

    get "/",       ApiController, :index
    get "/submit", ApiController, :submit
  end
end
