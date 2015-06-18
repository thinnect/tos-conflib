/**
 * @author Raido Pahtma
 * @license MIT
*/
#include "ConfTypes.h"
#include <avr/boot.h>
generic module ConfBootLockFuseP(uint8_t seq, uint32_t conf_id) {
	provides {
		interface Conf<uint32_t>;
	}
}
implementation {

	typedef union {
		struct {
			uint8_t extended;
			uint8_t high;
			uint8_t low;
			uint8_t lock;
		} bits;
		uint32_t flat;
	} lockfusebits_t;

	uint32_t getLockFuseBits() {
		lockfusebits_t value;
		value.bits.lock = boot_lock_fuse_bits_get(GET_LOCK_BITS);
		value.bits.low = boot_lock_fuse_bits_get(GET_LOW_FUSE_BITS);
		value.bits.high = boot_lock_fuse_bits_get(GET_HIGH_FUSE_BITS);
		value.bits.extended = boot_lock_fuse_bits_get(GET_EXTENDED_FUSE_BITS);
		return value.flat;
	}

	command uint32_t Conf.minValue() {
		return getLockFuseBits();
	}

	command uint8_t Conf.getSeq() {
		return seq;
	}

	command error_t Conf.set(uint32_t value) {
		return FAIL;
	}

	command uint32_t Conf.get() {
		return getLockFuseBits();
	}

	command uint32_t Conf.getId() {
		return conf_id;
	}

	command uint32_t Conf.getDefault() {
		return getLockFuseBits();
	}

	command uint8_t Conf.getStorageType() {
		return CPT_STORAGE_READONLY;
	}

	command uint8_t Conf.getType() {
		return CPT_UINT32_T;
	}

	command uint32_t Conf.maxValue() {
		return getLockFuseBits();
	}

}
