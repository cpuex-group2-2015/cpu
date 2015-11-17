#include <stdio.h>

void print_m_bit_bin_of_n(int n, int m) {

	if (m > 1) {
		print_m_bit_bin_of_n(n >> 1, m - 1);
	}

	printf("%d", n % 2);

	return;
}

void print_onetwothree() {
	int i;

	printf("MEMORY_INITIALIZATION_RADIX=2;\n");
	printf("MEMORY_INITIALIZATION_VECTOR=\n");

	for (i = 0; i < 16384 - 1; i++) {
		print_m_bit_bin_of_n(i, 32);
		printf(",\n");
	}

	print_m_bit_bin_of_n(i, 32);
	printf(";\n");

	return;
}

void print_zero() {
	int i;

	printf("MEMORY_INITIALIZATION_RADIX=2;\n");
	printf("MEMORY_INITIALIZATION_VECTOR=\n");

	for (i = 0; i < 16384 - 1; i++) {
		printf("00000000000000000000000000000000,\n");
	}

	printf("00000000000000000000000000000000;\n");

	return;
}

int main(int argc, char *argv[]) {

	print_zero();

	return 0;
}