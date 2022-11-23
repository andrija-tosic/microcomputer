#include <xc.h>
__CONFIG(FOSC_HS & WDTE_OFF & PWRTE_ON & CP_OFF);

#define _XTAL_FREQ 3276800

void display();
void eeprom_init();
void writeB(unsigned char);

unsigned char counter_h = 0;
unsigned char counter_l = 0;
unsigned char val0 = 0;
unsigned char val1 = 0;
unsigned char countdown = 0;


static unsigned char rnd_number = 33;
unsigned char random_next() {
    rnd_number ^= (rnd_number << 5);
    rnd_number ^= (rnd_number >> 3);
    rnd_number ^= (rnd_number << 7);
    return rnd_number;
}

void main(void)
{
	TRISA=0;
	TRISB=0x01;

	eeprom_init();
	PORTB=0x00;
	PORTA=0x00;

	INTCON = 0x30;
	INTCONbits.GIE = 1;

	OPTION_REG=0xC2;

	while (1);
}

void writeB(unsigned char num)
{
	EEADR = 0x02 + num;
	EECON1bits.RD=1;
	PORTB = EEDATA;
}

void eeprom_init() 
{
	int i = 0;
	int j = 2;
	static const int codes[]={ 0x80, 0xF2, 0x48, 0x60, 0x32, 0x24, 0x04, 0xF0, 0x00, 0x20 };
	for (i,j; i < 10; i++, j++) 
	{
		EEADR=j;
		EEDATA=codes[i];
		EECON1bits.WREN=1;
		EECON2=0x55;
		EECON2=0xAA;
		EECON1bits.WR=1;
		__delay_ms(10);
	}
}

void display()
{
	static unsigned char index = 0;
	
	if (countdown == 2) {
		counter_l++;
		if (counter_l == 200) {
			counter_l=0;
			counter_h++;
		}	
	}

	if (index == 1){
		PORTAbits.RA1=1;
		PORTAbits.RA0=0;
		writeB(val0);
		index = 0;
	}
	else {
		PORTAbits.RA0=1;
		PORTAbits.RA1=0;
		writeB(val1);
		index=1;
	}
}

void interrupt prekid(void) 
{
	if(INTCONbits.INTF==1)
	{
		if (countdown == 0) {
			countdown = 1;
			val0 = random_next() % 10;
			val1 = random_next() % 10;
		}
		else if (countdown == 1) {
			countdown = 2;
		}
		else {
			countdown = 0;
		}
		INTCONbits.INTF=0;
	}
	else if (INTCONbits.T0IF == 1){
		if (counter_h == 4 && countdown == 2) {
			if (val0 > 0) val0--;
			else if (val1 > 0) {
				val0=9;
				val1--;
			}
			else {
				countdown = 0;
			}
			counter_h = counter_l = 0;
		} 
		display();
		INTCONbits.T0IF=0;
	}
}