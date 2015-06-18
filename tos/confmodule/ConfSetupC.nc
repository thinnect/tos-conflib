/**
 * Configurable parameter setup module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "ConfSetup.h"
configuration ConfSetupC {
	provides {
		interface Boot;
	}
	uses {
		interface Boot as SysBoot @exactlyonce();
	}
}
implementation {

#ifndef DISABLE_CONF_MODULE
	components ConfSetupP;

	components new SmallBlockStorageC(D_SIMPLE_STORAGE_START, sizeof(uint32_t),
	                                  uniqueCount("d.conf.module.seq.num")) as IStorage;
	ConfSetupP.IStorage -> IStorage;

	components new SmallBlockStorageC(D_BB_STORAGE_START, D_BB_MAX_LENGTH,
	                                  uniqueCount("d.conf.module.seq.num.bb")) as BStorage;
	ConfSetupP.BStorage -> BStorage;

	components InternalFlashC;
	ConfSetupP.InternalFlash -> InternalFlashC;

	components new TimerMilliC();
	ConfSetupP.Timer -> TimerMilliC;

#else
	components DefaultConfSetupP as ConfSetupP;
#endif /* DISABLE_CONF_MODULE */

	Boot = ConfSetupP.Boot;
	SysBoot = ConfSetupP.SysBoot;

	components ConfModuleC;
	ConfSetupP.Conf -> ConfModuleC.ConfSeq;
	ConfSetupP.ConfInit -> ConfModuleC.ConfInit;
	ConfSetupP.BBConf -> ConfModuleC.BBConfSeq;
	ConfSetupP.BBConfInit -> ConfModuleC.BBConfInit;
	ConfSetupP.CMI -> ConfModuleC.ConfModuleInfo;

}
