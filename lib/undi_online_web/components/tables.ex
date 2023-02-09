defmodule UndiOnlineWeb.Components.Tables do
  @moduledoc """
  Dropdown components
  """
  use Phoenix.Component
  import UndiOnlineWeb.CoreComponents, only: [input: 1]

  attr :id, :string, required: true
  attr :path, :any, required: true
  attr :items, :list, required: true
  attr :meta, :any
  attr :row_click, :any, default: nil

  slot :col, required: true do
    attr :label, :string
    attr :field, :atom
  end

  slot :action, doc: "the slot for showing user actions in the last table column"
  def live_table(assigns) do
    assigns
    |> assign(opts: [
      container: true,
      container_attrs: [id: assigns[:id], class: "overflow-x-auto"],
      no_results_content: Phoenix.HTML.Tag.content_tag(:div, "No results.", class: "text-base-content/50 text-3xl font-bold text-center py-12"),
      table_attrs: [class: "table w-full"],
      tbody_tr_attrs: [class: "text-sm"],
    ])
    |> Flop.Phoenix.table()
  end

  attr :meta, :any, required: true
  attr :fields, :list, required: true
  attr :rule, :string, default: "ilike_and"
  def filter_form(assigns) do
    ~H"""
    <.form :let={f} for={@meta} phx-change="update-filter">
      <Flop.Phoenix.filter_fields :let={i} form={f} fields={@fields}>
        <.input
          type="hidden"
          value={@rule}
          field={{i.form, :op}}
        />
        <.input
          id={i.id}
          name={i.name}
          placeholder={"Filter by #{i.label}"}
          type={i.type}
          value={i.value}
          field={{i.form, i.field}}
          {i.rest}
        />
      </Flop.Phoenix.filter_fields>
    </.form>
    """
  end

  attr :path, :any, required: true
  attr :meta, :any, required: true
  def pagination(assigns) do
    assigns = assigns
    |> assign(opts: [
      disabled_class: "cursor-not-allowed no-underline hover:no-underline text-opacity-50",
      next_link_attrs: [class: "btn btn-link"],
      previous_link_attrs: [class: "btn btn-link"],

      pagination_link_attrs: [class: "flex items-center"],
      pagination_list_attrs: [class: "hidden"],
    ])
    ~H"""
    <div :if={@meta.total_count != 0} class="flex flex-col items-center my-4 space-y-4">
      <div class="text-sm text-base-content/80">
        Showing <span class="font-semibold"><%= @meta.current_offset + 1 %></span>
        <span :if={@meta.total_pages != 1}>to <span class="font-semibold"><%= @meta.next_offset || @meta.total_count %></span></span>
        of <span class="font-semibold"><%= @meta.total_count %></span> Entries
      </div>
      <Flop.Phoenix.pagination :if={@meta.total_pages != 1} meta={@meta} path={@path} opts={@opts} />
    </div>
    """
  end
end
