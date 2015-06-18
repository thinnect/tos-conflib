/**
 * Configurable uint32_t module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "ConfTypes.h"
generic configuration ConfROUint32C(uint32_t conf_id, uint32_t value) {
    provides {
        interface Conf<uint32_t>;
    }
}
implementation {

	enum {
		CONF_SEQ_NUM = uniqueCount("d.conf.module.seq.num")
		             + unique("d.conf.module.seq.num.volatile")
	};

	components new ConfROP(CONF_SEQ_NUM, conf_id, value) as ConfP;
    Conf = ConfP;

	components ConfModuleC;
	ConfModuleC.UsedConf[conf_id] -> ConfP;
	ConfModuleC.UsedConfSeq[CONF_SEQ_NUM] -> ConfP;

}
