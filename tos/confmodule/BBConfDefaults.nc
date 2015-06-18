/**
 * Byte buffer default value interface.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface BBConfDefaults {

	/**
	 * Copy the default value into buffer and return the length of the default value.
	 * @return actual size of the data stored into buffer
	 */
	event uint8_t defaultValue(uint8_t* buffer, uint8_t maxLength);

}
