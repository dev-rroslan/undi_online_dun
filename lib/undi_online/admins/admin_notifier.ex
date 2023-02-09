defmodule UndiOnline.Admins.AdminNotifier do
  @moduledoc """
  This module contains notifications aimed towards the admins.
  """
  use Phoenix.Swoosh, view: UndiOnlineWeb.Emails, layout: {UndiOnlineWeb.Emails, :layout}

  import Swoosh.Email
  import UndiOnline.Mailer, only: [base_email: 0, premail: 1]

  @doc """
  This email is used when an admin needs to login with a magic link
  """
  def admin_login_link(%{email: email, url: url}) do
    base_email()
    |> subject("Login token")
    |> to(email)
    |> render_body("admin_login_link.html", title: "Login token", url: url)
    |> premail()
  end
end
