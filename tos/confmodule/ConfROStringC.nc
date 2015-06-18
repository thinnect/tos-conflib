/**
 * Byte buffer generic component, read-only string.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "ConfTypes.h"
generic configuration ConfROStringC(uint32_t conf_id, uint8_t value[]) {
}
implementation {

	enum {
		CONF_SEQ_NUM = uniqueCount("d.conf.module.seq.num")
				     + uniqueCount("d.conf.module.seq.num.volatile")
		             + uniqueCount("d.conf.module.seq.num.bb")
		             + unique("d.conf.module.seq.num.bb.volatile")
	};

	components new BBROConfP(CPT_STRING, CONF_SEQ_NUM, conf_id, value);

	components ConfModuleC;
	ConfModuleC.UsedBBConf[conf_id] -> BBROConfP;
	ConfModuleC.UsedBBConfSeq[CONF_SEQ_NUM] -> BBROConfP;

}
