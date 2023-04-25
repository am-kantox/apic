defmodule Apic.Request do
  @fsm """
  virgin --> |init!| initialized
  initialized --> |request!| response
  initialized --> |request!| auth
  initialized --> |request!| error
  response --> |ok!| processed
  error --> |init!| initialized
  auth --> |login!| initialized
  auth --> |login!| error
  error --> |ko!| processed
  """

  @listener Application.compile_env(:apic, :listener, Apic.Request.Listener)

  use Finitomata, fsm: @fsm, listener: @listener, auto_terminate: true

  defstate %{
    remote: %{
      host: {StreamData, :constant, ["localhost"]},
      port: {StreamData, :constant, ["80"]},
      scheme: {StreamData, :constant, ["https"]},
      login_path: {StreamData, :constant, ["/login"]},
      path: {StreamData, :constant, ["/api"]},
      query: {StreamData, :constant, [""]}
    },
    token: {StreamData, :constant, ["some_token"]},
    request: {StreamData, :constant, ["{}"]},
    response: {StreamData, :constant, ["{}"]}
  }

  alias Apic.Request

  @impl Finitomata
  def on_transition(:initialized, :request!, _event_payload, %{} = payload) do
    {:ok, :response, payload}
  end

end
