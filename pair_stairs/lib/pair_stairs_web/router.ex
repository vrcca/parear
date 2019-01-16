defmodule PairStairsWeb.Router do
  use PairStairsWeb, :router

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

  scope "/", PairStairsWeb do
    pipe_through :browser

    get "/", PageController, :index

    scope "/stairs" do
      get "/", StairsController, :new
      post "/", StairsController, :create
      get "/:id", StairsController, :show
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", PairStairsWeb do
  #   pipe_through :api
  # end
end
