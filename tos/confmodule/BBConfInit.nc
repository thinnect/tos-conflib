/**
 * Byte buffer initialization interface.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface BBConfInit {

	command error_t initDefault();

	command error_t init(uint8_t* value, uint8_t len);

}
