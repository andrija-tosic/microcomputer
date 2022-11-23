#define _XTAL_FREQ 3276800

#include <htc.h>
#include <xc.h>
#define RS PORTBbits.RB1
#define EN PORTBbits.RB2
#define D4 PORTBbits.RB3
#define D5 PORTBbits.RB4
#define D6 PORTBbits.RB5
#define D7 PORTBbits.RB6
#include "lcd.h"

__CONFIG(FOSC_HS & WDTE_OFF & PWRTE_ON & CP_OFF);


void eeprom_init();
char provera();
void interrupt prekid();

char cifra;

static char cifre[4];

static const char codes[4]={ 0, 0, 1, 3 };

char counter = 0;

void main(void)
{
	TRISA=0x03;
	TRISB=0x01;

	eeprom_init();
	PORTB=0x00;
	PORTA=0x00;

	INTCON = 0x10;
	INTCONbits.GIE = 1;

	OPTION_REG=0x80;

	Lcd_Init();

	while (1);
}

void eeprom_init() 
{
	int i = 0, j = 3;
    for (i,j; i < 4; j++, i++) {
        EEADR = j;
        EEDATA = codes[i];
        EECON1bits.WREN=1;
        EECON2 = 0x55;
        EECON2 = 0xAA;
        EECON1bits.WR = 1;
        __delay_ms(30);
    }
}

char provera() {
	char i;
	for (i=0;i<4;i++) {
		EEADR = 0x03 + i;
		EECON1bits.RD=1;
		char cifra = EEDATA;
	
		if (cifra != cifre[i])
			return 0;
		}
	return 1;
}

void interrupt prekid(void) 
{
	if(INTCONbits.INTF == 1)
	{
			cifre[counter] = PORTAbits.RA0 + 2*PORTAbits.RA1;
			Lcd_Set_Cursor(1, counter+1);
			Lcd_Write_Char(cifre[counter] + '0');
			counter++;

		if (counter == 4) {
			if (provera()) {
				PORTAbits.RA3 = 1;
			}
			else{
				PORTAbits.RA2 = 1;
			}
			counter = 0;
			
			__delay_ms(3000);
			Lcd_Clear();
			PORTA = 0;
		}


		INTCONbits.INTF = 0;

	}
}