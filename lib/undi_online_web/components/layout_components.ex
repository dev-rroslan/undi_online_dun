defmodule UndiOnlineWeb.LayoutComponents do
  @moduledoc """
  Provides UI components used in the layouts.
  """
  use UndiOnlineWeb, :verified_routes
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  import UndiOnlineWeb.Components.Dropdowns, only: [dropdown: 1]

  attr :mobile, :boolean, default: false
  attr :current_user, :any
  def user_menu(%{mobile: true} = assigns) do
    ~H"""
    <.link
      :if={!@current_user}
      href={~p"/users/log_in"}
      class={[
        "btn btn-link text-base-content"
      ]}>Log in</.link>

    <.link
      :if={!@current_user}
      href={~p"/users/register"}
      class={[
        "btn btn-primary"
      ]}>Register</.link>

    <.link :if={@current_user} href={~p"/users/settings"} class="w-full btn btn-link text-base-content">Settings</.link>
    <.link :if={@current_user} href={~p"/accounts"} class="w-full btn btn-link text-base-content">Accounts</.link>
    <.link :if={@current_user} href={~p"/users/log_out"} method="delete" class="w-full btn btn-link text-base-content">Log out</.link>
    """
  end

  def user_menu(assigns) do
    ~H"""
    <.link
      :if={!@current_user}
      href={~p"/users/log_in"}
      class={[
        "btn btn-link text-base-content"
      ]}>Log in</.link>

    <.link
      :if={!@current_user}
      href={~p"/users/register"}
      class={[
        "btn btn-primary"
      ]}>Register</.link>

    <.dropdown :if={@current_user} id={"user-menu#{if @mobile, do: "-mobile"}"}>
      <:toggle class="px-2 btn btn-secondary">
        <Heroicons.user_circle solid class="w-8 h-8" />
      </:toggle>
      <:menu align="right">
        <li><.link href={~p"/users/settings"}>Settings</.link></li>
        <li><.link href={~p"/accounts"}>Accounts</.link></li>
        <li><.link href={~p"/users/log_out"} method="delete">Log out</.link></li>
      </:menu>
    </.dropdown>
    """
  end

  attr :id, :string, default: "drawer"
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :on_confirm, JS, default: %JS{}
  slot :inner_block, required: true
  def drawer(assigns) do
    ~H"""
    <div id={@id} phx-mounted={@show && show_drawer(@id)} class="relative z-40 lg:hidden" role="dialog" style="display: none" aria-modal="true">
      <div id={"#{@id}-bg"} class="fixed inset-0 bg-neutral-focus bg-opacity-30"></div>

      <div class="fixed inset-0 z-40 flex">
        <.focus_wrap
          id={"#{@id}-menu"}
          phx-mounted={@show && show_drawer(@id)}
          phx-window-keydown={hide_drawer(@on_cancel, @id)}
          phx-key="escape"
          phx-click-away={hide_drawer(@on_cancel, @id)}
          class="relative flex flex-col flex-1 w-full max-w-xs shadow-lg bg-base-100 focus:outline-none"
        >
          <div id={"#{@id}-close"} class="absolute top-0 right-0 pt-4 -mr-12">
            <button type="button" phx-click={hide_drawer(@on_cancel, @id)} class="flex items-center justify-center w-10 h-10 ml-1 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-base-100">
              <span class="sr-only">Close sidebar</span>
              <Heroicons.x_mark class="w-6 h-6 base-content text-opacity-50" />
            </button>
          </div>

          <%= render_slot(@inner_block) %>
        </.focus_wrap>

        <div class="flex-shrink-0 w-14" aria-hidden="true">
          <!-- Force sidebar to shrink to fit close icon -->
        </div>
      </div>
    </div>
    """
  end

  ## JS Commands

  def show_drawer(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> JS.show(
      to: "##{id}-menu",
      transition: {
        "transition-all transform ease-in-out duration-300",
        "-translate-x-full",
        "translate-x-0"
      }
    )
    |> JS.show(
      to: "##{id}-close",
      transition: {"ease-in-out duration-300", "opacity-0", "opacity-100"}
    )
    |> JS.focus_first(to: "##{id}-menu")
  end

  def hide_drawer(js \\ %JS{}, id) do
    js
    |> JS.show(
      to: "##{id}-close",
      transition: {"ease-in-out duration-300", "opacity-100", "opacity-0"}
    )
    |> JS.hide(
      to: "##{id}-menu",
      transition: {
        "transition ease-in-out duration-300 transform",
        "translate-x-0",
        "-translate-x-full"
      }
    )
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.pop_focus()
  end
end
