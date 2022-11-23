#include <xc.h>
__CONFIG(FOSC_HS & WDTE_OFF & PWRTE_ON & CP_OFF);

#define _XTAL_FREQ 3276800

static const char codes[]={0xC0, 0xF9, 0xA4, 0xB0};

void main(void)
{
	TRISA=0;
	TRISB=0x00;

	PORTB=0x00;
	PORTA=0x00;

	int br;

	while(1) {
		
		if (PORTAbits.RA2 == 1) {
			br = 0;		
			br += PORTAbits.RA0;
			br += 2 * PORTAbits.RA1;

			PORTB = codes[br];
		}
	}
}
