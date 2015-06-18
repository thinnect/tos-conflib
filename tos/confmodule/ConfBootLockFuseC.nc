/**
 * Fuse and lock bits as conf param.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "ConfTypes.h"
generic configuration ConfBootLockFuseC(uint32_t conf_id) {
}
implementation {

	enum {
		CONF_SEQ_NUM = uniqueCount("d.conf.module.seq.num")
		             + unique("d.conf.module.seq.num.volatile")
	};

	components new ConfBootLockFuseP(CONF_SEQ_NUM, conf_id) as ConfP;

	components ConfModuleC;
	ConfModuleC.UsedConf[conf_id] -> ConfP;
	ConfModuleC.UsedConfSeq[CONF_SEQ_NUM] -> ConfP;

}
