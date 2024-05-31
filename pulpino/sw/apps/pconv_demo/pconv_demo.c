#include <stdio.h>

#include "pconv.h"
#include "pconv_demo.h"
#include "stimuli/ifm.h"
#include "stimuli/w.h"
#include "stimuli/expected_ofm.h"

char calculated_ofm[784];

int main ()
{
    pconv_load_filter(w);
    pconv_load_input(ifm);
    pconv_start();
    pconv_get_output(calculated_ofm);

    for (char i = 0; i < 784; i++) {
        if (calculated_ofm[i] != expected_ofm[i]) {
            printf("The result is wrong!");
            return 0;
        }
    }

    printf("The result is right!");

    return 0;
}