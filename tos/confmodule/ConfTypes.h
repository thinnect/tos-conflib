/**
 * @author Raido Pahtma
 * @license MIT
*/
#ifndef CONFTYPES_H_
#define CONFTYPES_H_

/// @AMInclude
enum ConfTypes {

/*  Data types        */

	CPT_EMPTY      = 0x00,
	CPT_STRING     = 0x01,
	CPT_HEX        = 0x02,
	CPT_XML        = 0x03,

	CPT_UINT8_T    = 0x11,
	CPT_UINT16_T   = 0x12,
	CPT_UINT32_T   = 0x13,

	CPT_INT8_T     = 0x21,
	CPT_INT16_T    = 0x22,
	CPT_INT32_T    = 0x23,

	CPT_FLOAT_T    = 0x31,
	CPT_DOUBLE_T   = 0x32,

/*  Storage types           */

	CPT_STORAGE_PERSISTENT = 0x00,
	CPT_STORAGE_RAM        = 0x01,
	CPT_STORAGE_READONLY   = 0x02,

};

#endif /* CONFTYPES_H_ */
