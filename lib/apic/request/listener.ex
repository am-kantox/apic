defmodule Apic.Request.Listener do
  @behaviour Finitomata.Listener

  require Logger

  @impl Finitomata.Listener
  def after_transition(_id, :error, payload) do
    [error: payload]
    |> inspect(limit: :infinity)
    |> Logger.error()
  end

  def after_transition(_id, :response, payload) do
    [response: payload]
    |> inspect(limit: :infinity)
    |> Logger.info()

    Enum.each(payload.internals.subscribers, fn pid ->
      send(pid, {:response, payload.response})
    end)
  end

  @impl Finitomata.Listener
  def after_transition(_id, state, payload) do
    [{state, payload}]
    |> inspect(limit: :infinity)
    |> Logger.warn()
  end
end
