defmodule Apic.Connector do
  @callback login(Apic.Request.t()) :: {:ok, {:token, token}} | {:error, any()}
            when token: binary()
  @callback request(Apic.Request.t()) :: {:ok, {code, response}} | {:error, {code, any()}}
            when code: integer(), response: binary()
end

defmodule Apic.Storage do
  @callback get_creds(Apic.Request.t()) :: binary()
  @callback set_creds(Apic.Request.t()) :: :ok
end
