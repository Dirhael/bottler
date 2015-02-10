require Logger, as: L
require Bottler.Helpers, as: H

defmodule Bottler do

  @moduledoc """

  To run:
  ```
      run_erl -daemon /tmp/app/pipes/ /tmp/app/log "erl -boot /tmp/app/current/start -config /tmp/app/current/sys -env ERL_LIBS /tmp/app/lib -sname app"
  ```
  To attach:
  ```
      to_erl /tmp/app/pipes/erlang.pipe.1
  ```

  """

  @doc """
    Entry point for `mix release` task. Returns `:ok` when done.
  """
  def release(config), do: Bottler.Release.release config

  @doc """
    Copy local release file to remote servers
    Returns `{:ok, details}` when done, `{:error, details}` if anything fails.
  """
  def ship(config) do
    L.info "Shipping to #{config[:servers] |> Keyword.keys |> Enum.join(",")}..."

    app = Mix.Project.get!.project[:app]
    config[:servers] |> Keyword.values |> H.in_tasks( fn(args) ->
        args = args ++ [remote_user: config[:remote_user]]
        "scp rel/#{app}.tar.gz <%= remote_user %>@<%= ip %>:/tmp/"
            |> EEx.eval_string(args) |> to_char_list |> :os.cmd
      end, expected: [], to_s: true)
  end

  @doc """
    Install previously shipped release on remote servers.
    Returns `{:ok, details}` when done, `{:error, details}` if anything fails.
  """
  def install(config), do: Bottler.Install.install(config)

  @doc """
    Restart app on remote servers.
    It merely touches `app/tmp/restart`, so something like
    [Harakiri](http://github.com/elpulgardelpanda/harakiri) should be running
    on server.

    Returns `{:ok, details}` when done, `{:error, details}` if anything fails.
  """
  def restart(config) do
    L.info "Restarting #{config[:servers] |> Keyword.keys |> Enum.join(",")}..."

    app = Mix.Project.get!.project[:app]
    config[:servers] |> Keyword.values |> H.in_tasks( fn(args) ->
        args = args ++ [remote_user: config[:remote_user]]
        "ssh <%= remote_user %>@<%= ip %> 'touch #{app}/tmp/restart'"
          |> EEx.eval_string(args) |> to_char_list |> :os.cmd
      end, expected: [], to_s: true)
  end

end
