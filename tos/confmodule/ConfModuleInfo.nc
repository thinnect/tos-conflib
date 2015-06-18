/**
 * Configurable parameter information interface.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface ConfModuleInfo {

	command uint8_t totalCount();
	command uint8_t simpleTotalCount();
	command uint8_t bbTotalCount();

	command uint8_t simplePersistentCount();
	command uint8_t simpleVolatileCount();

	command uint8_t bbPersistentCount();
	command uint8_t bbVolatileCount();

	command bool isPersistent(uint8_t seq);
	command bool isSimple(uint8_t seq);

}
