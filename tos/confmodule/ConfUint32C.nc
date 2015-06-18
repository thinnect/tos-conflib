/**
 * Configurable uint32_t module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "ConfTypes.h"
generic configuration ConfUint32C(uint32_t conf_id) {
	provides {
		interface Conf<uint32_t>;
		interface ConfDefaults<uint32_t>;
	}
}
implementation {

	enum {
		CONF_SEQ_NUM = unique("d.conf.module.seq.num")
	};

	components new ConfP(uint32_t, CONF_SEQ_NUM, conf_id, CPT_UINT32_T, TRUE);
	Conf = ConfP;
	ConfDefaults = ConfP;

	components ConfModuleC;
	ConfModuleC.UsedConf[conf_id] -> ConfP;
	ConfModuleC.UsedConfSeq[CONF_SEQ_NUM] -> ConfP;
	ConfModuleC.UsedConfInit[CONF_SEQ_NUM] -> ConfP;

}
