defmodule UndiOnlineWeb.Admin.AdminLive.Index do
  @moduledoc """
  The admin admins index page.
  """
  use UndiOnlineWeb, :live_view

  import UndiOnlineWeb.Live.Admin.LiveHelpers
  import UndiOnlineWeb.Components.Cards, only: [card: 1]

  alias UndiOnline.Admins
  alias UndiOnline.Admins.Admin

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {
      :noreply,
      socket
      |> assign(:params, params)
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Admin")
    |> assign(:admin, Admins.get_admin!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Admin")
    |> assign(:admin, %Admin{})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Admins")
    |> assign(:admin, nil)
    |> assign_admins(params)
    |> assign(:params, params)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    admin = Admins.get_admin!(id)
    {:ok, _} = Admins.delete_admin(admin)

    {:noreply, assign_admins(socket, socket.assigns.params)}
  end

  defp assign_admins(socket, params) do
    case Admins.paginate_admins(params) do
      {:ok, {admins, meta}} ->
        assign(socket, %{admins: admins, meta: meta})
      _ ->
        push_navigate(socket, to: ~p"/admin/admins")
    end
  end
end
