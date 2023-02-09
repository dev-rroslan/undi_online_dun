defmodule UndiOnlineWeb.Live.Admin.LiveHelpers do
  @moduledoc """
  A collection of helpers and components for the admin live pages
  """
  use Phoenix.Component

  def human_date(datetime), do: human_date(datetime, "%x")
  def human_date(nil, _), do: nil
  def human_date(datetime, format), do: Calendar.strftime datetime, format

  def admin_page_heading(assigns) do
    ~H"""
    <div class="mb-8">
      <h1 class="font-sans text-3xl text-base-content text-opacity-80 leading-10 md:text-3xl">
        <%= @title %>
      </h1>

      <div class="flex items-center justify-between">
        <nav class="mt-4 text-sm breadcrumbs">
          <ul>
            <%= for link <- @link do %>
            <li>
              <%= render_slot(link) %>
            </li>
            <% end %>
          </ul>
        </nav>
        <div>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end
end
