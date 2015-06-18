/**
 * Byte buffer module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
generic module BBConfP(uint8_t type, uint8_t seq, uint32_t conf_id, uint8_t max_length, bool persistent) {
	provides {
		interface BBConf;
		interface BBConfInit;
		interface BBConfDefaults;
	}
}
implementation {

	uint8_t m_value[max_length];
	uint8_t m_length = 0;

	command error_t BBConf.set(uint8_t* value, uint8_t length) {
		if(call BBConfInit.init(value, length) == SUCCESS) {
			signal BBConf.changed(m_value, m_length);
			return SUCCESS;
		}
		return FAIL;
	}

	command uint8_t* BBConf.get() {
		return m_value;
	}

	command uint8_t BBConf.length() {
		return m_length;
	}

	command uint8_t BBConf.maxLength() {
		return max_length;
	}

	command error_t BBConfInit.initDefault() {
		m_length = signal BBConfDefaults.defaultValue(m_value, max_length);
		return SUCCESS;
	}

	command error_t BBConfInit.init(uint8_t* value, uint8_t length) {
		uint16_t maxLength = max_length; // max_length can be 255 and compiler would give a warning in a <= comparison
		if(length <= maxLength) {
			memcpy(m_value, value, length);
			m_length = length;
			return SUCCESS;
		}
		return FAIL;
	}

	command uint8_t BBConf.getDefault(uint8_t* buffer, uint8_t length) {
		return signal BBConfDefaults.defaultValue(buffer, length);
	}

	command uint8_t BBConf.getStorageType() {
		return persistent ? CPT_STORAGE_PERSISTENT : CPT_STORAGE_RAM;
	}

	command uint8_t BBConf.getType() {
		return type;
	}

	command uint32_t BBConf.getId() {
		return conf_id;
	}

	command uint8_t BBConf.getSeq() {
		return seq;
	}

}
