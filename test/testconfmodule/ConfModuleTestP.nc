/**
 * @author Raido Pahtma
 * @license MIT
*/
generic module ConfModuleTestP() {
	uses {
		interface Boot;
		interface Timer<TMilli>;
		interface Conf<uint32_t> as Conf1;
	}
}
implementation {

	#define __MODUUL__ "test"
	#define __LOG_LEVEL__ ( LOG_LEVEL_test & BASE_LOG_LEVEL )
	#include "log.h"

	event void Boot.booted()
	{
		call Timer.startPeriodic(1024UL);
	}

	event void Timer.fired()
	{
		debug1("%010"PRIu32" TOS_NODE_ID %04X", call Timer.getNow(), TOS_NODE_ID);
	}

	event void Conf1.changed(uint32_t value)
	{
		debug1("Conf1.changed(%"PRIu32, value);
	}

}
