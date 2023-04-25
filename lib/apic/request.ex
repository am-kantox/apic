defmodule Apic.Request do
  @fsm """
  virgin --> |init!| initialized
  initialized --> |request!| response
  initialized --> |request!| auth
  initialized --> |request!| error
  response --> |ok| processed
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
    subscribers: {StreamData, :constant, [[]]},
    request: {StreamData, :constant, ["{}"]},
    response: {StreamData, :constant, ["{}"]}
  }

  alias Apic.Request

  @doc false
  def void, do: Request.__generator__() |> Enum.take(1) |> hd()

  @behaviour Siblings.Worker

  @impl Siblings.Worker
  def perform(_state, _id, _payload), do: :noop

  @impl Finitomata
  def on_start(%{pid: from, request: request}) do
    state = struct!(void(), subscribers: [from], request: request)
    {:continue, state}
  end

  @impl Finitomata
  def on_transition(:initialized, :request!, _event_payload, %{} = payload) do
    {:ok, :response, payload}
  end

  @spec async_request(map() | String.t(), pid()) :: {:ok, pid()} | {:error, any()}
  def async_request(request, from \\ nil)

  def async_request(request, from) when is_map(request) do
    with {:ok, json} <- Jason.encode(request), do: async_request(json, from)
  end

  def async_request(request, from) when is_binary(request) do
    # id = :crypto.hash(:md5, request)
    id = System.monotonic_time()

    Siblings.start_child(Apic.Request, id, %{request: request, pid: from || self()},
      name: ApicRequests,
      hibernate?: false,
      interval: 200,
      throttler: [:initialized, :auth]
    )
  end
end
