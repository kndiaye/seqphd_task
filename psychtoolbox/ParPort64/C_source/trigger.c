/*
 * example.c: very simple example of port I/O
 *
 * This code does nothing useful, just a port write, a pause,
 * and a port read. Compile with `gcc -O2 -o trigger trigger.c',
 * and run as root with `./trigger'.
 */
#include <sys/ioctl.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <linux/ppdev.h>
#include <linux/parport.h>

int main(int argc, char *argv[])
{
    unsigned char trig = 0xFF;
    int pport = open("/dev/parport0", O_RDWR);
    
    if(argc > 1)
    {
        trig = atoi(argv[1]);
        //      printf("Trigger %d 0x%x\n", trig, trig);
    }
    if (pport >= 0)
    {
        if (ioctl(pport, PPCLAIM) < 0)
        {
            fprintf(stderr,"PPCLAIM ioctl Error : %s (%d)\n",
                    strerror(errno),errno);
            exit(errno);
        }
        if (ioctl (pport, PPWDATA, &trig) < 0)
        {
            fprintf(stderr,"PPWDATA ioctl Error : %s (%d)\n",
                    strerror(errno),errno);
            exit(errno);
        }
        // make 3 millisecond pulse (2 too short, 5 unnecessary)
        usleep(3000);
        trig = 0;
        ioctl (pport, PPWDATA, &trig);
        
        if (ioctl(pport, PPRELEASE) < 0)
        {
            fprintf(stderr,"PPRELEASE ioctl Error : %s (%d)\n",
                    strerror(errno),errno);
            exit(errno);
        }
        
        if(close(pport) < 0)
        {
            fprintf(stderr,"Close Error : %s (%d)\n",
                    strerror(errno),errno);
            exit(errno);
        }
    }
    else
        perror("trigger");
}

/* end of trigger.c */
