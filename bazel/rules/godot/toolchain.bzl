GodotInfo = provider(
    doc = "Information about the Godot toolchain.",
    fields = {
        "binary": "File: The Godot binary.",
    },
)

def _impl(ctx):
    return [
        platform_common.ToolchainInfo(
            godot_info = GodotInfo(
                binary = ctx.file.binary,
            ),
        ),
        DefaultInfo(
            files = depset([ctx.file.binary]),
        ),
    ]

godot_toolchain_impl = rule(
    implementation = _impl,
    attrs = {
        "binary": attr.label(
            allow_single_file = True,
            cfg = "exec",
            mandatory = True,
        ),
    },
)