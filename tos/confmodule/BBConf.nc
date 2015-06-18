/**
 * Byte buffer interface.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface BBConf {

	command error_t set(uint8_t* value, uint8_t len);

	command uint8_t* get();

	command uint8_t length();

	command uint8_t maxLength();

	command uint8_t getDefault(uint8_t* buffer, uint8_t len);


	command uint8_t getStorageType();

	command uint8_t getType();

	command uint32_t getId();

	command uint8_t getSeq();


	event void changed(uint8_t* value, uint8_t len);

}
