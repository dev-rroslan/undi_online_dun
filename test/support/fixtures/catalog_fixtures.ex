defmodule UndiOnline.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UndiOnline.Catalog` context.
  """

  @doc """
  Generate a unique product name.
  """
  def unique_product_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: unique_product_name()
      })
      |> UndiOnline.Catalog.create_product()

    product
  end
end
