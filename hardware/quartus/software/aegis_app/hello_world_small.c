#include <unistd.h>
#include "system.h"
#include "io.h"
#include "sys/alt_stdio.h"
#define LED_COUNT 10
#define ALL_LEDS_ON 0x3FF
#define STEP_DELAY_MICROSECONDS 200000

int main(){
	int led_index = 0;
	alt_putstr("AEGIS: base system started\n");
	while(1){
		if(IORD(SWITCH_BASE,0)&0x1){
			IOWR(LED_BASE,0,ALL_LEDS_ON);
		}
		else{
			IOWR(LED_BASE,0,1<<led_index);
			led_index = (led_index + 1)%LED_COUNT;
		}
		usleep(STEP_DELAY_MICROSECONDS);
	}
	return 0;
}
