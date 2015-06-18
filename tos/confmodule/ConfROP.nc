/**
 * @author Raido Pahtma
 * @license MIT
*/
#include "ConfTypes.h"
generic module ConfROP(uint8_t seq, uint32_t conf_id, uint32_t m_value) {
	provides {
		interface Conf<uint32_t>;
	}
}
implementation {

	command uint32_t Conf.minValue() {
		return m_value;
	}

	command uint8_t Conf.getSeq() {
		return seq;
	}

	command error_t Conf.set(uint32_t value) {
		return FAIL;
	}

	command uint32_t Conf.get() {
		return m_value;
	}

	command uint32_t Conf.getId() {
		return conf_id;
	}

	command uint32_t Conf.getDefault() {
		return m_value;
	}

	command uint8_t Conf.getStorageType() {
		return CPT_STORAGE_READONLY;
	}

	command uint8_t Conf.getType() {
		return CPT_UINT32_T;
	}

	command uint32_t Conf.maxValue() {
		return m_value;
	}

}
