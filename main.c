/* Equivalent high-level description of the RV32I program in simple_ram.v. */
#define LED_REG     (*(volatile unsigned int *)0x03000000u)
#define SW_REG      (*(volatile unsigned int *)0x03000004u)
#define BTN_LEFT    (*(volatile unsigned int *)0x03000008u)
#define BTN_RIGHT   (*(volatile unsigned int *)0x0300000Cu)
#define TARGET_REG  (*(volatile unsigned int *)0x03000010u)

int main(void)
{
    while (1) {
        if (BTN_RIGHT & 1u) {
            LED_REG = 0u;
            while (BTN_RIGHT & 1u) { }
        }

        if (BTN_LEFT & 1u) {
            unsigned int guess = SW_REG & 0xFu;
            unsigned int target = TARGET_REG & 0xFu;

            if (guess < target)
                LED_REG = 2u;
            else if (guess > target)
                LED_REG = 4u;
            else
                LED_REG = 1u;

            while (BTN_LEFT & 1u) { }
        }
    }
}
