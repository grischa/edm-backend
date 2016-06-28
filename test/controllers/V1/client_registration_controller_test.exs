defmodule EdmBackend.ClientRegistrationControllerTest do
  use EdmBackend.ConnCase, async: true

  test "GET /api/v1/client", %{conn: conn} do
    conn = get conn, "/api/v1/client"
    assert html_response(conn, 401) =~ ""
  end
end
