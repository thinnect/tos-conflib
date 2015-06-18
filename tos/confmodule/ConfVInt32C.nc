/**
 * Configurable int32_t module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "ConfTypes.h"
generic configuration ConfVInt32C(uint32_t conf_id) {
	provides {
		interface Conf<int32_t>;
		interface ConfDefaults<int32_t>;
	}
}
implementation {

	enum {
		CONF_SEQ_NUM = uniqueCount("d.conf.module.seq.num")
		             + unique("d.conf.module.seq.num.volatile")
	};

	components new ConfP(int32_t, CONF_SEQ_NUM, conf_id, CPT_INT32_T, FALSE);
	Conf = ConfP;
	ConfDefaults = ConfP;

	components ConfModuleC;
	ConfModuleC.UsedIConf[conf_id] -> ConfP;
	ConfModuleC.UsedIConfSeq[CONF_SEQ_NUM] -> ConfP;
	ConfModuleC.UsedIConfInit[CONF_SEQ_NUM] -> ConfP;

	// Initialization and communication modules only deal with unsigned types
	components new ConfIntUintAdapterP();
	ConfIntUintAdapterP.IConf -> ConfP;
	ConfIntUintAdapterP.IConfInit -> ConfP;
	ConfModuleC.UsedConf[conf_id] -> ConfIntUintAdapterP;
	ConfModuleC.UsedConfSeq[CONF_SEQ_NUM] -> ConfIntUintAdapterP;
	ConfModuleC.UsedConfInit[CONF_SEQ_NUM] -> ConfIntUintAdapterP;

}
