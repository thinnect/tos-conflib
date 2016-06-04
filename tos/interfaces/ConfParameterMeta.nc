/**
 * ConfLib metadata retrieval interface.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface ConfParameterMeta {

	command uint16_t get(uint8_t buffer[], uint16_t length);

}
