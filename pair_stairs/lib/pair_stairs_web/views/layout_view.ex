defmodule PairStairsWeb.LayoutView do
  use PairStairsWeb, :view

  def new_stairs_button(conn) do
    top_page_button(conn, conn.params)
  end

  defp top_page_button(conn, %{"id" => id}) do
    top_page_button(conn, %{"stairs_id" => id})
  end

  defp top_page_button(conn, %{"stairs_id" => stairs_id}) do
    link(gettext("Preferences"), to: Routes.stairs_participant_path(conn, :index, stairs_id))
  end

  defp top_page_button(conn, _params) do
    link(gettext("New"), to: Routes.stairs_path(conn, :new))
  end
end
