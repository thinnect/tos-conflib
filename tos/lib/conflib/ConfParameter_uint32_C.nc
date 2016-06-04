/**
 * ConfLib generic uint32_t parameter module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "ConfLib.h"
generic configuration ConfParameter_uint32_C(
		uint8_t u0, uint8_t u1, uint8_t u2, uint8_t u3, uint8_t u4, uint8_t u5, uint8_t u6, uint8_t u7,
		uint8_t u8, uint8_t u9, uint8_t ua, uint8_t ub, uint8_t uc, uint8_t ud, uint8_t ue, uint8_t uf,
		uint8_t conf_storage, uint8_t conf_policy,
		uint32_t value_min, uint32_t value_default, uint32_t value_max) {
	provides {
		interface Get<uint32_t>;
		interface Set<uint32_t>;
		interface GetSet<uint32_t>;
		interface Changed<uint32_t>;
	}
}
implementation {

	enum { CONF_PARAMETER_ID = unique("ConfParameter") };

	components new IntegerConfParameterP(
		u0, u1, u2, u3, u4, u5, u6, u7,
		u8, u9, ua, ub, uc, ud, ue, uf,
		conf_storage, conf_policy,
		CONF_PARAM_TYPE_SIGNED, uint32_t) as Parameter;

	components new ConfParameterMeta_uint32_C(value_min, value_default, value_max) as Meta;
	Parameter.GetDefault -> Meta;
	Parameter.ConfParameterCheck -> Meta;

	Get = Parameter.Get;
	Set = Parameter.Set;
	GetSet = Parameter.GetSet;
	Changed = Parameter.Changed;

	components ConfSetupC;
	ConfSetupC.ConfParameter[CONF_PARAMETER_ID] -> Parameter.ConfParameter;
	ConfSetupC.ConfParameterMeta[CONF_PARAMETER_ID] -> Meta.ConfParameterMeta;

	components MainC;
	MainC.SoftwareInit -> Parameter;

}
