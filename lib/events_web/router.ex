defmodule EventsWeb.Router do
  use EventsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug EventsWeb.Plugs.FetchSession
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EventsWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/events", EventController

    resources "/users", UserController
    get "/users/:id/photo", UserController, :photo

    # Event participants are a bit different,
    # so we handle them by hand
    scope "/events/:eventId/participants" do
      get "/edit/:email", EventParticipantController, :edit
      get "/new", EventParticipantController, :new
      post "/", EventParticipantController, :create
      patch "/:email", EventParticipantController, :update
      put "/:email", EventParticipantController, :update
      delete "/:email", EventParticipantController, :delete

      # Routes for looking up invites
      get "/", EventParticipantController, :lookup
      post "/search", EventParticipantController, :search
    end

    resources "/session", SessionController,
      only: [:create, :delete], singleton: true

  end

  # Other scopes may use custom stacks.
  # scope "/api", EventsWeb do
  #   pipe_through :api
  # end

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
      live_dashboard "/dashboard", metrics: EventsWeb.Telemetry
    end
  end
end
