defmodule UndiOnlineWeb.AdminNavigation do
  @moduledoc """
  Helper components for the navigation in the admin layout
  """
  use UndiOnlineWeb, :html

  defp nav_items do
    [
      %{label: "Admin", icon: :presentation_chart_line, path: ~p"/admin"},
      %{label: "Users", icon: :user, path: ~p"/admin/users"},
      %{label: "Accounts", icon: :users, path: ~p"/admin/accounts"},
      %{label: "Admins", icon: :identification, path: ~p"/admin/admins"},
      %{label: "Developers", icon: :beaker, path: ~p"/admin/developers"},
      ## Insert admin nav items below ##
    ]
  end

  attr :mobile, :boolean, default: false
  def nav(%{mobile: true} = assigns) do
    ~H"""
    <.link :for={%{label: label, icon: icon, path: path} <- nav_items()} href={path} class="flex items-center p-2 text-base font-medium text-base-content text-opacity-80 group rounded-md hover:text-opacity-100">
      <%= apply(Heroicons, icon, [%{__changed__: nil, class: "w-6 h-6 mr-4 text-primary"}]) %>
      <%= label %>
    </.link>
    """
  end

  def nav(assigns) do
    ~H"""
    <.link :for={%{label: label, icon: icon, path: path} <- nav_items()} href={path} data-tooltip={label} class="flex items-center p-2 rounded-lg text-base-content text-opacity-70 hover:text-opacity-100">
      <%= apply(Heroicons, icon, [%{__changed__: nil, class: "h-6 w-6"}]) %>
    </.link>
    """
  end
end
