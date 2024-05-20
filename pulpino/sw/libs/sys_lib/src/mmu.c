#include "mmu.h"

void __attribute__ ((optimize("-O0"))) mmu_start(int num_mat)
{
    MMCR = (num_mat << 1) | 1;
}

int __attribute__ ((optimize("-O0"))) mmu_done(void)
{
    return ((MMSR & 0x01) == 1);
}

void __attribute__ ((optimize("-O0"))) mmu_load_input(char *input_elems, short num_mat)
{
    for (short i = 0; i < num_mat*32; i+=4) {
        MMIN(i>>2) = ((int)input_elems[i] << 24) | ((int)input_elems[i+1] << 16) | ((int)input_elems[i+2] << 8) | ((int)input_elems[i+3]);
    }
}

void __attribute__ ((optimize("-O0"))) mmu_get_output(int *result, short num_mat)
{
    for (short i = 0; i < num_mat*16; i++) {
        result[i] = MMOT(i);
    }
}
