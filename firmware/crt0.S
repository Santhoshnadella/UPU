.section .text.start
.global _start

_start:
    # 1. Initialize Stack Pointer (Top of 256KB SRAM @ 0x10040000)
    li sp, 0x10040000

    # 2. Clear BSS (Global uninitialized variables)
    la t0, _bss_start
    la t1, _bss_end
    
clear_bss:
    bge t0, t1, jump_to_main
    sd x0, 0(t0)
    addi t0, t0, 8
    j clear_bss

jump_to_main:
    # 3. Jump to C Main
    call main

    # 4. Success/Exit (Spin loop)
exit_loop:
    j exit_loop

# ─────────────────────────────────────────────────────────────────────────────
# Interrupt Vector Table (Simple v1 Trap Handler)
# ─────────────────────────────────────────────────────────────────────────────
.section .text.trap
.align 4
trap_handler:
    # Minimal context save
    addi sp, sp, -64
    sd ra, 0(sp)
    sd t0, 8(sp)
    sd t1, 16(sp)
    
    # 1. Check mcause for IRQ vs Exception
    csrr t0, mcause
    blt t0, x0, irq_found
    
exception_loop:
    j exception_loop # Hang on exceptions

irq_found:
    # Call PLIC claim handler (Placeholder in C)
    call u_plic_claim_handler
    
    # Context restore
    ld ra, 0(sp)
    ld t0, 8(sp)
    ld t1, 16(sp)
    addi sp, sp, 64
    mret
