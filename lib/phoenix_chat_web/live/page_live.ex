defmodule ChatWeb.PageLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("get-random-room", _params, socket) do
    # Cocatenate a random slug to a slash string
    random_slug = "/" <> MnemonicSlugs.generate_slug(4)
    Logger.info(random_slug)

    # LiveView's push_redirect() redirects to URL with the router
    {:noreply, push_redirect(socket, to: random_slug)}
  end

end
