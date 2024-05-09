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

#define R1 4
#define C1 8 
#define R2 8
#define C2 4

void matrixmult(unsigned int input_stimuli[], unsigned int rom_coeff[])
{
	unsigned int sum;
	int i,j,k;
	int x,y;
	int z = 0;
	int t,w;
	int v = 0;
	unsigned int input[R1][C1];
	unsigned int new_rom[R2][C2];

	printf("Multiplication of two matrices is:\n ");  

 
    for (y = 0;y < 8;y++){
		for (x = 0; x < 4; x++){
			input [x][y] = input_stimuli[z];
			z++;
		}
    }

	for (w = 0;w < 4;w++){
		for (t = 0;t < 8;t++){
			new_rom [t][w] = rom_coeff[v];
			v++;
		}

	}

	for (i = 0; i < C2; i++){       
		for (j = 0; j < R1; j++){                 
		     sum = 0;
		     for (k = 0; k < C1; k++){
		         sum += input[i][k] * new_rom[k][j];
		         
		     }
		     printf("%d\t", sum);
		}
		printf("\n");
	}

}

int main()
{

	unsigned int input_stimuli[] = {
	103, 115, 16, 116, 80, 12, 35, 69, 122, 123, 20, 123, 122, 62, 102, 18, 54, 116, 101, 122, 83, 5, 108, 119, 86, 96, 94, 50, 83, 22, 90, 4, // x11, x12, x13, x14...
	35, 6, 12, 105, 88, 40, 121, 4, 56, 48, 97, 101, 24, 62, 57, 82, 90, 96, 35, 86, 83, 21, 15, 63, 122, 43, 74, 28, 95, 32, 64, 89, 
	113, 122, 69, 18, 19, 33, 107, 32, 103, 31, 118, 44, 25, 32, 78, 60, 45, 106, 74, 70, 116, 36, 96, 96, 48, 72, 10, 7, 67, 99, 119, 16, 
	72, 60, 2, 43, 21, 101, 40, 67, 21, 76, 33, 83, 88, 95, 57, 11, 29, 116, 19, 105, 68, 127, 10, 56, 14, 122, 1, 98, 104, 110, 11, 51, 
	33, 102, 55, 116, 23, 34, 18, 17, 110, 74, 70, 18, 108, 79, 45, 65, 51, 10, 30, 16, 23, 30, 53, 6, 115, 120, 62, 62, 43, 114, 47, 14
	};



	unsigned int rom_coeff[] = { 
	3, 22, 11, 1, 8, 3, 1, 2,  // a11, a21, a31, a41....
	8, 15, 2, 4, 12, 6, 1, 2, 
	18, 40, 3, 2, 16, 9, 1, 2, 
	1, 10, 4, 0, 2, 12, 1, 2 
	};

	int c;

	for (c = 0; c < 5; c++){
		matrixmult(input_stimuli + (32 * c),rom_coeff);
	}

return 0;

}





