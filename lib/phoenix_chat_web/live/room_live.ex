defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  # Extract the 'id' from the params and assign it to 'room_id'.
  # This 'id' param was defined in the router file.
  def mount(%{"id" => room_id}, _session, socket) do
    # Assign variables to the socket, making them available in templates.
    {:ok, assign(socket, room_id: room_id)}
  end

end
