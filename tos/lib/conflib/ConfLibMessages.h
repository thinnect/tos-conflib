/**
 * ConfLib messages.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#ifndef CONFLIBMESSAGES_H_
#define CONFLIBMESSAGES_H_

// Common header to all packets
typedef nx_struct conflib_header_t {
	nx_uint8_t header;
	nx_uint16_t version;
} conflib_header_t;

// Parameter details
typedef nx_struct conflib_parameter_details_t {
	nx_uuid128_t uuid;
	nx_uint16_t id; // locally assigned ID
	nx_uint8_t type : 3; // 0 - raw, 1 - ascii, 2 - unsigned, 3 - signed, 4 - unix timestamp, ...
	nx_uint8_t storage : 2; // 0 - read-only, 1 - runtime, 2 - persistent
	nx_uint8_t policy : 2; // 0 - not applicable, 1 - preserve on upgrade, 2 - reset to default on upgrade
	nx_uint8_t meta : 1; // Has meta information
	nx_uint32_t revision;
	nx_uint8_t watcher[8];

	nx_uint16_t hash; // CRC16?
} conflib_parameter_details_t;

// General information about parameters on a node
typedef nx_struct conflib_info_t {
	conflib_header_t header;
	nx_uint16_t count;           // number of available parameters
	nx_uint32_t revision;        // module state for this boot
	nx_uint32_t ident_boot;      // Boot ID - timestamp?
	nx_uint32_t ident_timestamp; // Software build timestamp
	nx_uint32_t ident_uidhash;   // Software build ID
} conflib_info_t;

// Get info about multiple parameters
typedef nx_struct conflib_list_get_t {
	conflib_header_t header;
	nx_uint16_t id[]; // Parameters to get
} conflib_list_get_t;

// Get a specific parameter by UUID
typedef nx_struct conflib_parameter_get_t {
	conflib_header_t header;
	nx_uuid128_t uuid;
} conflib_parameter_get_t;

typedef nx_struct conflib_span_t {
	nx_uint16_t offset;
	nx_uint8_t length;
} conflib_span_t;

// Get fragments for a larger parameter
typedef nx_struct conflib_parameter_get_fragments_t {
	conflib_header_t header;
	nx_uint16_t id;
	nx_uint16_t hash; // Requesting fragments only makes sense if the value has not changed
	conflib_span_t spans[];
} conflib_parameter_get_fragments_t;

// Parameter info response
typedef nx_struct conflib_parameter_info_t {
	conflib_header_t header;
	conflib_parameter_details_t details;

	//nx_uint16_t min_length;
	//nx_uint16_t max_length;
	nx_uint16_t length;
	nx_uint8_t value[]; // the part that fits in the first packet
	//nx_uint8_t meta[]; // default - min - max
} conflib_parameter_info_t;

// Integer constants:
// min|max|default|value
// (u)int8_t --> 4 bytes
// (u)int16_t --> 8 bytes
// (u)int32_t --> 16 bytes
// (u)int64_t --> 32 bytes

typedef nx_struct conflib_parameter_fragment_t { // value get / set for parameters that do not fit in info packet
	conflib_header_t header;
	nx_uint16_t id;
	nx_uint16_t hash; // CRC16?
	nx_uint16_t offset;
	nx_uint8_t data[];
} conflib_parameter_fragment_t;

typedef nx_struct conflib_parameter_set_t {
	conflib_header_t header;
	nx_uint16_t id;
	nx_uint16_t oldhash; // Old hash must be known, otherwise a change is rejected
	nx_uint16_t newhash;
	nx_uint16_t length;
	nx_uint8_t value[]; // first part
} conflib_parameter_set_t;

typedef nx_struct conflib_parameter_set_success_t {
	conflib_header_t header;
	conflib_parameter_details_t details;
} conflib_parameter_set_success_t;

typedef nx_struct conflib_parameter_set_failed_t {
	conflib_header_t header;
	conflib_parameter_details_t details;
	nx_uint16_t newhash;
	nx_uint8_t error;
} conflib_parameter_set_failed_t;

typedef nx_struct conflib_policy_t { // set policy / policy set
	nx_uint8_t header;
	nx_uint16_t id;
	nx_uint8_t policy;
} conflib_policy_t;

typedef nx_struct conflib_watcher_t { // set watcher / watcher set
	nx_uint8_t header;
	nx_uint16_t id;
	nx_uint8_t watcher[8]; // Set to 0000000000000000 to disable
} conflib_watcher_t;

#endif // CONFLIBMESSAGES_H_
