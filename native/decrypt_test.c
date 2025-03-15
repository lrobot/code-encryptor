#include <stdio.h>

#include "core_de.h"
#include "core_en.h"

void printHex(const unsigned char *arr, int length, char* desc) {
    printf("----hex for:%s: \n", desc);
    for (int i = 0; i < length; i++) {
        printf("%02X", arr[i]);
    }
    printf("\n");
}

#define ARRAY_SIZE 20
int main() {
    unsigned char code[ARRAY_SIZE] = {
            0xca, 0xfe, 0xba, 0xbe,
            0x11, 0x22, 0x33, 0x05,
            0x01, 0x02, 0x03, 0x04,
            0x05, 0x06, 0x07, 0x08,
            0x09, 0x0A, 0x0B, 0x0C,
    };
    printHex(code, ARRAY_SIZE, "before");
    encrypt(code, ARRAY_SIZE);
    printHex(code, ARRAY_SIZE, "after encrypt");
    decrypt(code, ARRAY_SIZE);
    printHex(code, ARRAY_SIZE, "after decrypt");
}
