/**
 * @author Raido Pahtma
 * @license MIT
*/
#include "logger.h"
configuration ConfModuleTestC {

}
implementation {

	components MainC;

	// First the boot event from MainC goes to StartPrintfC
	components new StartPrintfC(1024UL);
	StartPrintfC.SysBoot -> MainC.Boot;

	// Then the boot event from StartPrintfC goes to StartConfModuleC
	components new StartConfModuleC();
	StartConfModuleC.SysBoot -> StartPrintfC.Boot;

	// Finally application gets the boot event from StartConfModuleC
	components new ConfModuleTestP();
	ConfModuleTestP.Boot -> StartConfModuleC.Boot;

	components new TimerMilliC();
	ConfModuleTestP.Timer -> TimerMilliC;

	components new ConfUint32C(1);
	ConfModuleTestP.Conf1 -> ConfUint32C.Conf;

}
