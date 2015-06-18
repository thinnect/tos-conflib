/**
 * Byte buffer generic component, persistent string.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "ConfTypes.h"
generic configuration ConfStringC(uint32_t conf_id, uint8_t max_length) {
	provides {
		interface BBConf;
		interface BBConfDefaults;
	}
}
implementation {

	enum {
		CONF_SEQ_NUM = uniqueCount("d.conf.module.seq.num")
				     + uniqueCount("d.conf.module.seq.num.volatile")
		             + unique("d.conf.module.seq.num.bb")
	};

	components new BBConfP(CPT_STRING, CONF_SEQ_NUM, conf_id, max_length, TRUE);
	BBConf = BBConfP;
	BBConfDefaults = BBConfP;

	components ConfModuleC;
	ConfModuleC.UsedBBConf[conf_id] -> BBConfP;
	ConfModuleC.UsedBBConfSeq[CONF_SEQ_NUM] -> BBConfP;
	ConfModuleC.UsedBBConfInit[CONF_SEQ_NUM] -> BBConfP;

}
