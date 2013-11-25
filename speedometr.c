#include <mega8.h>
#include <delay.h> 

#define digit1 PORTC.0                     
#define digit2 PORTC.1      
#define digit3 PORTC.2 

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
interrupt [EXT_INT0] void ext_int0_isr(void)
{
i++;
}

// Timer 1 output compare A interrupt service routine
interrupt [TIM1_COMPA] void timer1_compa_isr(void)
{
imp=i;
i=0;
TCNT1=0;
}


// Timer 2 overflow interrupt service routine
interrupt [TIM2_OVF] void timer2_ovf_isr(void)
{
switch (cur_dig)
  {
  case 0:{digit3=0;digit1=1;PORTD=digits[digit_out[cur_dig]];break;}; 
  case 1:{digit1=0;digit2=1;PORTD=digits[digit_out[cur_dig]];break;};
  case 2:{digit2=0;digit3=1;PORTD=digits[digit_out[cur_dig]];break;};
  }
  cur_dig++;   
  if (cur_dig==3) cur_dig=0;
}

// Timer 2 output compare interrupt service routine
interrupt [TIM2_COMP] void timer2_comp_isr(void)
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