/**
 * ConfLib parameters interface. Communication between module, storage and comms.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "IeeeEui64.h"
#include "uuid128.h"
#include "ConfLib.h"
interface ConfParameters {

	command uint16_t local(uuid128_t* uuid);

	command error_t get(uint16_t id);
	event void getDone(error_t result,
					   uuid128_t* uuid, uint16_t id,
					   conflib_details_t* details,
					   uint8_t value[], uint16_t value_length,
					   uint8_t meta[],  uint8_t  meta_length);

	command error_t set(uint16_t id, uint16_t oldhash, uint16_t newhash, uint8_t value[], uint16_t length);
	event void setDone(error_t result, uint16_t id, uuid128_t* uuid, conflib_details_t* details);

	command error_t setPolicy(uint16_t id, uint8_t policy);
	event void setPolicyDone(error_t result, uint16_t id, uint8_t policy);

	// Only one watcher per parameter
	// Parameter change notification is occasionally(exponential backoff) attempted until an ack is received
	command error_t setWatcher(uint16_t id, ieee_eui64_t* watcher);
	event void setWatcherDone(error_t result, uint16_t id, ieee_eui64_t* watcher);

	// Notification only informs that the value has changed
	// return SUCCESS, if notification was sent out
	// return ERETRY, if watcher cannot be conatcted at the moment (network address not known, no route)
	// return EBUSY, if otherwise busy
	event error_t notifyWatcher(uint16_t id, uuid128_t* uuid, conflib_details_t* details, ieee_eui64_t* watcher);

	// will stop trying to notify the watcher
	command void watcherAck(uint16_t id, uint16_t hash, ieee_eui64_t* watcher);

}
