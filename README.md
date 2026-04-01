# ExProjectBootstrap

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_project_bootstrap` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_project_bootstrap, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_project_bootstrap>.

❯ mix igniter.new test_app --with phx.new --install path:./ex_project_bootstrap@0.1.0 --yes

./gomix.sh test_app

```
#!/bin/bash
# new_project.sh
APP_NAME=$1

mix igniter.new $APP_NAME --with phx.new --yes
cd $APP_NAME
mix igniter.install path:../ex_project_bootstrap@0.1.0 --yes
```

## To use

```
mix archive.install hex igniter_new --force
mix archive.install hex phx_new 1.8.5 --force

mix igniter.new <project_name> --with phx.new --install ex_project_bootstrap@github:idreaminteractive/ex_project_bootstrap  --setup --auth-strategy password --yes
```
