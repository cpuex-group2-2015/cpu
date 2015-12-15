#include <stdio.h>

int main(int argc, char *argv[]) {
	FILE *dst, *src;
	char line[34];
	int count = 0;

	if (argc == 1 || argc > 3) {
		printf("print_coe source [destination]\n");
		return 0;
	} else if (argc == 2) {
		if ((dst = fopen("out.coe", "w")) == NULL) {
			perror("fopen");
			return 1;
		}
	} else if (argc == 3) {
		if ((dst = fopen(argv[2], "w")) == NULL) {
			perror("fopen");
			return 1;
		}
	}

	if ((src = fopen(argv[1], "r")) == NULL) {
		perror("fopen");
		return 1;
	}

	fprintf(dst, "MEMORY_INITIALIZATION_RADIX=2;\n");
	fprintf(dst, "MEMORY_INITIALIZATION_VECTOR=\n");

	while (fgets(line, 34, src) != NULL) {
		line[32] = '\0';
		fprintf(dst, "%s,\n", line);
		count++;
	}

	while (count < 16383) {
		fprintf(dst, "00000000000000000000000000000000,\n");
		count++;
	}

	fprintf(dst, "00000000000000000000000000000000;\n");

	fclose(src);

	return 0;
}