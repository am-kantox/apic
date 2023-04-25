defmodule Apic.Request.Listener do
  @behaviour Finitomata.Listener

  require Logger

  @impl Finitomata.Listener
  def after_transition(id, state, payload) do
    [id: id, state: state, payload: payload]
    |> inspect(limit: :infinity)
    |> Logger.warn()
  end
end
