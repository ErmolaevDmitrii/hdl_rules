load("//verilog:defs.bzl", "collect_verilog_context")

visibility("private")

def _verilog_filelist_impl(ctx):
    verilog_context = collect_verilog_context(ctx)
    lines = []

    for incdir in verilog_context.incdirs.to_list():
        lines.append("+incdir+%s" % incdir)

    for define in verilog_context.defines.to_list():
        lines.append("+define+%s" % define)

    for src in verilog_context.srcs.to_list():
        lines.append(src.path)

    ctx.actions.write(
        output = ctx.outputs.out,
        content = "\n".join(lines) + "\n",
    )

    return [DefaultInfo(files = depset([ctx.outputs.out]))]

verilog_filelist = rule(
    implementation = _verilog_filelist_impl,
    attrs = {
        "deps": attr.label_list(mandatory = True),
        "out": attr.output(mandatory = True),
    },
)
