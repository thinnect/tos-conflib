/**
 * Configurable parameter interface.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface Conf<conf_type> {

	command error_t set(conf_type value);

	command conf_type get();

	command conf_type minValue();

	command conf_type maxValue();

	command conf_type getDefault();


	command uint8_t getStorageType();

	command uint8_t getType();

	command uint32_t getId();

	command uint8_t getSeq();


	event void changed(conf_type value);

}
