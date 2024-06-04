#include <stdio.h>

#include "pconv.h"
#include "pconv_demo.h"
#include "stimuli/ifm.h"
#include "stimuli/w.h"
#include "stimuli/expected_ofm.h"

char calculated_ofm[784];

int __attribute__ ((optimize("-O0"))) main ()
{
    // pconv_load_filter(w);
    // pconv_load_input(ifm);
    // pconv_start();
    // pconv_get_output(calculated_ofm);

    // for (char i = 0; i < 784; i++) {
    //     if (calculated_ofm[i] != expected_ofm[i]) {
    //         printf("The result is wrong!");
    //         return 0;
    //     }
    // }

    // loop through each channel
    for (int ch = 0; ch < 3; ch++) {
        // load the filter
        int tmp = 0;
        int filt_ch = ch*25;
        for (int i = filt_ch; i < filt_ch + 25; i++) {
            tmp = (tmp << 3) | w[i];
            if (i == filt_ch + 9) {
                CNFTRA = tmp;
                tmp = 0;
            } else if (i == filt_ch + 19) {
                CNFTRB = tmp;
                tmp = 0;
            } else if (i == filt_ch + 24) {
                CNFTRC = tmp;
                tmp = 0;
            }
        }

        // printf("%x %x %x\n", CNFTRA, CNFTRB, CNFTRC);
        // loop through every row of input
        for (int row = 0; row < 28; row++) {
            int ifm_offset = ch*784 + row*28;
            int tmp = 0;
            
            // load one row
            for (int col = 0; col < 28; col++) {
                tmp = (tmp << 3) | ifm[ifm_offset + col];

                if ((col == 9) || (col == 19) || (col == 27)) {
                    CNINR = tmp;
                    tmp = 0;
                }
            }

            if (row >= 2) {
                // set the start bit if row >= 2
                CNCR = 0x01;

                // wait for row done
                while (!(CNSR & 2));
            }
        }

        // wait for channel done
        while (!(CNSR & 4));
    }
    
    // wait for the done signal
    while (!(CNSR & 1));

    // load output data registers into here
    int tmp = 0;
    for (int i = 0; i < 196; i++) {
        tmp = REG(CONV_OUTPUT + i*4);
        calculated_ofm[i*4] = tmp & 0xFF;
        calculated_ofm[i*4+1] = (tmp >> 8) & 0xFF;
        calculated_ofm[i*4+2] = (tmp >> 16) & 0xFF;
        calculated_ofm[i*4+3] = (tmp >> 24) & 0xFF;
    }

    for (int i = 0; i < 784; i++) {
        if (expected_ofm[i] != calculated_ofm[i]) {
            printf("The result is WRONG!\n");
            printf("%d: expected=%d, actual=%d\n", i, expected_ofm[i], calculated_ofm[i]);
            return 0;
        }
    }

    printf("The result is right!\n");

    return 0;
}