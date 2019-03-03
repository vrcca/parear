defmodule PairStairsWeb.LayoutView do
  use PairStairsWeb, :view

  def new_stairs_button(conn) do
    top_page_button(conn, conn.params)
  end

  def display_stairs_class(conn, view_module) do
    function_exported?(view_module, :display_stairs_class, 1)
    |> case do
      true -> apply(view_module, :display_stairs_class, [conn])
      _ -> ""
    end
  end

  defp top_page_button(conn, %{"id" => id}) do
    top_page_button(conn, %{"stairs_id" => id})
  end

  defp top_page_button(conn, %{"stairs_id" => stairs_id}) do
    link(gettext("Preferences"), to: Routes.stairs_preferences_path(conn, :index, stairs_id))
  end

  defp top_page_button(conn, _params) do
    link(gettext("New"), to: Routes.stairs_path(conn, :new))
  end
end
