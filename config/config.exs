import Config

config :logger,
  level: :debug,
  backends: [:console]

if Mix.env() == :test,
  do: config(:apic, :listener, Apic.Request.Listener.Mox)
