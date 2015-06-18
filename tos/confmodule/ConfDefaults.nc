/**
 * Configurable parameter defaults interface.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface ConfDefaults<conf_type> {

	event conf_type minValue();
	event conf_type maxValue();
	event conf_type defaultValue();

}
