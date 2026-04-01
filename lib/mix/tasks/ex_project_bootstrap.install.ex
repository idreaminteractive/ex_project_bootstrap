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
          {:ash, "~> 3.0"},
          {:ash_phoenix, "~> 2.0"},
          {:ash_postgres, "~> 2.0"},
          {:ash_authentication, "~> 4.0"},
          {:ash_authentication_phoenix, "~> 2.0"},
          {:ash_admin, "~> 0.14"},
          {:oban, "~> 2.0"},
          {:oban_web, "~> 2.0"},
          {:ash_oban, "~> 0.8"},
          {:ash_state_machine, "~> 0.2"},
          {:tidewave, "~> 0.5", only: [:dev]},
          {:usage_rules, "~> 1.0", only: [:dev]},
          {:error_tracker, "~> 0.8.0"},
          {:phoenix_test, "~> 0.10.0", only: :test, runtime: false}
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

      igniter = igniter |> copy_supporting_files()

      app_name = Igniter.Project.Application.app_name(igniter)
      endpoint_module_name = Module.concat([Igniter.Libs.Phoenix.web_module(igniter), "Endpoint"])

      igniter = igniter |> update_runtime_config(app_name, endpoint_module_name)

      igniter |> update_endpoint_config(endpoint_module_name)
    end

    defp update_endpoint_config(igniter, endpoint_module_name) do
      tidewave_block = """
      if Mix.env() == :dev do
        plug Tidewave, allow_remote_access: true
      end
      """

      {:ok, igniter} =
        igniter
        |> Igniter.Project.Module.find_and_update_module(endpoint_module_name, fn zipper ->
          alias Sourceror.Zipper

          tidewave_zip =
            Zipper.find(zipper, fn node ->
              match?(
                {:if, _,
                 [
                   {:==, _,
                    [
                      {{:., _, [{:__aliases__, _, [:Mix]}, :env]}, _, []},
                      {:__block__, _, [:dev]}
                    ]},
                   _
                 ]},
                node
              )
            end)

          if tidewave_zip != nil do
            # already has if Mix.env() == :dev block — update plug Tidewave to add allow_remote_access: true
            new_plug = Sourceror.parse_string!("plug Tidewave, allow_remote_access: true")

            plug_zip =
              Zipper.find(tidewave_zip, fn node ->
                match?(
                  {:plug, _, [{:__aliases__, _, [:Tidewave]} | _]},
                  node
                )
              end)

            if plug_zip != nil do
              {:ok, Zipper.replace(plug_zip, new_plug)}
            else
              {:ok,
               Igniter.Code.Common.add_code(tidewave_zip, tidewave_block, placement: :before)}
            end
          else
            # no existing Tidewave block — insert before if code_reloading?
            code_reloading_zip =
              Zipper.find(zipper, fn node ->
                match?(
                  {:if, _, [{:code_reloading?, _, _} | _]},
                  node
                )
              end)

            if code_reloading_zip != nil do
              {:ok,
               Igniter.Code.Common.add_code(code_reloading_zip, tidewave_block,
                 placement: :before
               )}
            else
              {:warning, "could not find insertion point in #{inspect(endpoint_module_name)}"}
            end
          end
        end)

      igniter
    end

    defp copy_supporting_files(igniter) do
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
    end

    defp update_runtime_config(igniter, app_name, endpoint_module_name) do
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
