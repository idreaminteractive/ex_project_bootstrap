
<!-- usage_rules:start -->

# Project guidelines

## General

- All changes should NEVER happen on `develop`. If you are attempting to make
changes directly on the `develop` branch, prompt the user to checkout a
branch to start their work on.

- All commands (mix text, mix compile, etc) should at a minimum, be run using `mise`
ie: `mise x -- mix compile`

- We also use `task` for many commands, like `mise x -- task test`, etc. Please
note, we still prefix it with `mise x --`

- When working on a feature, stop after each todo item and validate with
me to ensure it is on the right track. Let me verify and be the
human in the loop.

## Ash First

Always use Ash concepts, almost never Ecto concepts directly. Think hard about
the "Ash way" to do things. If you don't know, look for information in the
rules & docs of Ash & associated packages.

## Tidewave

Use the Tidewave MCP tooling for checking and debugging if available.

## Code Generation

The project will have some basic scaffolding setup and some example structure
for resources, controllers, and views. You should use this scaffolding as a
sample of good practice (but use your discretion)

## Logs & Tests

When you're done executing code, try to compile the code, and check the
logs or run any applicable tests to see what effect your changes have had.

## Tools

- Never attempt to start or stop a Phoenix application. Tidewave tools work by
being connected to the running application, and starting or stopping it can
cause issues.
- Use the `project_eval` tool to execute code in the running instance of the
application. Eval `h Module.fun` to get documentation for a module or function.
- Always use `search_package_docs` to find relevant documentation before
beginning work.

## Other rules

- For styling, ALWAYS use DaisyUI if possible. [DaisyUI usage rules](https://daisyui.com/docs/install/usage-rules)
- If DaisyUI won't work for something specific, you can goto Tailwind
[Tailwind usage rules](https://tailwindcss.com/docs/content-configuration#usage-rules)

- Tests should be written and verified.
- HEEX components should have the appropriate `attr` and `slot` attributes.
Don't worry too much about docs.
- All design should account for responsive design.
- Do not guess at business logic. Please ask for clarification if you are unsure.
- If you identify possible performance or security issues, please report them.
- Don't use `:live_component` if you can help it. It's more trouble than it's worth.
- When creating tests, utilize the `test/support/generator.ex` file to generate
data. If a generator is missing, please ask for confirmation before writing a
new one
- If you hit an error using Ash like "The pin operator ^ is supported only
inside matches or inside custom macros. Make sure you are inside a match or all
necessary macros have been required", you may need to add `require Ash.Query` at
the top
<!-- usage_rules:end -->
