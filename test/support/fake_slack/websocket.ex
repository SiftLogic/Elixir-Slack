defmodule Slack.FakeSlack.Websocket do
  @behaviour :cowboy_websocket

  @impl true
  def init(req, _opts) do
    {:cowboy_websocket, req, %{}}
  end

  @impl true
  def websocket_init(state) do
    pid = Application.get_env(:slack, :test_pid)
    send(pid, {:websocket_connected, self()})

    {:ok, state}
  end

  @impl true
  def websocket_handle(:ping, state) do
    {{:text, "pong"}, state}
  end

  def websocket_handle({:text, message}, state) do
    pid = Application.get_env(:slack, :test_pid)
    send(pid, {:bot_message, Jason.decode!(message)})

    {:ok, state}
  end

  @impl true
  def websocket_info(message, state) do
    {[{:text, message}], state}
  end
end
