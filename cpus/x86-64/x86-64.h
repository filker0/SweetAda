
/*
 * x86-64.h - x86-64 architecture definitions.
 *
 * Copyright (C) 2020-2025 Gabriele Galeotti
 *
 * This work is licensed under the terms of the MIT License.
 * Please consult the LICENSE.txt file located in the top-level directory.
 */

#ifndef _x86_64_H
#define _x86_64_H 1

/*
 * Basic definitions.
 */

#define GDT_ALIGNMENT 8
#define IDT_ALIGNMENT 8

#define PL0 0
#define PL1 1
#define PL2 2
#define PL3 3

/*
 * Segment selectors and descriptors.
 */

#define TI_GDT 0
#define TI_LDT 1

#define DATA_RW 0x2
#define CODE_ER 0xA

#define GATE_TASK      0x05
#define GATE_INTERRUPT 0x0E
#define GATE_TRAP      0x0F

/* 1st/2nd byte of a segment descriptor */
#define LIMITL(x)     ((x) & 0xFFFF)
/* 3rd/4th byte of a segment descriptor */
#define BASEL(x)      ((x) & 0xFFFF)
/* 5th byte of a segment descriptor */
#define BASEM(x)      ((x) >> 16 & 0xFF)
/* 6th byte of a segment descriptor */
#define SEG_SYSTEM    0
#define SEG_CODE_DATA (1 << 4)
#define SEG_PL0       (PL0 << 5)
#define SEG_PL1       (PL1 << 5)
#define SEG_PL2       (PL2 << 5)
#define SEG_PL3       (PL3 << 5)
#define SEG_PRESENT   (1 << 7)
/* 7th byte of a segment descriptor */
#define LIMITH(x)     ((x) >> 16 & 0xFF)
#define SEG_AVL       (1 << 4)
#define SEG_32        0
#define SEG_64        (1 << 5)
#define SEG_OP16      0
#define SEG_OP32      (1 << 6)
#define SEG_GRANBYTE  0
#define SEG_GRAN4k    (1 << 7)
/* 8th byte of a segment descriptor */
#define BASEH(x)      ((x) >> 24 & 0xFF)

/*
 * Segmented and paged memory management.
 */

#define CR0_PE (1 << 0)
#define CR0_NE (1 << 5)
#define CR0_NW (1 << 29)
#define CR0_CD (1 << 30)
#define CR0_PG (1 << 31)

#define CR4_PAE (1 << 5)
#define CR4_PGE (1 << 7)

#define PAGE_ENTRIES 1024
#define PAGE_SIZE    4096
#define PAGE_PRESENT (1 << 0)
#define PAGE_WRITE   (1 << 1)
#define PAGE_USER    (1 << 2)

#define PAGE2ADDRESS(x) ((x) << 12)
#define ADDRESS2PAGE(x) ((x) >> 12)

/*
 * RFLAGS.
 */

#define RFLAGS_CF (1 << 0)
#define RFLAGS_PF (1 << 2)
#define RFLAGS_AF (1 << 4)
#define RFLAGS_ZF (1 << 6)
#define RFLAGS_SF (1 << 7)
#define RFLAGS_TF (1 << 8)
#define RFLAGS_IF (1 << 9)
#define RFLAGS_DF (1 << 10)
#define RFLAGS_OF (1 << 11)
#define RFLAGS_NT (1 << 14)
#define RFLAGS_RF (1 << 16)
#define RFLAGS_VM (1 << 17)

/*
 * MSRs
 */

#define IA32_EFER     0xC0000080
#define IA32_EFER_LME (1 << 8)

/*
 * Exceptions.
 */

#define DIVISION_BY_0        0
#define DEBUG_EXCEPTION      1
#define NMI_INTERRUPT        2
#define ONE_BYTE_INTERRUPT   3
#define INT_ON_OVERFLOW      4
#define ARRAY_BOUNDS         5
#define INVALID_OPCODE       6
#define DEVICE_NOT_AVAILABLE 7
#define DOUBLE_FAULT         8
#define CP_SEGMENT_OVERRUN   9
#define INVALID_TSS          10
#define SEGMENT_NOT_PRESENT  11
#define STACK_FAULT          12
#define GENERAL_PROTECTION   13
#define PAGE_FAULT           14
#define COPROCESSOR_ERROR    16

/*
 * IRQ exception identifiers.
 */

#define IRQ0  32
#define IRQ1  33
#define IRQ2  34
#define IRQ3  35
#define IRQ4  36
#define IRQ5  37
#define IRQ6  38
#define IRQ7  39
#define IRQ8  40
#define IRQ9  41
#define IRQ10 42
#define IRQ11 43
#define IRQ12 44
#define IRQ13 45
#define IRQ14 46
#define IRQ15 47

/*
 * Breakpoint.
 */

#define OPCODE_NOP             0x90
#define OPCODE_BREAKPOINT      0xCC
#define OPCODE_BREAKPOINT_SIZE 1

#endif /* _x86_64_H */

