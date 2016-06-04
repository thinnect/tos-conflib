/**
 * ConfLib module for int32_t metadata.
 *
 * @author Raido Pahtma
 * @license MIT
 */
generic module ConfParameterMeta_int32_C(int32_t value_min, int32_t value_default, int32_t value_max) {
	provides {
		interface Get<int32_t> as GetDefault;
		interface ConfParameterCheck<int32_t>;
		interface ConfParameterMeta;
	}
}
implementation {

	command int32_t GetDefault.get() {
		return value_default;
	}

	command bool ConfParameterCheck.suitable(int32_t value) {
		// Two comparisions to avoid compiler warning when value_min is the absolute minimum
		return (((value == value_min)||(value > (int32_t)value_min))
				&&(value <= (int32_t)value_max)); // Additionally the sign somehow is lost for long long positive constants
	}

	command uint16_t ConfParameterMeta.get(uint8_t buffer[], uint16_t length) {
		if(length >= 12) {
			int32_t pvmin = value_min;
			int32_t pvdef = value_default;
			int32_t pvmax = value_max;
			reverse_byte_order(&buffer[0], (uint8_t*)&pvmin, 4);
			reverse_byte_order(&buffer[4], (uint8_t*)&pvdef, 4);
			reverse_byte_order(&buffer[8], (uint8_t*)&pvmax, 4);
			return 12;
		}
		return 0;
	}

}
