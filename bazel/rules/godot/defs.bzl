def _impl(ctx):
    toolchain = ctx.toolchains["@rules_godot//:toolchain_type"]
    godot = toolchain.godot_info.binary

    arguments = ctx.attr.arguments

    executable = ctx.actions.declare_file(ctx.label.name)

    ctx.actions.expand_template(
        template = ctx.file._launcher,
        output = executable,
        substitutions = {
            "%{godot_path}": godot.short_path,
            "%{arguments}": arguments.replace(
                "$(location)", '"$BUILD_WORKSPACE_DIRECTORY"'
            )
        },
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = [godot])
    return [DefaultInfo(executable = executable, runfiles = runfiles)]

_godot_rule = rule(
    implementation = _impl,
    attrs = {
        "arguments": attr.string(default = ""),
        "_launcher": attr.label(
            default = Label("@rules_godot//:launcher.sh.tpl"),
            allow_single_file = True,
        ),
    },
    toolchains = ["@rules_godot//:toolchain_type"],
    executable = True,
)

def godot_project(name, config="project.godot", **kwargs):
    """Defines targets for running a Godot project.

    This macro creates three executable targets for working with a Godot project:
    - `{name}.import`: Imports and processes project assets
    - `{name}.play`: Runs the game in debug mode with the window visible
    - `{name}.engine`: Opens the Godot editor in fullscreen mode

    Args:
        name: The base name for the generated targets. The actual targets will be
            named `{name}.import`, `{name}.play`, and `{name}.engine`.
        config: Path to the Godot project configuration file (project.godot).
            Defaults to "project.godot".
        **kwargs: Additional arguments passed to the underlying _godot_rule.
            Common arguments include:
            - data: Files and directories to include in runfiles
            - deps: Dependencies for the target

    Examples:
        Basic usage for a standard Godot project:

        ```starlark
        load("@rules_godot//:defs.bzl", "godot_project")

        godot_project(
            name = "my_game",
        )
        ```

        This creates targets:
        - `//:my_game.import` - Import project assets
        - `//:my_game.play` - Run the game
        - `//:my_game.engine` - Open the editor

        Custom project file location:

        ```starlark
        godot_project(
            name = "my_game",
            config = "custom_project.godot",
        )
        ```

    Usage:
        Run the game: `bazel run //:my_game.play`
        Import assets: `bazel run //:my_game.import`
        Open editor: `bazel run //:my_game.engine`

    Note:
        The macro assumes the Godot project files are in the same directory
        as the BUILD.bazel file. Use the `data` attribute to include additional
        files or directories if needed.
    """
    import_args = "--path $(location) --import"
    _godot_rule(
        name = name + ".import",
        arguments = import_args,
        **kwargs
    )

    play_args = "--path $(location) -d -w"
    _godot_rule(
        name = name + ".play",
        arguments = play_args,
        **kwargs
    )

    engine_args = "--fullscreen $(location)/{}".format(config)
    _godot_rule(
        name = name + ".engine",
        arguments = engine_args,
        **kwargs
    )

