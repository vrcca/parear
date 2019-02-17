defmodule PairStairsWeb.PageView do
  use PairStairsWeb, :view

  def link_to_stairs(conn, stairs) do
    link(stairs.name, to: Routes.stairs_path(conn, :show, stairs.id))
  end

  def create_stairs_button(conn) do
    link(gettext("Create Stairs"),
      to: Routes.stairs_path(conn, :new),
      class: "button"
    )
  end
end
