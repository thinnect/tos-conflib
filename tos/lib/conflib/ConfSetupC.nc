/**
 * ConfLib setup configuration.
 *
 * @author Raido Pahtma
 * @license MIT
 */
configuration ConfSetupC {
	provides {
		interface Boot;
	}
	uses {
		interface ConfParameter[uint16_t id];
		interface ConfParameterMeta[uint16_t id];
		interface Boot as SysBoot;
	}
}
implementation {

	components new ConfSetupP(uniqueCount("ConfParameter"));
	ConfSetupP.ConfParameter = ConfParameter;
	ConfSetupP.ConfParameterMeta = ConfParameterMeta;
	Boot = ConfSetupP.Boot;
	ConfSetupP.SysBoot = SysBoot;

}
