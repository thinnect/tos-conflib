/**
 * ConfLib messages.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#ifndef CONFLIBMESSAGES_H_
#define CONFLIBMESSAGES_H_

#include "uuid128.h"
#include "IeeeEui64.h"

typedef nx_struct nx_ieee_eui64 {
  nx_uint8_t data[IEEE_EUI64_LENGTH];
} nx_ieee_eui64_t;

#define AMID_CONFLIB 0xCF

enum ConfLibMessageTypes {
	CONFLIB_MSG_GET_INFO           = 0x00,
	CONFLIB_MSG_INFO               = 0x80,

	CONFLIB_MSG_GET_UUID           = 0x01,
	CONFLIB_MSG_GET                = 0x11,
	CONFLIB_MSG_GET_FRAGMENTS      = 0x21,
	CONFLIB_MSG_PARAMETER_INFO     = 0x81,
	CONFLIB_MSG_PARAMETER_FRAGMENT = 0x91,

	CONFLIB_MSG_SET                = 0x02,
	CONFLIB_MSG_SET_FRAGMENT       = 0x12,
	CONFLIB_MSG_SET_DONE           = 0x82,

	CONFLIB_MSG_SET_POLICY         = 0x03,
	CONFLIB_MSG_POLICY_SET         = 0x83,

	CONFLIB_MSG_SET_WATCHER        = 0x04,
	CONFLIB_MSG_WATCHER_SET        = 0x84,

	CONFLIB_MSG_NOTIFICATION       = 0x8A,
	CONFLIB_MSG_NOTIFICATION_ACK   = 0x0A,

	CONFLIB_MSG_ERROR              = 0xFE,

	CONFLIB_MSG_BUSY               = 0xFF
};

typedef nx_struct conflib_msg_common {
	nx_uint8_t header;
} conflib_msg_common_t;

// General information about parameters on a node
typedef nx_struct conflib_msg_info {
	nx_uint8_t  header;
	nx_uint8_t  version_major;   // Parameter values may not survive upgrade
	nx_uint8_t  version_minor;   // Backwards compatible functionality
	nx_uint8_t  version_patch;   // Internals
	nx_uint16_t count;           // number of available parameters
	nx_uint32_t ident_boot;      // Boot ID - timestamp?
	nx_uint32_t ident_timestamp; // Software build timestamp
	nx_uint32_t ident_uidhash;   // Software build ID
} conflib_msg_info_t;

// Get info about multiple parameters
typedef nx_struct conflib_msg_list_get {
	nx_uint8_t  header;
	nx_uint16_t id[];   // Parameters to get
} conflib_msg_list_get_t;

// Get a specific parameter by UUID
typedef nx_struct conflib_msg_parameter_get {
	nx_uint8_t   header;
	nx_uuid128_t uuid;
} conflib_msg_parameter_get_t;

typedef nx_struct conflib_msg_span {
	nx_uint16_t offset;
	nx_uint8_t  length;
} conflib_msg_span_t;

// Get fragments for a larger parameter
typedef nx_struct conflib_msg_parameter_get_fragments {
	nx_uint8_t     header;
	nx_uint16_t    id;      // locally assigned ID
	nx_uint16_t    hash;    // Requesting fragments only makes sense if the value has not changed
	conflib_msg_span_t spans[];
} conflib_msg_parameter_get_fragments_t;

// Parameter info response
typedef nx_struct conflib_msg_parameter_info {
	nx_uint8_t      header;
	nx_uint16_t     id;          // locally assigned ID

	nx_uuid128_t    uuid;
	nx_uint16_t     hash;        // CRC16?
	nx_uint8_t      type    : 4; // 0 - raw, 1 - ascii, 2 - unsigned, 3 - signed, 4 - unix timestamp, ...
	nx_uint8_t      storage : 2; // 0 - read-only, 1 - runtime, 2 - persistent
	nx_uint8_t      policy  : 2; // 0 - not applicable, 1 - preserve on upgrade, 2 - reset to default on upgrade
	nx_uint16_t     min_length;
	nx_uint16_t     max_length;
	nx_ieee_eui64_t watcher;

	nx_uint16_t     length;
	nx_uint8_t      value[];     // the part that fits in the first packet
	//nx_uint8_t    meta[];      // min/default/max. Comes after the value, is always 3*sizeof(value) and optionally only used for numerics
} conflib_msg_parameter_info_t;

typedef nx_struct conflib_msg_parameter_fragment { // value get / set for parameters that do not fit in info packet
	nx_uint8_t  header;
	nx_uint16_t id;     // locally assigned ID
	nx_uint16_t hash;   // CRC16?
	nx_uint16_t offset;
	nx_uint8_t  data[];
} conflib_msg_parameter_fragment_t;

typedef nx_struct conflib_msg_parameter_set {
	nx_uint8_t  header;
	nx_uint16_t id;      // locally assigned ID
	nx_uint16_t oldhash; // Old hash must be known, otherwise a change is rejected
	nx_uint16_t newhash;
	nx_uint16_t length;
	nx_uint8_t  value[]; // first part
} conflib_msg_parameter_set_t;

typedef nx_struct conflib_msg_parameter_set_done {
	nx_uint8_t  header;
	nx_uint16_t id;     // locally assigned ID
	nx_uint16_t hash;   // newhash
	nx_uint8_t  error;  // 0 for success
} conflib_msg_parameter_set_done_t;

typedef nx_struct conflib_msg_policy { // set policy / policy set
	nx_uint8_t  header;
	nx_uint16_t id;     // locally assigned ID
	nx_uint8_t  policy;
} conflib_msg_policy_t;

typedef nx_struct conflib_msg_watcher { // set watcher / watcher set
	nx_uint8_t      header;
	nx_uint16_t     id;      // locally assigned ID
	nx_ieee_eui64_t watcher; // Set to 0000000000000000 to disable
} conflib_msg_watcher_t;

typedef nx_struct conflib_msg_error { // something went wrong
	nx_uint8_t   header;
	nx_uint8_t   code;    // The error code, cannot be 0
	nx_uint8_t   command; // The command(message) that caused the error
	nx_uint16_t  id;      // FFFF if UUID was used, but no such UUID exists
	nx_uuid128_t uuid;    // 0000000000000000 when id was used, but no matching UUID was found
} conflib_msg_error_t;

#endif // CONFLIBMESSAGES_H_
