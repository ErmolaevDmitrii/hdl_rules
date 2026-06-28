visibility("public")

load(
    ":providers.bzl",
    _VerilogContext = "VerilogContext",
    _verilog_library = "verilog_library",
    _merge_verilog_context = "merge_verilog_context",
    _collect_verilog_context = "collect_verilog_context",
)

VerilogContext = _VerilogContext
verilog_library = _verilog_library
merge_verilog_context = _merge_verilog_context
collect_verilog_context = _collect_verilog_context