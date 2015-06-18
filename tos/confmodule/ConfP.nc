/**
 * Configurable parameter module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include <limits.h>
#include "ConfTypes.h"
generic module ConfP(typedef conf_type @integer(), uint8_t seq, uint32_t conf_id, uint8_t type_id, bool persistent) {
	provides {
		interface Conf<conf_type>;
		interface ConfInit<conf_type>;
		interface ConfDefaults<conf_type>;
	}
}
implementation {

	conf_type m_value = 0;

	command error_t Conf.set(conf_type value) {
		if(call ConfInit.init(value) == SUCCESS) {
			signal Conf.changed(m_value);
			return SUCCESS;
		}
		return FAIL;
	}

	command conf_type Conf.get() {
		return m_value;
	}

	command conf_type Conf.getDefault() {
		return signal ConfDefaults.defaultValue();
	}

	command uint8_t Conf.getStorageType() {
		return persistent ? CPT_STORAGE_PERSISTENT : CPT_STORAGE_RAM;
	}

	command uint8_t Conf.getType() {
		return type_id;
	}

	command uint32_t Conf.getId() {
		return conf_id;
	}

	command uint8_t Conf.getSeq() {
		return seq;
	}

	command error_t ConfInit.initDefault() {
		m_value = signal ConfDefaults.defaultValue();
		return SUCCESS;
	}

	command error_t ConfInit.init(conf_type value) {
		if(value <= signal ConfDefaults.maxValue()) {
			if(value >= signal ConfDefaults.minValue()) {
				m_value = value;
				return SUCCESS;
			}
		}
		return FAIL;
	}

	command conf_type Conf.maxValue() {
		return signal ConfDefaults.maxValue();
	}

	command conf_type Conf.minValue() {
		return signal ConfDefaults.minValue();
	}

	// Default values chosen to support both int32 and uint32
	default event conf_type ConfDefaults.minValue() {
		return 0;
	}

	default event conf_type ConfDefaults.maxValue() {
		return (conf_type)LONG_MAX;
	}

	default event conf_type ConfDefaults.defaultValue() {
		return 0;
	}

}
