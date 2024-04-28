_OAPI_CODEGEN = Label("//oapi-codegen:oapi-codegen")

def _codegen_impl(ctx):
    args = ctx.actions.args()
    args.add("-o", ctx.outputs.out.path)
    args.add("-package", ctx.attr.package)
    if len(ctx.attr.generate) > 0:
      args.add("-generate", ",".join(ctx.attr.generate))
    args.add(ctx.file.open_api_spec.path)
    ctx.actions.run(
        inputs = [ctx.file.open_api_spec],
        outputs = [ctx.outputs.out],
        executable = ctx.executable.codegen_tool,
        tools = [ctx.executable.codegen_tool],
        arguments = [args],
        mnemonic = "DeepmapOpenAPICodegen",
    )
    return [
        DefaultInfo(files = depset([ctx.outputs.out])),
        OutputGroupInfo(go_generated_srcs = [ctx.outputs.out]),
    ]

oapi_codegen = rule(
    _codegen_impl,
    attrs = {
        "package": attr.string(
            doc = "The value to use as the name within the generated code",
            mandatory = True,
        ),
        "open_api_spec": attr.label(
            allow_single_file = [".json", ".yaml", ".yml"],
            mandatory = True,
            doc = "The OpenAPI spec used to generate the code.",
        ),
        "codegen_tool": attr.label(
            executable = True,
            default = _OAPI_CODEGEN,
            doc = "The oapi-codegen tool to run",
            allow_single_file = True,
            mandatory = False,
            cfg = "exec",
        ),
        "out": attr.output(doc = "The new Go file to emit the generated code into.", mandatory = True),
        "generate": attr.string_list(
        default = ["types", "client", "server", "spec"],
        doc = 'Comma-separated list of code to generate; valid options: "types", "client", "chi-server", "server", "gin", "gorilla", "spec", "skip-fmt", "skip-prune", "fiber", "iris". (default "types,client,server,spec")',
        ),
    },
)
