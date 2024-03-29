defmodule HafenWeb.Router do
  use HafenWeb, :router

  use Kaffy.Routes, scope: "/admin", pipe_through: []

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

  scope "/", HafenWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/trainer/article", TrainerController, :article_question
    post "/trainer/article", TrainerController, :article_answer
  end

  # Other scopes may use custom stacks.
  scope "/api", HafenWeb do
    pipe_through :api

    resources "/corpora", CorpusController, except: [:new, :edit]
    resources "/corpora/:corpus_id/texts", TextController, except: [:new, :edit]
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: HafenWeb.Telemetry
    end
  end
end
