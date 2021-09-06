defmodule ChatWeb.PageLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("get-random-room", _params, socket) do
    Logger.info("Event fired: 'get-random-room'")
    {:noreply, socket}
  end

end
