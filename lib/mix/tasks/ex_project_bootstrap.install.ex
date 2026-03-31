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

      # add the values into the runtime config
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
