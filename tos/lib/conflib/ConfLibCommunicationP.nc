/**
 * ConfLib communication module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "fragmenter_assembler.h"
#include "ConfLibMessages.h"
#include "ConfLib.h"
#include "uuid128.h"
module ConfLibCommunicationP {
	uses {
		interface ConfParameters;

		interface AMSend;
		interface Receive;
		interface AMPacket;
		interface Pool<message_t> as MsgPool;

		interface Timer<TMilli>;
	}
}
implementation {

	#define __MODUUL__ "cnfcm"
	#define __LOG_LEVEL__ ( LOG_LEVEL_ConfLibCommunicationP & BASE_LOG_LEVEL )
	#include "log.h"

	enum States {
		S_IDLE,
		S_SENDING_LIST,
		S_SENDING_BB,
		S_RECEIVING_BB,
	};

	typedef struct comm_state_t {
		uint8_t state : 3;
		bool send_busy : 1;
	} comm_state_t;

	comm_state_t m_state = { S_IDLE, FALSE };

	am_addr_t m_client;
	uint32_t m_conf_id;

	uint8_t m_offset; // bb offset / list seq number

	typedef struct assemble_t {
		uint8_t fragmap;
		uint8_t maxfrag;
		uint8_t length;
		uint8_t data[];
	} assemble_t;

	assemble_t* m_assemble = NULL;

	void sendAck(uint8_t result, am_addr_t dst, uint32_t id, uint8_t seq, uint8_t code) {
		if(m_state.send_busy == FALSE) {
			// message_t* msg = call MsgPool.get();
			// if(msg != NULL) {
			// 	conf_msg_ack_t* amsg = (conf_msg_ack_t*)call AMSend.getPayload(msg, sizeof(conf_msg_ack_t));
			// 	if(amsg != NULL)
			// 	{
			// 		amsg->header = CP_ACK;
			// 		amsg->result = result;
			// 		amsg->id = id;
			// 		amsg->seq = seq;
			// 		amsg->ecode = code;

			// 		if(call AMSend.send(dst, msg, sizeof(conf_msg_ack_t)) == SUCCESS)
			// 		{
			// 			m_state.send_busy = TRUE;
			// 			return;
			// 		}
			// 	}
			// 	call MsgPool.put(msg);
			// }
		}
	}

	event void ConfParameters.getDone(error_t result, uuid128_t* uuid, uint16_t id, conflib_details_t* details,
									  uint8_t value[], uint16_t value_length,
									  uint8_t meta[],  uint8_t  meta_length) {

	}

	event void ConfParameters.setDone(error_t result, uint16_t id, uuid128_t* uuid, conflib_details_t* details) {

	}

	event void ConfParameters.setPolicyDone(error_t result, uint16_t id, uint8_t policy) {

	}

	event void ConfParameters.setWatcherDone(error_t result, uint16_t id, ieee_eui64_t* watcher) {

	}

	event error_t ConfParameters.notifyWatcher(uint16_t id, uuid128_t* uuid, conflib_details_t* details, ieee_eui64_t* watcher) {

	}

	event void Timer.fired() {

	}

	event message_t* Receive.receive(message_t *msg, void *payload, uint8_t len) {
		if(len > sizeof(conflib_msg_common_t)) {
			conflib_msg_common_t* cmsg = (conflib_msg_common_t*)payload;
			logger(LOG_DEBUG2, "rcv %02X", cmsg->header);
			switch(cmsg->header) {
				case CONFLIB_MSG_GET_INFO:
					break;
			}
		}
		return msg;
	}

	event void AMSend.sendDone(message_t *msg, error_t error) {
		logger(error==SUCCESS?LOG_DEBUG2:LOG_WARN2, "snt(%p,%u)", msg, error);
		call MsgPool.put(msg);
		m_state.send_busy = FALSE;
	}

}
