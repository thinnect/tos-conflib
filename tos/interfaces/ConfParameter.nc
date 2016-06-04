/**
 * ConfLib parameter interface. Communication between module, storage and comms.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "uuid128.h"
#include "ConfLib.h"
interface ConfParameter {

	command error_t init(uint8_t buffer[], uint16_t length);

	command error_t properties(conf_info_struct_t* pinfo);

	command error_t uuid(uuid128_t* u);

	command bool match(uuid128_t* u);

	command uint16_t get(uint8_t buffer[], uint16_t length);

	command error_t set(uint8_t buffer[], uint16_t length);

}
