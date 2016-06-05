/**
 * ConfLib setup module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "uuid128.h"
#include "ConfLib.h"
#include "ConfLibMessages.h"
generic module ConfLibSetupP(uint16_t conf_count) {
	provides {
		interface Boot;
		interface ConfParameters;
	}
	uses {
		interface Boot as SysBoot @exactlyonce();
		interface ConfParameter[uint16_t id];
		interface ConfParameterMeta[uint16_t id];
	}
}
implementation {

	#define __MODUUL__ "confs"
	#define __LOG_LEVEL__ ( LOG_LEVEL_ConfSetupP & BASE_LOG_LEVEL )
	#include "log.h"

	event void SysBoot.booted() {
		uint16_t i;
		debug1("count %u", conf_count);
		for(i=0;i<conf_count;i++) {
			if(call ConfParameter.set[i](NULL, 0, TRUE) == SUCCESS) {
				uuid128_t uuid;
				conflib_info_t prms;
				uint8_t meta[24];
				uint8_t val[8];
				uint16_t vs = call ConfParameter.get[i](val, sizeof(val));
				uint8_t ms = call ConfParameterMeta.get[i](meta, sizeof(meta));

				call ConfParameter.uuid[i](&uuid);
				call ConfParameter.properties[i](&prms);

				//debugb1("min=%"PRIi32" default=%"PRIi32" max=%"PRIi32" value=%"PRIi32" uuid:", uuid, 16,
				//		(int32_t)value_min, (int32_t)value_default, (int32_t)value_max, (int32_t)call GetSet.get());
				debugb1("st=%u, pol=%u, tp=%u, sz=%u uuid:", &uuid, UUID128_LENGTH, prms.storage, prms.policy, prms.type, prms.length);
				debugb1("val", val, vs);
				debugb1("meta", meta, ms);
			}
			else err1("init %u", i);
		}
		signal Boot.booted();
	}


	command uint16_t ConfParameters.local(uuid128_t* uuid) {
		uint16_t i;
		for(i=0;i<conf_count;i++) {
			if(call ConfParameter.match[i](uuid)) {
				return i;
			}
		}
		return 0xFFFF;
	}

	command error_t ConfParameters.get(uint16_t id) {
		// TODO
		return FAIL;
	}

	command error_t ConfParameters.set(uint16_t id, uint16_t oldhash, uint16_t newhash, uint8_t value[], uint16_t length) {
		// TODO
		return FAIL;
	}

	command error_t ConfParameters.setPolicy(uint16_t id, uint8_t policy) {
		// TODO
		return FAIL;
	}

	command error_t ConfParameters.setWatcher(uint16_t id, ieee_eui64_t* watcher) {
		// TODO
		return FAIL;
	}

	command void ConfParameters.watcherAck(uint16_t id, uint16_t hash, ieee_eui64_t* watcher) {
		// TODO
	}

	default command error_t ConfParameter.properties[uint16_t id](conflib_info_t* pinfo) { return ELAST; }

	default command error_t ConfParameter.uuid[uint16_t id](uuid128_t* uuid) { return ELAST; }

	default command bool ConfParameter.match[uint16_t id](uuid128_t* uuid) { return FALSE; }

	default command uint16_t ConfParameter.get[uint16_t id](uint8_t buffer[], uint16_t length) { return 0; }

	default command error_t ConfParameter.set[uint16_t id](uint8_t buffer[], uint16_t length, bool init) { return ELAST; }

	default command uint16_t ConfParameterMeta.get[uint16_t id](uint8_t buffer[], uint16_t length) { return 0; }

}
