defmodule UndiOnlineWeb.Admin.UserLiveTest do
  use UndiOnlineWeb.ConnCase

  import Phoenix.LiveViewTest
  import UndiOnline.UsersFixtures

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  setup :register_and_log_in_admin

  describe "Index" do
    setup [:create_user]

    test "lists all users", %{conn: conn, user: user} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/users")

      assert html =~ "Listing Users"
      assert html =~ user.email
    end

    test "saves new user", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/users")

      assert index_live |> element("a[href=\"/admin/users/new\"]") |> render_click() =~
               "New User"

      assert_patch(index_live, ~p"/admin/users/new")

      assert index_live
             |> form("#user-form", user: %{email: nil})
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#user-form", user: %{email: "valid-email@example.com"})
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/users")

      assert html =~ "User created successfully"
      assert html =~ "valid-email@example.com"
    end
  end

  describe "Show" do
    setup [:create_user]

    test "displays user", %{conn: conn, user: user} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/users/#{user}")

      assert html =~ "Show User"
      assert html =~ user.email
    end
  end
end
