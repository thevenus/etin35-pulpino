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

int main()
{

  int x = 354;
  int y = 983;
  int z = 1727;

  int a,b,c,d;

  a = x*y;
  b = x+z;
  c = z/x;
  d = z-y;

  printf("Multiply is %d\nAdd is %d\nDivide is %d\nSubtract is %d\n",a,b,c,d);
  //printf("Simon, Fuad, Viktor\n");
  return 0;
}
