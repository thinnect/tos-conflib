/**
 * ConfLib parameter checking interface.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface ConfParameterCheck<value_type> {

	command bool suitable(value_type value);

}
