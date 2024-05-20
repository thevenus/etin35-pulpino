/**
 * @file
 * @brief MMU Library.
 *
 * Provides MMU functions like writing input matrix to 
 * the corresponding registers, starting calculations,
 * fetching output results and so on.
 *
 * @author Florian Zaruba
 *
 * @version 1.0
 *
 * @date 2/10/2015
 *
 */
#ifndef __MMU_H__
#define __MMU_H__

#include "pulpino.h"

#define MMU_CTRL         0x000
#define MMU_STATUS       0x004
#define MMU_INDATA       0x100
#define MMU_OUTDATA      0x200

/* pointer to mem of MM unit - PointerTimer */
#define __PT__(a) *(volatile int*) (TIMER_BASE_ADDR + a)

/** MMU Control Register */
#define MMCR __PT__(MMU_CTRL)

/** MMU Status Register */
#define MMSR __PT__(MMU_STATUS)

/** MMU Input Data Register */
#define MMIN(i) __PT__(MMU_INDATA + ((i)<<2))

/** MMU Output Data Register */
#define MMOT(i) __PT__(MMU_OUTDATA + ((i)<<2))

void mmu_start(int num_mat);

int mmu_done(void);

void mmu_load_input(char *input_elems, short num_mat);

void mmu_get_output(int *result, short num_mat);

#endif
