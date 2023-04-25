defmodule Apic.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Siblings.child_spec(name: ApicRequests, die_with_children: false)
    ]

    opts = [strategy: :one_for_one, name: Apic.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
