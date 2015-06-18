/**
 * Configurable parameter central wiring module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
configuration ConfModuleC {
	provides {
		interface Conf<uint32_t> as Conf[uint32_t conf_id];
		interface Conf<uint32_t> as ConfSeq[uint8_t confSeqNum];
		interface ConfInit<uint32_t> as ConfInit[uint8_t confSeqNum];

		interface Conf<int32_t> as IConf[uint32_t conf_id];
		interface Conf<int32_t> as IConfSeq[uint8_t confSeqNum];
		interface ConfInit<int32_t> as IConfInit[uint8_t confSeqNum];

		interface BBConf as BBConf[uint32_t conf_id];
		interface BBConf as BBConfSeq[uint8_t confSeqNum];
		interface BBConfInit as BBConfInit[uint8_t confSeqNum];

		interface ConfModuleInfo;
		interface Boot;
	}
	uses {
		interface Conf<uint32_t> as UsedConf[uint32_t conf_id];
		interface Conf<uint32_t> as UsedConfSeq[uint8_t confSeqNum];
		interface ConfInit<uint32_t> as UsedConfInit[uint8_t confSeqNum];

		interface Conf<int32_t> as UsedIConf[uint32_t conf_id];
		interface Conf<int32_t> as UsedIConfSeq[uint8_t confSeqNum];
		interface ConfInit<int32_t> as UsedIConfInit[uint8_t confSeqNum];

		interface BBConf as UsedBBConf[uint32_t conf_id];
		interface BBConf as UsedBBConfSeq[uint8_t confSeqNum];
		interface BBConfInit as UsedBBConfInit[uint8_t confSeqNum];
		interface Boot as SysBoot @exactlyonce();
	}
}
implementation {

#ifndef ENABLE_CONF_MODULE
	#error "You must declare ENABLE_CONF_MODULE to use ConfModuleC"
#endif /* ENABLE_CONF_MODULE */

	Conf = UsedConf;
	ConfSeq = UsedConfSeq;
	ConfInit = UsedConfInit;

	IConf = UsedIConf;
	IConfSeq = UsedIConfSeq;
	IConfInit = UsedIConfInit;

	BBConf = UsedBBConf;
	BBConfSeq = UsedBBConfSeq;
	BBConfInit = UsedBBConfInit;

	components ConfModuleP;
	ConfModuleInfo = ConfModuleP;

#ifndef DISABLE_CONF_COMMUNICATION
	components ConfCommunicationC;
#else
	#warning "DISABLE_CONF_COMMUNICATION in effect!"
#endif /* DISABLE_CONF_COMMUNICATION */

	components ConfSetupC;
	Boot = ConfSetupC.Boot;
	SysBoot = ConfSetupC.SysBoot;

}
