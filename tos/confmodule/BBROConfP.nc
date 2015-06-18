/**
 * Byte buffer module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
generic module BBROConfP(uint8_t type, uint8_t seq, uint32_t conf_id, char m_value[]) {
	provides {
		interface BBConf;
	}
}
implementation {

	command error_t BBConf.set(uint8_t* value, uint8_t length) {
		return FAIL;
	}

	command uint8_t* BBConf.get() {
		return (uint8_t*)m_value;
	}

	command uint8_t BBConf.length() {
		return sizeof(m_value);
	}

	command uint8_t BBConf.maxLength() {
		return call BBConf.length();
	}

	command uint8_t BBConf.getDefault(uint8_t* buffer, uint8_t length) {
		return 0;
	}

	command uint8_t BBConf.getStorageType() {
		return CPT_STORAGE_READONLY;
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
