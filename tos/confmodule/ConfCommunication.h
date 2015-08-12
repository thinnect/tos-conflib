/**
 * @author Raido Pahtma
 * @license MIT
*/
#ifndef CONFCOMMUNICATION_H_
#define CONFCOMMUNICATION_H_

	#ifndef AMID_CONF
 	#define AMID_CONF 0x90
 	#else
 	#warning "AMID_CONF defined externally!"
 	#endif // AMID_CONF


	/**
    *	List request.
    *
    * 	@AMPacket{AMID_CONF}
    * 	@AMFirstByte{CP_REQ_CONF_LIST}
    */
	typedef struct conf_msg_t {
		nx_uint8_t header;
	} conf_msg_t;

    /**
    *	Ack message sent by node to confirm success / report failure.
    *
    * 	@AMPacket{AMID_CONF}
    * 	@AMFirstByte{CP_ACK}
    */
	typedef struct conf_msg_ack_t {
		nx_uint8_t header;
		nx_uint8_t result;
		nx_uint8_t seq;
		nx_uint32_t id;
		nx_uint8_t ecode;
	} conf_msg_ack_t;

    /**
    *	Set value of an integer parameter.
    *
    * 	@AMPacket{AMID_CONF}
    * 	@AMFirstByte{CP_SET_CONF_PARAM}
    */
	typedef struct conf_std_msg_t {
		nx_uint8_t header;
		nx_uint32_t id;
		nx_uint32_t value;
	} conf_std_msg_t;

	typedef struct conf_item_t {
		nx_uint8_t seq;
		nx_uint32_t id;
		nx_uint8_t dataType;
	} conf_item_t;

    /**
    *	Configurable parameter list.
    *
    * 	@AMPacket{AMID_CONF}
    * 	@AMFirstByte{CP_CONF_LIST}
    */
	typedef struct conf_list_msg_t {
		nx_uint8_t header;
		nx_uint8_t totalCount;
		conf_item_t list[];
	} conf_list_msg_t;

    /**
    *	Byte buffer contents, fragmented.
    *
    * 	@AMPacket{AMID_CONF}
    * 	@AMFirstByte{CP_BB}
    */
	typedef struct conf_bb_msg_t {
		nx_uint8_t header;
		nx_uint32_t id;
		nx_uint8_t totalLength; // Total length of the byte buffer
		nx_uint8_t fragMaxSize; // Max size of fragment
		nx_uint8_t offset; // Offset of current fragment
		nx_uint8_t fragment[];
	} conf_bb_msg_t;

    /**
    *	Set byte buffer contents, fragmented.
    *
    * 	@AMPacket{AMID_CONF}
    * 	@AMFirstByte{CP_SET_BB_CONF_PARAM}
    */
	typedef struct conf_set_bb_msg_t { // Is a copy of conf_bb_msg_t
		nx_uint8_t header;
		nx_uint32_t id;
		nx_uint8_t totalLength; // Total length of the byte buffer
		nx_uint8_t fragMaxSize; // Max size of fragment
		nx_uint8_t offset; // Offset of current fragment
		nx_uint8_t fragment[];
	} conf_set_bb_msg_t;

    /**
    *	Request by id.
    *
    * 	@AMPacket{AMID_CONF}
    * 	@AMFirstByte{CP_REQ_CONF_PARAM_BY_ID}
    */
	typedef struct conf_id_req_msg_t {
		nx_uint8_t header;
		nx_uint32_t id;
	} conf_id_req_msg_t;

    /**
    *	Request bb by id.
    *
    * 	@AMPacket{AMID_CONF}
    * 	@AMFirstByte{CP_REQ_BB}
    */
	typedef struct conf_id_req_bb_msg_t { // Is a copy of conf_id_req_msg_t
		nx_uint8_t header;
		nx_uint32_t id;
	} conf_id_req_bb_msg_t;

    /**
    *	Request by sequence number.
    *
    * 	@AMPacket{AMID_CONF}
    * 	@AMFirstByte{CP_REQ_CONF_PARAM_BY_SEQ_NO}
    */
	typedef struct conf_seq_req_msg_t {
		nx_uint8_t header;
		nx_uint8_t seq;
	} conf_seq_req_msg_t;

    /**
    *	Conf param info.
    *
    * 	@AMPacket{AMID_CONF}
    * 	@AMFirstByte{CP_CONF_PARAM}
    */
	typedef struct conf_info_msg_t {
		nx_uint8_t header;
		nx_uint32_t id;
		nx_uint8_t seq;
		nx_uint8_t dataType; // Client needs to be BB aware
		nx_uint32_t defValue; // max fragment length when BB
		nx_uint32_t minValue; // 0 when bb
		nx_uint32_t maxValue; // max length when bb
		nx_uint32_t value; // current length when bb
		nx_uint8_t storeType; // FLASH, RAM, RO
	} conf_info_msg_t;

	enum CommunicationSettings {
		BB_UPDATE_TIMEOUT = 5000,
	};

    /// @AMInclude
	enum Errors {
		ERR_CM_DEFAULT    = 0x00,
		ERR_CM_PARAMS     = 0x01,
		ERR_CM_NO_BUFFER  = 0x02,
		ERR_CM_BAD_ID     = 0x03,
		ERR_CM_TIMEOUT    = 0x04,
		ERR_CM_BAD_PACKET = 0x05,
		ERR_CM_TOO_LONG   = 0x06
	};

	enum ConfParamMessages {
		CP_REQ_CONF_LIST            = 0x01, // Request list
		CP_CONF_LIST                = 0x02, // List

		CP_REQ_CONF_PARAM_BY_SEQ_NO = 0x03, // Get configurable parameter by sequence no
		CP_REQ_CONF_PARAM_BY_ID     = 0x04, // Get configurable parameter by parameter ID
		CP_CONF_PARAM               = 0x05, // Configurable parameter info

		CP_SET_CONF_PARAM           = 0x06, // Set configurable parameter value
		CP_SET_BB_CONF_PARAM        = 0x07, // Set BB value

		CP_REQ_BB                   = 0x08, // Request BB value
		CP_BB                       = 0x09, // BB value

        CP_ACK                      = 0x0A,
	};

    /// @AMInclude
	enum AckResults {
		CP_ACK_SUCCESS  = 0x00,
		CP_ACK_FAIL     = 0x01,
		CP_ACK_NO_PARAM = 0x02
	};

#endif /* CONFCOMMUNICATION_H_ */
