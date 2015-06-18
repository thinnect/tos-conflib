/**
 * @author Raido Pahtma
 * @license MIT
*/
generic module ConfIntUintAdapterP() {
	provides {
		interface Conf<uint32_t>;
		interface ConfInit<uint32_t>;
	}
	uses {
		interface Conf<int32_t> as IConf;
		interface ConfInit<int32_t> as IConfInit;
	}
}
implementation {

	command uint8_t Conf.getStorageType() {
		return call IConf.getStorageType();
	}

	command uint8_t Conf.getType() {
		return call IConf.getType();
	}

	command uint8_t Conf.getSeq() {
		return call IConf.getSeq();
	}

	command error_t Conf.set(uint32_t value) {
		return call IConf.set(value);
	}

	command uint32_t Conf.getId() {
		return call IConf.getId();
	}

	command uint32_t Conf.maxValue() {
		return call IConf.maxValue();
	}

	command uint32_t Conf.getDefault() {
		return call IConf.getDefault();
	}

	command uint32_t Conf.minValue() {
		return call IConf.minValue();
	}

	command uint32_t Conf.get() {
		return call IConf.get();
	}

	command error_t ConfInit.init(uint32_t value) {
		return call IConfInit.init((int32_t)value);
	}

	command error_t ConfInit.initDefault() {
		return call IConfInit.initDefault();
	}

	event void IConf.changed(int32_t value) {
		signal Conf.changed((uint32_t)value);
	}

}
