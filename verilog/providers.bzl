visibility("private")

VerilogInfo = provider(
    doc = "SystemVerilog sources and metadata for downstream EDA filelists.",
    fields = {
        "srcs": "Depset of .sv/.v/.svh/.vh files in dependency order.",
        "incdirs": "Depset of include directories.",
        "defines": "Depset of preprocessor defines.",
    },
)

def merge_verilog_info(ctx, direct_srcs = [], direct_incdirs = [], direct_defines = []):
    dep_infos = [dep[VerilogInfo] for dep in ctx.attr.deps if VerilogInfo in dep]

    return VerilogInfo(
        srcs = depset (
            direct=direct_srcs,
            transitive=[info.srcs for info in dep_infos],
            order="postorder",
        ),
        incdirs = depset (
            direct=direct_incdirs,
            transitive=[info.incdirs for info in dep_infos],
            order="postorder",
        ),
        defines = depset (
            direct=direct_defines,
            transitive=[info.defines for info in dep_infos],
            order="postorder",
        ),
    )

def collect_verilog_info(ctx):
    return merge_verilog_info(ctx)

def _verilog_library_impl(ctx):
    direct_srcs = ctx.files.srcs
    direct_incdirs = [src.dirname for src in direct_srcs] + ctx.attr.incdirs
    verilog_info = merge_verilog_info(
        ctx,
        direct_srcs = direct_srcs,
        direct_incdirs = direct_incdirs,
        direct_defines = ctx.attr.defines,
    )

    return [
        DefaultInfo(files = verilog_info.srcs),
        verilog_info,
    ]

verilog_library = rule (
    implementation = _verilog_library_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".sv", ".v", ".svh", ".vh"]),
        "deps": attr.label_list(),
        "incdirs": attr.string_list(),
        "defines": attr.string_list(),
    },
)