defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  # Extract the 'id' from the params and assign it to 'room_id'.
  # This 'id' param was defined in the router file.
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(2)
    if connected?(socket) do
      ChatWeb.Endpoint.subscribe(topic)
      ChatWeb.Presence.track(self(), topic, username, %{})
    end

    # Assign variables to the socket, making them available in templates.
    {:ok,
    assign(socket,
      room_id: room_id,
      topic: topic,
      username: username,
      message: "",
      messages: [],
      active_users: [],
      temporary_assigns: [messages: []]
    )}
  end

  @impl true
  # The 'chat' form is received via params and message is extracted
  # from its contents
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{uuid: UUID.uuid4(), content: message, username: socket.assigns.username}
    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)

    # Clear the form input by resetting the message assigned to its
    # value to an empty string
    {:noreply, assign(socket, message: "")}
  end

  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  # Broadcasted events are handled by the 'handle_info()' function
  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    # Assign the broadcasted message to the socket's messages array
    # (initially defined in the mount() function)
    {:noreply, assign(socket, messages: [message])}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    # Generate 'user has joined' message
    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system,
          uuid: UUID.uuid4(),
          content: "#{username} has joined the chat!"
        } end)

    # Generate 'user has left' message
    leave_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system,
          uuid: UUID.uuid4(),
          content: "#{username} has left the chat!"
        } end)

    # Generate list of active users
    active_users = ChatWeb.Presence.list(socket.assigns.topic)
        |> Map.keys()

    {:noreply, assign(socket, messages: join_messages ++ leave_messages, active_users: active_users )}
  end

  def display_message(%{type: :system, uuid: uuid, content: content}) do
    ~E"""
    <p id="<%= uuid %>">
      <em><%= content %></em>
    </p>
    """
  end

  def display_message(%{uuid: uuid, content: content, username: username}) do
    ~E"""
    <p id="<%= uuid %>">
      <strong><%= username %></strong>: <%= content %>
    </p>
    """
  end

end
