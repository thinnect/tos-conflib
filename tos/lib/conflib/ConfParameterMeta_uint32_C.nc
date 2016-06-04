/**
 * ConfLib module for uint32_t metadata.
 *
 * @author Raido Pahtma
 * @license MIT
 */
generic module ConfParameterMeta_uint32_C(uint32_t value_min, uint32_t value_default, uint32_t value_max) {
	provides {
		interface Get<uint32_t> as GetDefault;
		interface ConfParameterCheck<uint32_t>;
		interface ConfParameterMeta;
	}
}
implementation {

	command uint32_t GetDefault.get() {
		return value_default;
	}

	command bool ConfParameterCheck.suitable(uint32_t value) {
		// Two comparisions to avoid compiler warning when value_min is the absolute minimum
		return (((value == value_min)||(value > value_min))
				&&(value <= value_max));
	}

	command uint16_t ConfParameterMeta.get(uint8_t buffer[], uint16_t length) {
		if(length >= 12) {
			uint32_t pvmin = value_min;
			uint32_t pvdef = value_default;
			uint32_t pvmax = value_max;
			reverse_byte_order(&buffer[0], (uint8_t*)&pvmin, 4);
			reverse_byte_order(&buffer[4], (uint8_t*)&pvdef, 4);
			reverse_byte_order(&buffer[8], (uint8_t*)&pvmax, 4);
			return 12;
		}
		return 0;
	}

}
