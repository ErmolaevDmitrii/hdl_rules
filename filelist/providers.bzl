visibility("private")

load("//verilog:defs.bzl", "collect_verilog_info")

def _verilog_filelist_impl(ctx):
    verilog_info = collect_verilog_info(ctx)
    lines = []

    for incdir in verilog_info.incdirs.to_list():
        lines.append("+incdir+%s" % incdir)

    for define in verilog_info.defines.to_list():
        lines.append("+define+%s" % define)

    for src in verilog_info.srcs.to_list():
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
