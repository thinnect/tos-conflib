/**
 * ConfLib main options.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#ifndef CONFLIB_H_
#define CONFLIB_H_

typedef struct conflib_info {
	uint8_t  type;
	uint8_t  storage;
	uint8_t  policy;
	uint16_t min_length;
	uint16_t max_length;
	uint16_t length;
} conflib_info_t;

typedef struct conflib_details {
	uint8_t      type;
	uint8_t      storage;
	uint8_t      policy;
	uint16_t     min_length;
	uint16_t     max_length;
	uint16_t     length;
	uint16_t     hash;
	ieee_eui64_t watcher;
} conflib_details_t;

enum ConfParamTypes {
	CONF_PARAM_TYPE_RAW        = 0, // just bits/bytes
	CONF_PARAM_TYPE_STRING     = 1, // UTF-8
	CONF_PARAM_TYPE_UNSIGNED   = 2, // Unsigned big-endian integer
	CONF_PARAM_TYPE_SIGNED     = 3, // Signed big-endian integer
	CONF_PARAM_TYPE_FLOAT      = 4, // Should choose a specific floating point representation from IEEE754
	CONF_PARAM_TYPE_RESERVED_5 = 5, // Reserved for future use
	CONF_PARAM_TYPE_RESERVED_6 = 6, // Reserved for future use
	CONF_PARAM_TYPE_UNIX_TIME  = 7  // Seconds since the epoch
};

enum ConfStorageOptions {
	CONF_STORAGE_READ_ONLY  = 0,
	CONF_STORAGE_RUNTIME    = 1,
	CONF_STORAGE_PERSISTENT = 2,
	CONF_STORAGE___________ = 3,
};

enum ConfPolicyOptions {
	CONF_POLICY_NONE  = 0,
	CONF_POLICY_KEEP  = 1,
	CONF_POLICY_RESET = 2,
	CONF_POLICY______ = 3,
};

#endif // CONFLIB_H_
