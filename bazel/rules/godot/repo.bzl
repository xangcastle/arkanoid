def _imp(repository_ctx):
    version = repository_ctx.attr.version
    flavor = repository_ctx.attr.flavor
    platform = repository_ctx.attr.platform
    url = "https://downloads.godotengine.org/?version={version}&flavor={flavor}&platform={platform}&slug={slug}".format(
        version=version,
        flavor=flavor,
        platform=platform,
        slug=repository_ctx.attr.slug,
    )
    canonical_id = "godot-{}-{}-{}".format(version, platform, flavor)
    output = "Godot.zip"
    repository_ctx.download(url, output=output, canonical_id=canonical_id)
    repository_ctx.extract(output)
    if platform.startswith("linux"):
        binary = "Godot"
    elif platform.startswith("windows"):
        binary = "Godot.exe"
    elif platform.startswith("macos"):
        binary = "Godot.app/Contents/MacOS/Godot"
    else:
        fail("Unsupported platform: {}".format(platform))

    repository_ctx.file("BUILD.bazel", """
exports_files(["{binary}"])

sh_binary(
    name = "godot",
    srcs = ["{binary}"],
)
    """.format(binary=binary))

repo = repository_rule(
    implementation = _imp,
    attrs = {
        "version": attr.string(mandatory=True, default="4.5"),
        "flavor": attr.string(mandatory=True, default="stable"),
        "platform": attr.string(mandatory=True, default="macos.universal"),
        "slug": attr.string(mandatory=True, default="macos.universal.zip"),
    },
)