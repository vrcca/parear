defmodule PairStairsWeb.ErrorViewTest do
  use PairStairsWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  @tag :integration
  test "renders 404.html" do
    assert render_to_string(PairStairsWeb.ErrorView, "404.html", []) == "Not Found"
  end

  @tag :integration
  test "renders 500.html" do
    assert render_to_string(PairStairsWeb.ErrorView, "500.html", []) == "Internal Server Error"
  end
end
