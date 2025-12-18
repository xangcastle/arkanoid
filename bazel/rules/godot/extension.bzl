load("//:repo.bzl", "repo")

def _imp(module_ctx):
    registrations = {}

    for module in module_ctx.modules:
        for toolchain in module.tags.toolchain:
            if toolchain.name in registrations:
                fail("Duplicate: a Godot with name = '{}' already exists".format(toolchain.name))

            registrations[toolchain.name] = {
                "version": toolchain.version,
                "flavor": toolchain.flavor,
                "platform": toolchain.platform,
                "slug": toolchain.slug,
            }

    for name, config in registrations.items():
        repo(
            name = name,
            version = config["version"],
            flavor = config["flavor"],
            platform = config["platform"],
            slug = config["slug"],
        )

    return module_ctx.extension_metadata(
        reproducible = True,
        root_module_direct_deps = "all",
        root_module_direct_dev_deps = [],
    )

_toolchain_tag = tag_class(
    attrs = {
        "name": attr.string(
            doc = "Name of the repo that will contain the Godot binary",
            mandatory = True,
        ),
        "version": attr.string(
            doc = "Godot version",
            default = "4.5",
        ),
        "flavor": attr.string(
            doc = "Godot flavor",
            default = "stable",
        ),
        "platform": attr.string(
            doc = "Godot platform",
            default = "macos.universal",
        ),
        "slug": attr.string(
            doc = "Godot slug",
            default = "macos.universal.zip",
        ),
    },
)

godot = module_extension(
    implementation = _imp,
    tag_classes = {
        "toolchain": _toolchain_tag
    },
)