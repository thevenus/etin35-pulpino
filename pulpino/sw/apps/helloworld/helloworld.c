// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


#include <stdio.h>

#include "timer.h"

char input_stimuli[] = {
  103, 115, 16, 116, 80, 12, 35, 69, 122, 123, 20, 123, 122, 62, 102, 18, 54, 116, 101, 122, 83, 5, 108, 119, 86, 96, 94, 50, 83, 22, 90, 4, // x11, x12, x13, x14...
  35, 6, 12, 105, 88, 40, 121, 4, 56, 48, 97, 101, 24, 62, 57, 82, 90, 96, 35, 86, 83, 21, 15, 63, 122, 43, 74, 28, 95, 32, 64, 89, 
  113, 122, 69, 18, 19, 33, 107, 32, 103, 31, 118, 44, 25, 32, 78, 60, 45, 106, 74, 70, 116, 36, 96, 96, 48, 72, 10, 7, 67, 99, 119, 16, 
  72, 60, 2, 43, 21, 101, 40, 67, 21, 76, 33, 83, 88, 95, 57, 11, 29, 116, 19, 105, 68, 127, 10, 56, 14, 122, 1, 98, 104, 110, 11, 51, 
  33, 102, 55, 116, 23, 34, 18, 17, 110, 74, 70, 18, 108, 79, 45, 65, 51, 10, 30, 16, 23, 30, 53, 6, 115, 120, 62, 62, 43, 114, 47, 14
};

int mmu_calc()
{
  int mmu_start = 0x1A103000;
  int mmu_indata_start = 0x1A103100;
  int mmu_outdata_start = 0x1A103200;

  // for (int i = 0; i < 10000000; i++);

  // int temp = 0;
  // for (char i=0; i<160; i++) {
  //   temp = temp | (input_stimuli[i] << (24-(i%4)*8));
  //   if (i % 4 == 0) {
  //     *(volatile int*) (mmu_indata_start+i) = temp;
  //   }

  //   // *(volatile int*) (mmu_indata_start+i) = (input_stimuli[i] << 24) | (input_stimuli[i+1] << 16) | (input_stimuli[i+2] << 8) | (input_stimuli[i+3]);
  // }

  for (char i=0; i<96; i=i+4) {
    *(int*) (mmu_indata_start+i) = (input_stimuli[i] << 24) | (input_stimuli[i+1] << 16) | (input_stimuli[i+2] << 8) | (input_stimuli[i+3]);
  }

  // for (char i=0; i<64; i=i+4) {
  //   *(volatile int*) (mmu_indata_start+i) = (input_stimuli[i] << 24) | (input_stimuli[i+1] << 16) | (input_stimuli[i+2] << 8) | (input_stimuli[i+3]);
  // }
  // for (char i=64; i<128; i=i+4) {
  //   *(volatile int*) (mmu_indata_start+i) = (input_stimuli[i] << 24) | (input_stimuli[i+1] << 16) | (input_stimuli[i+2] << 8) | (input_stimuli[i+3]);
  // }
  // for (char i=128; i<160; i=i+4) {
  //   *(volatile int*) (mmu_indata_start+i) = (input_stimuli[i] << 24) | (input_stimuli[i+1] << 16) | (input_stimuli[i+2] << 8) | (input_stimuli[i+3]);
  // }

  *(volatile int*) (mmu_start) = 0x0000000B;

  while (*(volatile int*) (mmu_start+4) != 1);

  for (char i = 0; i < 80; i++) {
    printf("%d\n", *(volatile int*)(mmu_outdata_start + i*4));
  }

  return 0;
}


int main()
{
  mmu_calc();

  // int a, b, c;
  // a = 5;
  // b = 6; 
  // c = 7;

  // int d, e, f;
  // d = a+b;
  // e = a-b-c;
  // f = a*b*c;
  // printf("%d + %d = %d\n", a, b, d);
  // printf("%d - %d - %d = %d\n", a, b, c, e);
  // printf("%d * %d * %d = %d\n", a, b, c, f);

  return 0;
}
