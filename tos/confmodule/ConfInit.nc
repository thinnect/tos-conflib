/**
 * Configurable parameter initialization interface.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface ConfInit<conf_type> {

	command error_t initDefault();

	command error_t init(conf_type value);

}
