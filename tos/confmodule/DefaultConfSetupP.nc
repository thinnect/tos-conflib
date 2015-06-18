/**
 * Configurable parameter setup module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "ConfSetup.h"
module DefaultConfSetupP {
	provides {
		interface SplitControl;
		interface Boot;
	}
	uses {
		interface Conf<uint32_t>[uint8_t confSeqNum];
		interface ConfInit<uint32_t>[uint8_t confSeqNum];
		interface BBConf[uint8_t confSeqNum];
		interface BBConfInit[uint8_t confSeqNum];
		interface ConfModuleInfo as CMI;
	}
}
implementation {

	#warning "This version of ConfSetup always loads defaults at boot!"

	#define __MODUUL__ "CStpP"
	#define __LOG_LEVEL__ ( LOG_LEVEL_CStpP & BASE_LOG_LEVEL )
	#include "log.h"

	task void startDone() {
		signal SplitControl.startDone(SUCCESS);
		signal Boot.booted();
	}

	command error_t SplitControl.start() {
		uint8_t i;
		for(i=0;i<call CMI.totalCount();i++)
		{
			if(call CMI.isSimple(i))
			{
				call ConfInit.initDefault[i]();
			}
			else
			{
				call BBConfInit.initDefault[i]();
			}
		}
		post startDone();
		return SUCCESS;
	}

	command error_t SplitControl.stop() {
		return FAIL;
	}

	event void Conf.changed[uint8_t confSeqNum](uint32_t value) {
	}

	event void BBConf.changed[uint8_t confSeqNum](uint8_t *value, uint8_t len) {
	}

	/* The following default commands should never actually get called. */

	default command uint32_t Conf.get[uint8_t confSeqNum]() {
		return 0;
	}

	default command error_t ConfInit.init[uint8_t confSeqNum](uint32_t value) {
		return FAIL;
	}

	default command error_t ConfInit.initDefault[uint8_t confSeqNum]() {
		return SUCCESS;
	}

	default command uint8_t* BBConf.get[uint8_t confSeqNum]() {
		return NULL;
	}

	default command uint8_t BBConf.length[uint8_t confSeqNum]() {
		return 0;
	}

	default command error_t BBConfInit.init[uint8_t confSeqNum](uint8_t* value, uint8_t len) {
		return FAIL;
	}

	default command error_t BBConfInit.initDefault[uint8_t confSeqNum]() {
		return SUCCESS;
	}

	default event void Boot.booted() { }

}
