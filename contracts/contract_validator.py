"""
Validates all generated RTL files against the design contract.
Runs BEFORE the AI autofix loop — catches contract violations
before they become synthesis or timing bugs.
"""
import yaml
import re
from pathlib import Path
from dataclasses import dataclass
from typing import List

@dataclass
class ContractViolation:
    file: str
    line: int
    rule: str
    severity: str       # "ERROR" | "WARNING"
    plain_english: str  # Human-readable explanation
    auto_fixable: bool
    fix_description: str

def load_contract(path: str = "contracts/upu_contract.yaml") -> dict:
    with open(path) as f:
        return yaml.safe_load(f)

def validate_rtl_file(filepath: str, contract: dict) -> List[ContractViolation]:
    """Check a single RTL file against all contract rules."""
    violations = []
    content = Path(filepath).read_text()
    lines = content.split("\n")

    # ── Rule 1: No async reset ─────────────────────────────────────────
    if not contract["reset"]["async_reset_allowed"]:
        for i, line in enumerate(lines):
            if re.search(r"posedge\s+rst|negedge\s+rst_n", line):
                if "or" in line:  # async sensitivity list
                    violations.append(ContractViolation(
                        file=filepath, line=i+1,
                        rule="ASYNC_RESET_FORBIDDEN",
                        severity="ERROR",
                        plain_english=(
                            "This flip-flop uses an asynchronous reset. "
                            "Your contract requires synchronous reset everywhere. "
                            "Async resets can cause glitches when reset deasserts. "
                            "Fix: Remove rst from the sensitivity list."
                        ),
                        auto_fixable=True,
                        fix_description="Convert to synchronous reset pattern"
                    ))

    # ── Rule 2: Overflow policy on accumulators ────────────────────────
    if contract["data_widths"]["npu_overflow_policy"] == "SATURATE":
        # Check for accumulators without saturation logic
        if "accumulator" in filepath.lower() or "acc" in filepath.lower():
            has_saturate = "saturate" in content.lower() or "$signed" in content
            if not has_saturate and "+" in content:
                violations.append(ContractViolation(
                    file=filepath, line=0,
                    rule="MISSING_SATURATION",
                    severity="ERROR",
                    plain_english=(
                        "This accumulator adds numbers but has no saturation logic. "
                        "If the sum exceeds 32 bits, it silently wraps to zero — "
                        "corrupting all your neural network results. "
                        "Fix: Add: if (sum > MAX_VAL) sum = MAX_VAL; after each addition."
                    ),
                    auto_fixable=True,
                    fix_description="Add saturation clamp after accumulation"
                ))

    # ── Rule 3: AXI VALID independence from READY ─────────────────────
    if "axi" in filepath.lower() or "master" in filepath.lower():
        # Detect: assign valid = ... ready ... (VALID depending on READY)
        for i, line in enumerate(lines):
            if re.search(r"valid\s*=.*ready", line) and "assert" not in line:
                violations.append(ContractViolation(
                    file=filepath, line=i+1,
                    rule="AXI_VALID_DEPENDS_ON_READY",
                    severity="ERROR",
                    plain_english=(
                        "VALID is being driven by READY on this line. "
                        "This breaks the AXI specification (rule A3.1.2). "
                        "It causes deadlock: the slave waits for valid, "
                        "the master waits for ready — both wait forever. "
                        "Fix: VALID must be set independently, based only on "
                        "whether you have data to send."
                    ),
                    auto_fixable=True,
                    fix_description="Decouple valid from ready signal"
                ))

    # ── Rule 4: Pipeline depth check ──────────────────────────────────
    max_depth = contract["pipeline"]["max_combinational_depth_gates"]
    # Count combinational chain depth (simplified: count operators between registers)
    always_blocks = re.findall(r"always_comb(.*?)(?=always|endmodule)", content, re.DOTALL)
    for block in always_blocks:
        # Count arithmetic operators as proxy for gate depth
        op_count = len(re.findall(r"[+\-\*\/\|&^]", block))
        if op_count > max_depth:
            violations.append(ContractViolation(
                file=filepath, line=0,
                rule="COMBINATIONAL_PATH_TOO_DEEP",
                severity="WARNING",
                plain_english=(
                    f"This combinational block has ~{op_count} operations. "
                    f"Your contract allows max {max_depth}. "
                    "At 50MHz, this path may not meet timing (needs to finish in 20ns). "
                    "Fix: Add pipeline registers to split this into 2 stages."
                ),
                auto_fixable=True,
                fix_description="Split into pipelined stages"
            ))

    # ── Rule 5: Cross-module outputs must be registered ───────────────
    if contract["pipeline"]["cross_module_outputs_registered"]:
        # Check for combinational output ports (output reg is fine, output wire is suspicious)
        output_wires = re.findall(r"output\s+wire\s+\w+", content)
        if output_wires and "assign" in content:
            for wire in output_wires:
                port_name = wire.split()[-1]
                # Check if this port is driven by pure combinational logic
                if re.search(rf"assign\s+{port_name}\s*=", content):
                    violations.append(ContractViolation(
                        file=filepath, line=0,
                        rule="UNREGISTERED_OUTPUT_PORT",
                        severity="WARNING",
                        plain_english=(
                            f"Output port '{port_name}' is combinational (not registered). "
                            "When this connects to another module, combinational glitches "
                            "can propagate and cause incorrect behavior. "
                            "Fix: Register this output with a flip-flop."
                        ),
                        auto_fixable=True,
                        fix_description="Add output register stage"
                    ))

    return violations


def validate_all_rtl(project_dir: str, contract: dict) -> dict:
    """Validate entire project RTL against contract. Returns summary."""
    rtl_dir = Path(project_dir) / "rtl"
    all_violations = []

    for sv_file in rtl_dir.glob("**/*.sv"):
        violations = validate_rtl_file(str(sv_file), contract)
        all_violations.extend(violations)

    errors   = [v for v in all_violations if v.severity == "ERROR"]
    warnings = [v for v in all_violations if v.severity == "WARNING"]

    return {
        "total_violations": len(all_violations),
        "errors": len(errors),
        "warnings": len(warnings),
        "violations": [v.__dict__ for v in all_violations],
        "contract_passed": len(errors) == 0,
        "ready_for_synthesis": len(errors) == 0,
    }

if __name__ == "__main__":
    import sys
    import json
    
    contract = load_contract("k:/upu/upu-fab/contracts/upu_contract.yaml")
    results = validate_all_rtl("k:/upu/upu-fab", contract)
    
    print(json.dumps(results, indent=2))
    
    if results["errors"] > 0:
        sys.exit(1)
    sys.exit(0)
