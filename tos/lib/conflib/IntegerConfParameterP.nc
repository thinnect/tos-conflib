/**
 * ConfLib integer storage module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
 #include "ConfLib.h"
 #include "uuid128.h"
 #include "byteorder.h"
 generic module IntegerConfParameterP(
		uint8_t u0, uint8_t u1, uint8_t u2, uint8_t u3, uint8_t u4, uint8_t u5, uint8_t u6, uint8_t u7,
		uint8_t u8, uint8_t u9, uint8_t ua, uint8_t ub, uint8_t uc, uint8_t ud, uint8_t ue, uint8_t uf,
		uint8_t conf_storage, uint8_t conf_policy,
		uint8_t conf_type, typedef value_type @integer()) {
	provides {
		interface Set<value_type>;
		interface Get<value_type>;
		interface GetSet<value_type>;
		interface Changed<value_type>;

		interface ConfParameter;

		interface Init @exactlyonce();
	}
	uses {
		interface ConfParameterCheck<value_type>;
		interface Get<value_type> as GetDefault;
	}
}
implementation {

	#define __MODUUL__ "confp"
	#define __LOG_LEVEL__ ( LOG_LEVEL_IntegerConfParameterP & BASE_LOG_LEVEL )
	#include "log.h"

	PROGMEM const uint8_t conf_uuid[UUID128_LENGTH] = { u0, u1, u2, u3, u4, u5, u6, u7, u8, u9, ua, ub, uc, ud, ue, uf };
	PROGMEM const conf_info_struct_t conf_info = {conf_storage, conf_policy, conf_type, sizeof(value_type)};

	value_type conf_value;

	command error_t Init.init() {
		conf_value = call GetDefault.get();
		return SUCCESS;
	}

	command error_t ConfParameter.properties(conf_info_struct_t* pinfo) {
		memcpy_P(pinfo, &conf_info, sizeof(conf_info_struct_t));
		return SUCCESS;
	}

	command bool ConfParameter.match(uuid128_t* uuid) {
		return memcmp_P(uuid, conf_uuid, UUID128_LENGTH) == 0;
	}

	command error_t ConfParameter.uuid(uuid128_t* uuid) {
		memcpy_P(uuid, conf_uuid, UUID128_LENGTH);
		return SUCCESS;
	}

	command uint16_t ConfParameter.get(uint8_t buffer[], uint16_t length) {
		if(length >= sizeof(value_type)) {
			reverse_byte_order(buffer, (uint8_t*)&conf_value, sizeof(value_type));
			return sizeof(value_type);
		}
		return 0;
	}

	command error_t ConfParameter.set(uint8_t buffer[], uint16_t length) {
		if(length == sizeof(value_type)) {
			value_type v;
			reverse_byte_order((uint8_t*)&v, buffer, sizeof(value_type));
			if(call ConfParameterCheck.suitable(v)) {
				conf_value = v;
				signal Changed.changed(conf_value);
				return SUCCESS;
			}
			return EINVAL;
		}
		return ESIZE;
	}

	command error_t ConfParameter.init(uint8_t buffer[], uint16_t length) {
		if(length == sizeof(value_type)) {
			value_type v;
			reverse_byte_order((uint8_t*)&v, buffer, sizeof(value_type));
			if(call ConfParameterCheck.suitable(v)) {
				conf_value = v;
				return SUCCESS;
			}
			return EINVAL;
		}
		return ESIZE;
	}

	/**
	 * Value access by user component.
	 */
	command value_type Get.get() {
		return conf_value;
	}

	/**
	 * Value changing by user component.
	 */
	command void Set.set(value_type value) {
		conf_value = value;
		// TODO notify watchers?
		// TODO organize update?
	}

	command value_type GetSet.get() {
		return call Get.get();
	}

	command void GetSet.set(value_type value) {
		call Set.set(value);
	}

	default event void Changed.changed(value_type value) {
		debug1("chngd(%"PRIi32")", (int32_t)value);
	}

}
