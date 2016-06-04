/**
 * Structures for 128bit UUID.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#ifndef UUID128_H_
#define UUID128_H_

enum { UUID128_LENGTH = 16 };

typedef struct uuid128_t {
  uint8_t data[UUID128_LENGTH];
} uuid128_t;

typedef nx_struct nx_uuid128_t {
  nx_uint8_t data[UUID128_LENGTH];
} nx_uuid128_t;

#endif // UUID128_H_
