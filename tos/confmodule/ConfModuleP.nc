/**
 * Configurable parameter information module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
module ConfModuleP {
	provides interface ConfModuleInfo;
}
implementation {

	command uint8_t ConfModuleInfo.totalCount() {
		return call ConfModuleInfo.simpleTotalCount() + call ConfModuleInfo.bbTotalCount();
	}

	command uint8_t ConfModuleInfo.simpleTotalCount() {
		return call ConfModuleInfo.simplePersistentCount() + call ConfModuleInfo.simpleVolatileCount();
	}

	command uint8_t ConfModuleInfo.bbTotalCount() {
		return call ConfModuleInfo.bbPersistentCount() + call ConfModuleInfo.bbVolatileCount();
	}

	command uint8_t ConfModuleInfo.simplePersistentCount() {
		return uniqueCount("d.conf.module.seq.num");
	}

	command uint8_t ConfModuleInfo.simpleVolatileCount() {
		return uniqueCount("d.conf.module.seq.num.volatile");
	}

	command uint8_t ConfModuleInfo.bbPersistentCount() {
		return uniqueCount("d.conf.module.seq.num.bb");
	}

	command uint8_t ConfModuleInfo.bbVolatileCount() {
		return uniqueCount("d.conf.module.seq.num.bb.volatile");
	}

	command bool ConfModuleInfo.isPersistent(uint8_t seq) {
		if(seq < call ConfModuleInfo.simplePersistentCount())
		{
			return TRUE;
		}
		else if(seq >= call ConfModuleInfo.simpleTotalCount())
		{
			if(seq < call ConfModuleInfo.simpleTotalCount() + call ConfModuleInfo.bbPersistentCount())
			{
				return TRUE;
			}
		}
		return FALSE;
	}

	command bool ConfModuleInfo.isSimple(uint8_t seq) {
		if(seq < call ConfModuleInfo.simpleTotalCount())
		{
			return TRUE;
		}
		return FALSE;
	}

}
