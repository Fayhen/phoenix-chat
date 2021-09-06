defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  # Extract the 'id' from the params and assign it to 'room_id'.
  # This 'id' param was defined in the router file.
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    if connected?(socket), do: ChatWeb.Endpoint.subscribe(topic)

    # Assign variables to the socket, making them available in templates.
    {:ok,
    assign(socket,
      room_id: room_id,
      topic: topic,
      message: "",
      messages: [%{uuid: UUID.uuid4(), content: "Anonymous user joined the chat."}],
      temporary_assigns: [messages: []]
    )}
  end

  @impl true
  # The 'chat' form is received via params and message is extracted
  # from its contents
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{uuid: UUID.uuid4(), content: message}
    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    # Clear the form input by resetting the message assigned to its
    # value to an empty string
    {:noreply, assign(socket, message: "")}
  end

  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)
    {:noreply, assign(socket, message: message)}
  end

  # Broadcasted events are handled by the 'handle_info()' function
  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    Logger.info(payload: message)
    # Assign the broadcasted message to the socket's messages array
    # (initially defined in the mount() function)
    {:noreply, assign(socket, messages: [message])}
  end

end
