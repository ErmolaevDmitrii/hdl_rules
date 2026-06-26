visibility("public")

load(
    ":providers.bzl",
    _VerilogInfo = "VerilogInfo",
    _verilog_library = "verilog_library",
    _merge_verilog_info = "merge_verilog_info",
    _collect_verilog_info = "collect_verilog_info",
)

VerilogInfo = _VerilogInfo
verilog_library = _verilog_library
merge_verilog_info = _merge_verilog_info
collect_verilog_info = _collect_verilog_info