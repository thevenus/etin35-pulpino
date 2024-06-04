#include "pconv.h"

void pconv_start()
{
    CNCR = 0x01;
}

uint8_t pconv_done()
{
    return ((CNSR & 0x01) == 1);
}

void pconv_load_filter(uint8_t* kernel)
{
    // CNFTRA = kernel[0] << 
}

void pconv_load_input(uint8_t* input)
{

}

void pconv_get_output(uint8_t* results)
{

}