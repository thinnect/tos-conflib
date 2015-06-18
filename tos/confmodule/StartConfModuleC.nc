/**
 * @author Raido Pahtma
 * @license MIT
*/
generic configuration StartConfModuleC() {
	provides {
		interface Boot;
	}
	uses {
		interface Boot as SysBoot;
	}
}
implementation {

	components ConfModuleC;
	Boot = ConfModuleC.Boot;
	SysBoot = ConfModuleC.SysBoot;

}
