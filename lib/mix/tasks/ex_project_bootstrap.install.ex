defmodule Mix.Tasks.ExProjectBootstrap.Install.Docs do
  @moduledoc false

  @spec short_doc() :: String.t()
  def short_doc do
    "iDream Specific bootstrap task"
  end

  @spec example() :: String.t()
  def example do
    "mix ex_project_bootstrap.install"
  end

  @spec long_doc() :: String.t()
  def long_doc do
    """
    #{short_doc()}

    Installs all then things i like. 

    ## Example

    ```sh
    #{example()}
    ```

    ## Options

    * `--example-option` or `-e` - Docs for your option
    """
  end
end

if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.ExProjectBootstrap.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()}"

    @moduledoc __MODULE__.Docs.long_doc()

    use Igniter.Mix.Task

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{
        # Groups allow for overlapping arguments for tasks by the same author
        # See the generators guide for more.
        group: :ex_project_bootstrap,
        adds_deps: [],
        installs: [
          # {:ash, "~> 3.0"},
          # {:ash_phoenix, "~> 2.0"},
          # {:ash_postgres, "~> 2.0"},
          # {:ash_authentication, "~> 4.0"},
          # {:ash_authentication_phoenix, "~> 2.0"},
          # {:ash_admin, "~> 0.14"},
          # {:oban, "~> 2.0"},
          # {:oban_web, "~> 2.0"},
          # {:ash_oban, "~> 0.8"},
          # {:ash_state_machine, "~> 0.2"},
          # {:tidewave, "~> 0.5", only: [:dev]},
          # {:usage_rules, "~> 1.0", only: [:dev]},
          # {:error_tracker, "~> 0.8.0"}
        ],
        # An example invocation
        example: __MODULE__.Docs.example(),
        # A list of environments that this should be installed in.
        only: nil,
        # a list of positional arguments, i.e `[:file]`
        positional: [],
        # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
        # This ensures your option schema includes options from nested tasks
        composes: [],
        # `OptionParser` schema
        # these will be passed into the other installers too!
        schema: [
          auth_strategy: :csv,
          setup: :boolean
        ],
        # Default values for the options in the `schema`
        defaults: [],
        # CLI aliases
        aliases: [],
        # A list of options in the schema that are required
        required: []
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      # Do your work here and return an updated igniter
      dbg(igniter.assigns)

      igniter =
        igniter
        |> Igniter.create_new_file(
          "Taskfile.yml",
          File.read!(Path.join(__DIR__, "../../../priv/templates/Taskfile.yml")),
          on_exists: :warning
        )
        |> Igniter.create_new_file(
          "pull-data.sh",
          File.read!(Path.join(__DIR__, "../../../priv/templates/pull-data.sh")),
          on_exists: :warning
        )
        |> Igniter.create_new_file(
          "mise.toml",
          File.read!(Path.join(__DIR__, "../../../priv/templates/mise.toml")),
          on_exists: :warning
        )
        |> Igniter.create_new_file(
          "usage_rules.md",
          File.read!(Path.join(__DIR__, "../../../priv/templates/usage_rules.md")),
          on_exists: :warning
        )
        |> Igniter.create_new_file(
          "firefly_bootstrap.sh",
          File.read!(Path.join(__DIR__, "../../../priv/templates/firefly_bootstrap.sh")),
          on_exists: :warning
        )

      app_name = Igniter.Project.Application.app_name(igniter)
      endpoint_module_name = Module.concat([Igniter.Libs.Phoenix.web_module(igniter), "Endpoint"])

      igniter =
        igniter
        |> Igniter.Project.Config.configure_runtime_env(
          :dev,
          app_name,
          [endpoint_module_name, :http],
          {:code,
           Sourceror.parse_string!("""
            port = String.to_integer(System.get_env("PORT", "4000"))
           fly_6pn_ip =
           case :inet.gethostbyname(~c'fly-local-6pn', :inet6) do {:ok, {:hostent, _, _, _, _, [ip | _]}} ->
            ip

           error ->
            IO.inspect(error, label: "fly-local-6pn lookup failed, binding to ipv4")

            # we have a safe fallback if we are running locally here
            {0, 0, 0, 0}
           end

           IO.inspect(fly_6pn_ip, label: "binding to")

             [ip: fly_6pn_ip, port: port]
              # config :ai_bootstrap, AiBootstrapWeb.Endpoint, http: [ip: fly_6pn_ip, port: port]

           """)}
        )

      code = """
      if Code.ensure_loaded?(Tidewave) do
        plug Tidewave, allow_remote_access: true
      end
      """

      # find_code = """
      # __cursor__()
      # if code_reloading? do
      #   __
      # end
      # """
      #
      igniter
      |> Igniter.Project.Module.find_and_update_module(endpoint_module_name, fn zipper ->
        alias Sourceror.Zipper

        zip =
          Zipper.find(zipper, fn node ->
            case node do
              {:if, _,
               [
                 {:code_reloading?, _},
                 _
               ]} ->
                node

              _ ->
                nil
            end
          end)

        if zip != nil do
          Igniter.Code.Common.add_code(zip, code, placement: :before)
        else
          IO.puts("couuld not find it")
        end

        # case Igniter.Code.Common.move_to_cursor(zipper, find_code) do
        #   {:ok, zipper} ->
        #     IO.puts("1")
        #     dbg(zipper)
        #     Igniter.Code.Common.add_code(zipper, code, placement: :before)
        #
        #   :error ->
        #     IO.puts("2")
        #     Igniter.Code.Common.add_code(zipper, code, placement: :after)
        #
        #   other ->
        #     IO.puts("oh shit, #{inspect(other)}")
        # end
      end)

      # add tidewave config to allow remote 

      # create our mise file
    end
  end
else
  defmodule Mix.Tasks.ExProjectBootstrap.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()} | Install `igniter` to use"

    @moduledoc __MODULE__.Docs.long_doc()

    use Mix.Task

    @impl Mix.Task
    def run(_argv) do
      Mix.shell().error("""
      The task 'ex_project_bootstrap.install' requires igniter. Please install igniter and try again.

      For more information, see: https://hexdocs.pm/igniter/readme.html#installation
      """)

      exit({:shutdown, 1})
    end
  end
end
