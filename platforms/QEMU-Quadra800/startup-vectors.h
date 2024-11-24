
                .extern accfault_handler
                .extern addrerr_handler
                .extern illinstr_handler
                .extern div0_handler
                .extern chkinstr_handler
                .extern ftrapcc_handler
                .extern privilegev_handler
                .extern trace_handler
                .extern line1010_handler
                .extern line1111_handler
                .extern cprotocolv_handler
                .extern formaterr_handler
                .extern uninitint_handler
                .extern spurious_handler
                .extern l1autovector_handler
                .extern l2autovector_handler
                .extern l3autovector_handler
                .extern l4autovector_handler
                .extern l5autovector_handler
                .extern l6autovector_handler
                .extern l7autovector_handler
                .extern trap0_handler
                .extern trap1_handler
                .extern trap2_handler
                .extern trap3_handler
                .extern trap4_handler
                .extern trap5_handler
                .extern trap6_handler
                .extern trap7_handler
                .extern trap8_handler
                .extern trap9_handler
                .extern trap10_handler
                .extern trap11_handler
                .extern trap12_handler
                .extern trap13_handler
                .extern trap14_handler
                .extern trap15_handler

                .global interrupt_vector_table
interrupt_vector_table:

initialsp:      .long   INITIALSP               // 000 0x0000 -
initialpc:      .long   INITIALPC               // 001 0x0004 -
accfault:       .long   accfault_handler        // 002 0x0008 -
addrerr:        .long   addrerr_handler         // 003 0x000C -
illinstr:       .long   illinstr_handler        // 004 0x0010 -
div0:           .long   div0_handler            // 005 0x0014 -
chkinstr:       .long   chkinstr_handler        // 006 0x0018 -
ftrapcc:        .long   ftrapcc_handler         // 007 0x001C -
privilegev:     .long   privilegev_handler      // 008 0x0020 -
trace:          .long   trace_handler           // 009 0x0024 -
line1010:       .long   line1010_handler        // 010 0x0028 -
line1111:       .long   line1111_handler        // 011 0x002C -
reserved1:      .long   0                       // 012 0x0030 -
cprotocolv:     .long   cprotocolv_handler      // 013 0x0034 -
formaterr:      .long   formaterr_handler       // 014 0x0038 -
uninitint:      .long   uninitint_handler       // 015 0x003C -
reserved2:      .long   0                       // 016 0x0040 -
reserved3:      .long   0                       // 017 0x0044 -
reserved4:      .long   0                       // 018 0x0048 -
reserved5:      .long   0                       // 019 0x004C -
reserved6:      .long   0                       // 020 0x0050 -
reserved7:      .long   0                       // 021 0x0054 -
reserved8:      .long   0                       // 022 0x0058 -
reserved9:      .long   0                       // 023 0x005C -
spurious:       .long   spurious_handler        // 024 0x0060 -
l1autovector:   .long   l1autovector_handler    // 025 0x0064 -
l2autovector:   .long   l2autovector_handler    // 026 0x0068 -
l3autovector:   .long   l3autovector_handler    // 027 0x006C -
l4autovector:   .long   l4autovector_handler    // 028 0x0070 -
l5autovector:   .long   l5autovector_handler    // 029 0x0074 -
l6autovector:   .long   l6autovector_handler    // 030 0x0078 -
l7autovector:   .long   l7autovector_handler    // 031 0x007C -
trap0:          .long   trap0_handler           // 032 0x0080 -
trap1:          .long   trap1_handler           // 033 0x0084 -
trap2:          .long   trap2_handler           // 034 0x0088 -
trap3:          .long   trap3_handler           // 035 0x008C -
trap4:          .long   trap4_handler           // 036 0x0090 -
trap5:          .long   trap5_handler           // 037 0x0094 -
trap6:          .long   trap6_handler           // 038 0x0098 -
trap7:          .long   trap7_handler           // 039 0x009C -
trap8:          .long   trap8_handler           // 040 0x00A0 -
trap9:          .long   trap9_handler           // 041 0x00A4 -
trap10:         .long   trap10_handler          // 042 0x00A8 -
trap11:         .long   trap11_handler          // 043 0x00AC -
trap12:         .long   trap12_handler          // 044 0x00B0 -
trap13:         .long   trap13_handler          // 045 0x00B4 -
trap14:         .long   trap14_handler          // 046 0x00B8 -
trap15:         .long   trap15_handler          // 047 0x00BC -
fpunordcond:    .long   0                       // 048 0x00C0 -
fpinexact:      .long   0                       // 049 0x00C4 -
fpdiv0:         .long   0                       // 050 0x00C8 -
fpundeflow:     .long   0                       // 051 0x00CC -
fpoperror:      .long   0                       // 052 0x00D0 -
fpoverflow:     .long   0                       // 053 0x00D4 -
fpsignan:       .long   0                       // 054 0x00D8 -
fpunimpdata:    .long   0                       // 055 0x00DC unassigned, reserved for MC68020
mmuconferror:   .long   0                       // 056 0x00E0 defined for MC68030 and MC68851, not used by MC68040
mmuilloperror:  .long   0                       // 057 0x00E4 defined for MC68851, not used by MC68030/MC68040
mmuacclevviol:  .long   0                       // 058 0x00E8 defined for MC68851, not used by MC68030/MC68040
reserved10:     .long   0                       // 059 0x00EC -
reserved11:     .long   0                       // 060 0x00F0 -
reserved12:     .long   0                       // 061 0x00F4 -
reserved13:     .long   0                       // 062 0x00F8 -
reserved14:     .long   0                       // 063 0x00FC -

                // User Defined Vectors (192)
                .space  192*4

