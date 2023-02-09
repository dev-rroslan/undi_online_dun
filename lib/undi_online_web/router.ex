defmodule UndiOnlineWeb.Router do
  use UndiOnlineWeb, :router

  import UndiOnlineWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {UndiOnlineWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug UndiOnlineWeb.Context
  end

  pipeline :admin do
    plug UndiOnline.Admins.Pipeline
  end

  # Set the layout for when an admin signs in
  pipeline :admin_session_layout do
    plug :put_root_layout, {UndiOnlineWeb.Layouts, :session}
  end

  pipeline :require_current_admin do
    plug UndiOnlineWeb.Plugs.RequireCurrentAdmin
  end

  # Set the main layout for the admin area
  pipeline :admin_layout do
    plug :put_root_layout, {UndiOnlineWeb.Layouts, :admin}
  end

  # Set the layout for when a user registers or signs in
  pipeline :session_layout do
    plug :put_root_layout, {UndiOnlineWeb.Layouts, :session}
  end

  scope "/", UndiOnlineWeb do
    pipe_through :browser

    live "/", PageLive, :index
  end

  scope "/api" do
    pipe_through :graphql

    forward "/", Absinthe.Plug, schema: UndiOnlineWeb.Schema
  end

  if Application.compile_env(:ninja_app, :dev_routes) do
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: UndiOnlineWeb.Schema
  end
  # Other scopes may use custom stacks.
  # scope "/api", UndiOnlineWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:undi_online, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: UndiOnlineWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", UndiOnlineWeb do
    pipe_through [:browser, :session_layout, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{UndiOnlineWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", UndiOnlineWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{UndiOnlineWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/accounts", AccountLive.Index, :index
      live "/accounts/:account_id/members", MemberLive.Index, :index
      live "/products", ProductLive.Index, :index
      live "/products/new", ProductLive.Index, :new
      live "/products/:id/edit", ProductLive.Index, :edit

      live "/products/:id", ProductLive.Show, :show
      live "/products/:id/show/edit", ProductLive.Show, :edit
    end
  end

  scope "/", UndiOnlineWeb do
    pipe_through [:browser, :session_layout]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{UndiOnlineWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/admin", UndiOnlineWeb.Admin, as: :admin do
    pipe_through [:browser, :admin, :admin_session_layout]

    get "/sign_in", SessionController, :new
    post "/sign_in", SessionController, :create
    delete "/sign_out", SessionController, :delete
    get "/reset_password", ResetPasswordController, :new
    post "/reset_password", ResetPasswordController, :create
    get "/reset_password/:token", ResetPasswordController, :show
  end

  scope "/admin", UndiOnlineWeb.Admin, as: :admin do
    pipe_through [:browser, :admin, :require_current_admin, :admin_layout]

    live "/", DashboardLive.Index, :index
    live "/settings", SettingLive.Edit, :edit

    post "/impersonate/:id", UserImpersonationController, :create

    live "/accounts", AccountLive.Index, :index
    live "/accounts/new", AccountLive.Index, :new
    live "/accounts/:id/edit", AccountLive.Index, :edit

    live "/accounts/:id", AccountLive.Show, :show
    live "/accounts/:id/show/edit", AccountLive.Show, :edit

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id", UserLive.Show, :show

    live "/admins", AdminLive.Index, :index
    live "/admins/new", AdminLive.Index, :new
    live "/admins/:id/edit", AdminLive.Index, :edit

    live "/admins/:id", AdminLive.Show, :show
    live "/admins/:id/show/edit", AdminLive.Show, :edit

    live "/developers", DeveloperLive.Index, :index
  end
end
