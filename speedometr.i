// CodeVisionAVR C Compiler
// (C) 1998-2004 Pavel Haiduc, HP InfoTech S.R.L.
// I/O registers definitions for the ATmega8
#pragma used+
#pragma used+
sfrb TWBR=0;
sfrb TWSR=1;
sfrb TWAR=2;
sfrb TWDR=3;
sfrb ADCL=4;
sfrb ADCH=5;
sfrw ADCW=4;      // 16 bit access
sfrb ADCSRA=6;
sfrb ADMUX=7;
sfrb ACSR=8;
sfrb UBRRL=9;
sfrb UCSRB=0xa;
sfrb UCSRA=0xb;
sfrb UDR=0xc;
sfrb SPCR=0xd;
sfrb SPSR=0xe;
sfrb SPDR=0xf;
sfrb PIND=0x10;
sfrb DDRD=0x11;
sfrb PORTD=0x12;
sfrb PINC=0x13;
sfrb DDRC=0x14;
sfrb PORTC=0x15;
sfrb PINB=0x16;
sfrb DDRB=0x17;
sfrb PORTB=0x18;
sfrb EECR=0x1c;
sfrb EEDR=0x1d;
sfrb EEARL=0x1e;
sfrb EEARH=0x1f;
sfrw EEAR=0x1e;   // 16 bit access
sfrb UBRRH=0x20;
sfrb UCSRC=0X20;
sfrb WDTCR=0x21;
sfrb ASSR=0x22;
sfrb OCR2=0x23;
sfrb TCNT2=0x24;
sfrb TCCR2=0x25;
sfrb ICR1L=0x26;
sfrb ICR1H=0x27;
sfrw ICR1=0x26;   // 16 bit access
sfrb OCR1BL=0x28;
sfrb OCR1BH=0x29;
sfrw OCR1B=0x28;  // 16 bit access
sfrb OCR1AL=0x2a;
sfrb OCR1AH=0x2b;
sfrw OCR1A=0x2a;  // 16 bit access
sfrb TCNT1L=0x2c;
sfrb TCNT1H=0x2d;
sfrw TCNT1=0x2c;  // 16 bit access
sfrb TCCR1B=0x2e;
sfrb TCCR1A=0x2f;
sfrb SFIOR=0x30;
sfrb OSCCAL=0x31;
sfrb TCNT0=0x32;
sfrb TCCR0=0x33;
sfrb MCUCSR=0x34;
sfrb MCUCR=0x35;
sfrb TWCR=0x36;
sfrb SPMCR=0x37;
sfrb TIFR=0x38;
sfrb TIMSK=0x39;
sfrb GIFR=0x3a;
sfrb GICR=0x3b;
sfrb SPL=0x3d;
sfrb SPH=0x3e;
sfrb SREG=0x3f;
#pragma used-
// Interrupt vectors definitions
// Needed by the power management functions (sleep.h)
#asm
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif
#endasm
// CodeVisionAVR C Compiler
// (C) 1998-2000 Pavel Haiduc, HP InfoTech S.R.L.
#pragma used+
#pragma used+
void delay_us(unsigned int n);
void delay_ms(unsigned int n);
#pragma used-
flash char digits[] = {
0b00001000,                   //0
0b11101001,                   //1
0b00010001,                   //2
0b01000001,                   //3
0b11100000,                   //4  digits for anode
0b01000010,                   //5
0b00000010,                   //6
0b01101001,                   //7
0b00000000,                   //8
0b01000000,                   //9
0b11111011,                   //none 10
0b01111011,                   //a    11
0b11111001,                   //b    12
0b11101011,                   //c    13
0b11011011,                   //d  discrete segments
0b10111011,                   //e    15
0b11111010                    //f    16
};
char digit_out[3], cur_dig ;
unsigned int indication;
unsigned int i;
unsigned int imp;
int x, y;
 void recoding(void) 
 {       
 if (indication<1000) 
 {                         
 digit_out[0]=indication%10;   
 indication=indication/10;     
 digit_out[1]=indication%10;
 indication=indication/10;     
 digit_out[2]=indication%10;
 indication=indication/10;
 }
 } 
// External Interrupt 0 service routine
interrupt [2] void ext_int0_isr(void)
{
i++;
}
// Timer 1 output compare A interrupt service routine
interrupt [7] void timer1_compa_isr(void)
{
imp=i;
i=0;
TCNT1=0;
}
// Timer 2 overflow interrupt service routine
interrupt [5] void timer2_ovf_isr(void)
{
switch (cur_dig)
  {
  case 0:{PORTC.2 =0;PORTC.0                     =1;PORTD=digits[digit_out[cur_dig]];break;}; 
  case 1:{PORTC.0                     =0;PORTC.1      =1;PORTD=digits[digit_out[cur_dig]];break;};
  case 2:{PORTC.1      =0;PORTC.2 =1;PORTD=digits[digit_out[cur_dig]];break;};
  }
  cur_dig++;   
  if (cur_dig==3) cur_dig=0;
}
// Timer 2 output compare interrupt service routine
interrupt [4] void timer2_comp_isr(void)
{
PORTC=0x00;
}
// Declare your global variables here
void main(void)
{
// Declare your local variables here
// Input/Output Ports initialization
// Port B initialization
PORTB=0x00;
DDRB=0x00;
// Port C initialization 
PORTC=0x00;
DDRC=0x07;
// Port D initialization
PORTD=0x04;
DDRD=0xFB;
// Timer/Counter 1 initialization
TCCR1A=0x00;
TCCR1B=0x05;
TCNT1=0x0000;
ICR1H=0x00;
ICR1L=0x00;
OCR1AH=0x1E;
OCR1AL=0x84;
OCR1BH=0x00;
OCR1BL=0x00;
// Timer/Counter 2 initialization
ASSR=0x00;
TCCR2=0x04;
TCNT2=0x00;
OCR2=0x80;  // PWM value
// External Interrupt(s) initialization
GICR|=0x40;
MCUCR=0x02;
GIFR=0x40;
// Timer(s)/Counter(s) Interrupt(s) initialization
TIMSK=0x40;
// Analog Comparator initialization
ACSR=0x80;
SFIOR=0x00;
i=0;
// Global enable interrupts
#asm("sei")
for (y=0;y<3;y++)
{
  for (x=11;x<17;x++)
  {
    digit_out[0]=x;
    digit_out[1]=x;
    digit_out[2]=x;
    delay_ms(50);
  }
}
TIMSK=0x50;
while (1)
{
  if (PINB.0==1) TIMSK=0xD0;
  else TIMSK=0x50;
  indication=(imp*36)/40;  //20 - 4 imp/m, 30 - 6 imp/m, 40 - 8 imp/m
  recoding();
}
}
