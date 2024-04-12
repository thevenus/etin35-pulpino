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
  int a, b, c;
  a = 5;
  b = 6; 
  c = 7;

  int d, e, f;
  d = a+b;
  e = a-b-c;
  f = a*b*c;
  printf("%d + %d = %d\n", a, b, d);
  printf("%d - %d - %d = %d\n", a, b, c, e);
  printf("%d * %d * %d = %d\n", a, b, c, f);

  return 0;
}
