load("//verilog:defs.bzl", "merge_verilog_context")

visibility("private")

def _verilog_jinja2_render_impl(ctx):
    template_file = ctx.file.template

    rendered_file_path = None

    if ctx.attr.out:
        rendered_file_path = ctx.attr.out
    else:
        rendered_file_path = ctx.label.name + ".sv"

    rendered_file = ctx.actions.declare_file(rendered_file_path)

    config_json_file = ctx.actions.declare_file(rendered_file_path + "_config.json")
    ctx.actions.write(
        output = config_json_file,
        content = json.encode(ctx.attr.params)
    )

    renderer_args = ctx.actions.args()
    renderer_args.add("-t", template_file.path)
    renderer_args.add("-c", config_json_file.path)
    renderer_args.add("-o", rendered_file.path)
    include_dirs = {}
    for util_file in ctx.files._jinja2_utils:
        include_dirs[util_file.dirname] = None
    for include_dir in include_dirs:
        renderer_args.add("-I", include_dir)

    inputs = (
        [template_file, config_json_file]
        + ctx.files.deps
        + ctx.files._jinja2_utils
    )

    ctx.actions.run(
        inputs = inputs,
        outputs = [rendered_file],
        executable = ctx.executable.renderer,
        arguments = [renderer_args],
        mnemonic = "Jinja2SvRenderer",
    )

    verilog_context = merge_verilog_context(
        ctx,
        direct_srcs = [rendered_file],
        direct_incdirs = [rendered_file.dirname] + ctx.attr.incdirs,
        direct_defines = ctx.attr.defines,
    )

    return [
        DefaultInfo(files = depset([rendered_file])),
        verilog_context,
    ]

verilog_jinja2_render = rule(
    implementation = _verilog_jinja2_render_impl,
    attrs = {
        "template": attr.label(
            allow_single_file = [".v.j2", ".sv.j2"],
            mandatory = True,
        ),
        "params": attr.string_dict(),
        "out": attr.string(),
        "incdirs": attr.string_list(),
        "defines": attr.string_list(),
        "deps": attr.label_list(
            allow_files = True,
        ),
        "renderer": attr.label(
            default = Label("//jinja2/default_renderer:default_renderer"),
            executable = True,
            cfg = "exec",
        ),
        "_jinja2_utils": attr.label(
            default = Label("//jinja2/utils:jinja2_utils"),
        )
    }
)
