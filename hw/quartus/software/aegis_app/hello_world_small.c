#include <unistd.h>
#include "system.h"
#include "io.h"
#include "sys/alt_stdio.h"

int main(){
	int i=0;
	alt_putstr("AEGIS: base system started\n");
	while(1){
		if(IORD(SW_BASE,0)&0x1){
			IOWR(LED_BASE,0,0x3FF);
		}
		else{
			IOWR(LED_BASE,0,1<<i);
			i=(i + 1)%10;
		}
		usleep(200000);
	}
	return 0;
}
