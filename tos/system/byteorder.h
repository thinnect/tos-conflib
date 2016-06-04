/**
 * Reverse byte order for arbitrary number of bytes.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#ifndef BYTEORDER_H_
#define BYTEORDER_H_

/*
 * Swaps bytes.
 */
void reverse_byte_order(uint8_t* destination, uint8_t* source, uint8_t length) {
	uint8_t i;
	for(i=0;i<length;i++) {
		destination[i] = source[length - i - 1];
	}
}

#endif // BYTEORDER_H_
