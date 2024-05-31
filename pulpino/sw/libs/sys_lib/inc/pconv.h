#ifndef __CONV_H__
#define __CONC_H__

#include <stdint.h>
#include "pulpino.h"

// Register address definitions
#define CONV_BASE_ADDR          ( TIMER_BASE_ADDR + 0x500 )

#define CONV_CTRL               ( CONV_BASE_ADDR + 0x00   ) 
#define CONV_STATUS             ( CONV_BASE_ADDR + 0x04   )
#define CONV_INPUT              ( CONV_BASE_ADDR + 0x08   )
#define CONV_OUTPUT             ( CONV_BASE_ADDR + 0x0C   )
#define CONV_FILT1              ( CONV_BASE_ADDR + 0x400  )
#define CONV_FILT2              ( CONV_BASE_ADDR + 0x404  )
#define CONV_FILT3              ( CONV_BASE_ADDR + 0x408  )

/* Convolution Control Register */
#define CNCR        REG(CONV_CTRL)

/* Convolution Status Register */
#define CNSR        REG(CONV_STATUS)

/* Convolution Input Data Register */
#define CNINR       REG(CONV_INPUT)

/* Convolution Output Data Register */
#define CNOTR       REG(CONV_OUTPUT)

/* Convolution Filter Data Registers */
#define CNFTRA       REG(CONV_FILT1)
#define CNFTRB       REG(CONV_FILT2)
#define CNFTRC       REG(CONV_FILT3)

// ======= Functions ===============

void pconv_start();

uint8_t pconv_done();

void pconv_load_filter(uint8_t* kernel);

void pconv_load_input(uint8_t* input);

void pconv_get_output(uint8_t* results);


#endif
