/*
 * Human-readable RV32I source corresponding to the program stored as
 * machine-code words in rtl/simple_ram.v.
 *
 * Memory map:
 *   0x03000000 LED output
 *   0x03000004 switches
 *   0x03000008 left button (submit)
 *   0x0300000C right button (clear result)
 *   0x03000010 pseudo-random target
 */

    .section .text
    .globl _start

_start:
    lui   x1, 0x03000          /* x1 = 0x03000000 */

main_loop:
    lw    x6, 12(x1)           /* BTN_RIGHT */
    andi  x6, x6, 1
    bne   x6, x0, reset_leds

    lw    x5, 8(x1)            /* BTN_LEFT */
    andi  x5, x5, 1
    beq   x5, x0, main_loop

    lw    x2, 4(x1)            /* guess = SW[3:0] */
    andi  x2, x2, 15
    lw    x3, 16(x1)           /* target */

    blt   x2, x3, too_small
    blt   x3, x2, too_large

    addi  x4, x0, 1            /* LED0: correct */
write_led:
    sw    x4, 0(x1)

wait_left_release:
    lw    x5, 8(x1)
    andi  x5, x5, 1
    bne   x5, x0, wait_left_release
    jal   x0, main_loop

too_small:
    addi  x4, x0, 2            /* LED1: too small */
    sw    x4, 0(x1)
    jal   x0, wait_left_release

too_large:
    addi  x4, x0, 4            /* LED2: too large */
    sw    x4, 0(x1)
    jal   x0, wait_left_release

reset_leds:
    sw    x0, 0(x1)

wait_right_release:
    lw    x6, 12(x1)
    andi  x6, x6, 1
    bne   x6, x0, wait_right_release
    jal   x0, main_loop
