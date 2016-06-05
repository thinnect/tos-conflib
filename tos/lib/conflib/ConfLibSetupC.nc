/**
 * ConfLib setup configuration.
 *
 * @author Raido Pahtma
 * @license MIT
 */
configuration ConfLibSetupC {
	provides {
		interface Boot;
		interface ConfParameters;
	}
	uses {
		interface ConfParameter[uint16_t id];
		interface ConfParameterMeta[uint16_t id];
		interface Boot as SysBoot;
	}
}
implementation {

	components new ConfLibSetupP(uniqueCount("ConfParameter"));
	ConfParameters = ConfLibSetupP;
	ConfLibSetupP.ConfParameter = ConfParameter;
	ConfLibSetupP.ConfParameterMeta = ConfParameterMeta;
	Boot = ConfLibSetupP.Boot;
	ConfLibSetupP.SysBoot = SysBoot;

	components ConfLibCommunicationC;

}
