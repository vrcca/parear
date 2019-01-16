defmodule PairStairsWeb.LayoutView do
  use PairStairsWeb, :view

  def new_stairs_button(conn) do
    link("New", to: Routes.stairs_path(conn, :new))
  end
end
