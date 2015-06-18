/**
 * Configurable parameter communication module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "fragmenter_assembler.h"
#include "ConfCommunication.h"
#include "ConfTypes.h"
module ConfCommunicationP {
	uses {
		interface AMSend;
		interface Receive;
		interface AMPacket;
		interface Pool<message_t> as MsgPool;
		interface Conf<uint32_t>[uint32_t conf_id];
		interface Conf<uint32_t> as ConfSeq[uint8_t seq];
		interface BBConf[uint32_t conf_id];
		interface BBConf as BBConfSeq[uint8_t seq];
		interface ConfModuleInfo as CMI;
		interface MemChunk;
		//interface Authorization list?
		interface Timer<TMilli>;
	}
}
implementation {

	#define __MODUUL__ "cnfcm"
	#define __LOG_LEVEL__ ( LOG_LEVEL_cnfcm & BASE_LOG_LEVEL )
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
		if(m_state.send_busy == FALSE)
		{
			message_t* msg = call MsgPool.get();
			if(msg != NULL)
			{
				conf_msg_ack_t* amsg = (conf_msg_ack_t*)call AMSend.getPayload(msg, sizeof(conf_msg_ack_t));
				if(amsg != NULL)
				{
					amsg->header = CP_ACK;
					amsg->result = result;
					amsg->id = id;
					amsg->seq = seq;
					amsg->ecode = code;

					if(call AMSend.send(dst, msg, sizeof(conf_msg_ack_t)) == SUCCESS)
					{
						m_state.send_busy = TRUE;
						return;
					}
				}
				call MsgPool.put(msg);
			}
		}
	}

	void sendInfo(am_addr_t dst, uint32_t id, uint8_t seq) {
		message_t* msg = call MsgPool.get();
		if(msg != NULL)
		{
			conf_info_msg_t* imsg = call AMSend.getPayload(msg, sizeof(conf_info_msg_t));
			if(imsg != NULL)
			{
				imsg->header = CP_CONF_PARAM;
				imsg->id = id;
				imsg->seq = seq;
				if(call CMI.isSimple(seq))
				{
					imsg->storeType = call ConfSeq.getStorageType[seq]();
					imsg->dataType = call ConfSeq.getType[seq]();
					imsg->defValue = call ConfSeq.getDefault[seq]();
					imsg->minValue = call ConfSeq.minValue[seq]();
					imsg->maxValue = call ConfSeq.maxValue[seq]();
					imsg->value = call ConfSeq.get[seq]();
				}
				else
				{
					imsg->storeType = call BBConfSeq.getStorageType[seq]();
					imsg->dataType = call BBConfSeq.getType[seq]();
					imsg->defValue = call AMSend.maxPayloadLength() - sizeof(conf_bb_msg_t);
					imsg->minValue = 0;
					imsg->maxValue = call BBConfSeq.maxLength[seq]();
					imsg->value = call BBConfSeq.length[seq]();
				}
				if(call AMSend.send(dst, msg, sizeof(conf_info_msg_t)) == SUCCESS)
				{
					m_state.send_busy = TRUE;
					return;
				}
			}
			call MsgPool.put(msg);
		}
	}

	task void sendBBValue() {
		message_t* msg = call MsgPool.get();
		if(msg != NULL)
		{
			conf_bb_msg_t* bbmsg;
			uint8_t* data = call BBConf.get[m_conf_id]();
			uint8_t fragsize = call AMSend.maxPayloadLength() - sizeof(conf_bb_msg_t);
			uint8_t length = call BBConf.length[m_conf_id]() - m_offset;
			if(length > fragsize)
			{
				length = fragsize;
			}
			bbmsg = call AMSend.getPayload(msg, sizeof(conf_bb_msg_t) + length);
			if((bbmsg != NULL) && (data != NULL)) //(length > 0)
			{
				bbmsg->header = CP_BB;
				bbmsg->id = m_conf_id;
				bbmsg->totalLength = call BBConf.length[m_conf_id]();
				bbmsg->fragMaxSize = fragsize;
				bbmsg->offset = m_offset;
				memcpy(bbmsg->fragment, &data[m_offset], length);
				if(call AMSend.send(m_client, msg, sizeof(conf_bb_msg_t) + length) == SUCCESS)
				{
					logger(LOG_DEBUG2, "%u %u %u", m_offset, length, call BBConf.length[m_conf_id]());
					m_state.send_busy = TRUE;
					m_offset += length;
					if(m_offset == call BBConf.length[m_conf_id]())
					{
						m_state.state = S_IDLE;
					}
					return;
				}
			}
			call MsgPool.put(msg);
		}
		logger(LOG_DEBUG2, "err");
		m_state.state = S_IDLE;
	}

	task void sendList() {
		uint8_t fits = (call AMSend.maxPayloadLength() - sizeof(conf_list_msg_t)) / sizeof(conf_item_t);
		message_t* msg = call MsgPool.get();
		if(msg != NULL)
		{
			conf_list_msg_t* cmsg = call AMSend.getPayload(msg, sizeof(conf_list_msg_t) + fits*sizeof(conf_item_t));
			if(cmsg != NULL)
			{
				uint8_t seq = 0;
				uint8_t i = 0;
				cmsg->header = CP_CONF_LIST;
				cmsg->totalCount = call CMI.totalCount();
				for(i=0;i<fits;i++)
				{
					seq = i + m_offset;
					if(seq < call CMI.totalCount())
					{
						cmsg->list[i].seq = seq;
						if(call CMI.isSimple(seq))
						{
							cmsg->list[i].id = call ConfSeq.getId[seq]();
							cmsg->list[i].dataType = call ConfSeq.getType[seq]();
						}
						else
						{
							cmsg->list[i].id = call BBConfSeq.getId[seq]();
							cmsg->list[i].dataType = call BBConfSeq.getType[seq]();
						}
					}
					else {
						break; // Everything has been sent
					}
				}
				m_offset = seq + 1;
				if(m_offset >= call CMI.totalCount()) // Last item is in the list
				{
					m_state.state = S_IDLE;
				}
				if(call AMSend.send(m_client, msg, sizeof(conf_list_msg_t) + i*sizeof(conf_item_t)) == SUCCESS)
				{
					m_state.send_busy = TRUE;
					return;
				}
			}
			m_state.state = S_IDLE;
			call MsgPool.put(msg);
		}
		else
		{
			post sendList();
		}
	}

	event void Timer.fired() {
		if(m_state.state == S_RECEIVING_BB)
		{
			call MemChunk.put(m_assemble);
			m_assemble = NULL;
			m_state.state = S_IDLE;
			sendAck(m_client, m_conf_id, call BBConf.getSeq[m_conf_id](), FAIL, ERR_CM_TIMEOUT);
		}
	}

	event message_t* Receive.receive(message_t *msg, void *payload, uint8_t len) {
		conf_msg_t* cmsg = (conf_msg_t*)payload;
		logger(LOG_DEBUG2, "rcv h=%u s=%u", cmsg->header, m_state.state);
		switch(cmsg->header)
		{
			case CP_REQ_CONF_LIST: // REQUEST LIST
				if(m_state.state == S_IDLE)
				{
					m_client = call AMPacket.source(msg);
					m_offset = 0;
					m_state.state = S_SENDING_LIST;
					post sendList();
				}
				break;
			case CP_SET_BB_CONF_PARAM: // SET BB
				if((m_state.state == S_IDLE) || (m_state.state == S_RECEIVING_BB))
				{
					conf_bb_msg_t* bmsg = (conf_bb_msg_t*)payload;
					uint8_t fragSize = len - sizeof(conf_bb_msg_t);

					if(len < sizeof(conf_bb_msg_t))
					{
						sendAck(CP_ACK_FAIL, call AMPacket.source(msg), bmsg->id, call BBConf.getSeq[bmsg->id](),
						        ERR_CM_BAD_PACKET);
						return msg;
					}

					if(m_state.state == S_IDLE)
					{
						if(call BBConf.getId[bmsg->id]() != bmsg->id)
						{
							sendAck(CP_ACK_FAIL, call AMPacket.source(msg), bmsg->id, call BBConf.getSeq[bmsg->id](),
							        ERR_CM_BAD_ID);
							return msg;
						}
						if(call BBConf.maxLength[bmsg->id]() < bmsg->totalLength)
						{
							sendAck(CP_ACK_FAIL, call AMPacket.source(msg), bmsg->id, call BBConf.getSeq[bmsg->id](),
							        ERR_CM_TOO_LONG);
							return msg;
						}

						m_assemble = (assemble_t*)call MemChunk.get(bmsg->totalLength + sizeof(assemble_t));
						if(m_assemble == NULL)
						{
							sendAck(CP_ACK_FAIL, call AMPacket.source(msg), bmsg->id, call BBConf.getSeq[bmsg->id](),
							        ERR_CM_NO_BUFFER);
							return msg;
						}
						m_assemble->fragmap = 0;
						m_assemble->length = bmsg->totalLength;
						m_assemble->maxfrag = bmsg->fragMaxSize;
						m_state.state = S_RECEIVING_BB;
						m_client = call AMPacket.source(msg);
						m_conf_id = bmsg->id;
					}
					else
					{
						if((m_client != call AMPacket.source(msg))
						 ||(m_conf_id != bmsg->id)
						 ||(m_assemble->length != bmsg->totalLength)
						 ||(m_assemble->maxfrag != bmsg->fragMaxSize))
						{
							sendAck(CP_ACK_FAIL, call AMPacket.source(msg), bmsg->id, call BBConf.getSeq[bmsg->id](),
							        ERR_CM_PARAMS);
							return msg;
						}
					}

					call Timer.startOneShot(BB_UPDATE_TIMEOUT);

					if(data_assembler(m_assemble->maxfrag, m_assemble->data, m_assemble->length,
					                  (uint8_t*)bmsg->fragment, fragSize, bmsg->offset, &m_assemble->fragmap))
					{
						if(call BBConf.set[m_conf_id](m_assemble->data, m_assemble->length) == SUCCESS)
						{
							sendAck(CP_ACK_SUCCESS, m_client, m_conf_id, call BBConf.getSeq[m_conf_id](),
							        ERR_CM_DEFAULT);
						}
						else
						{
							sendAck(CP_ACK_FAIL, m_client, m_conf_id, call BBConf.getSeq[m_conf_id](),
							        ERR_CM_DEFAULT);
						}
						call MemChunk.put(m_assemble);
						m_assemble = NULL;
						m_state.state = S_IDLE;
						call Timer.stop();
					}
				}
				break;
			case CP_SET_CONF_PARAM: // SET STD
				if(m_state.send_busy == FALSE)
				{
					conf_std_msg_t* smsg = (conf_std_msg_t*)payload;
					if(call Conf.set[smsg->id](smsg->value) == SUCCESS)
					{
						sendAck(CP_ACK_SUCCESS, call AMPacket.source(msg), smsg->id, call Conf.getSeq[smsg->id](),
						        ERR_CM_DEFAULT);
					}
					else
					{
						sendAck(CP_ACK_FAIL, call AMPacket.source(msg), smsg->id, call Conf.getSeq[smsg->id](),
						        ERR_CM_DEFAULT);
					}
				}
				break;
			case CP_REQ_CONF_PARAM_BY_ID: // REQUEST INFO
				if(m_state.send_busy == FALSE)
				{
					conf_id_req_msg_t* imsg = (conf_id_req_msg_t*)payload;
					uint8_t seq;
					if(call Conf.getId[imsg->id]() == imsg->id)
					{
						seq = call Conf.getSeq[imsg->id]();
					}
					else if(call BBConf.getId[imsg->id]() == imsg->id)
					{
						seq = call BBConf.getSeq[imsg->id]();
					}
					else
					{
						sendAck(CP_ACK_NO_PARAM, call AMPacket.source(msg), imsg->id, call CMI.totalCount(), ERR_CM_DEFAULT);
						return msg;
					}
					sendInfo(call AMPacket.source(msg), imsg->id, seq);
				}
				break;
			case CP_REQ_CONF_PARAM_BY_SEQ_NO: // REQUEST INFO by seq
				if(m_state.send_busy == FALSE)
				{
					conf_seq_req_msg_t* imsg = (conf_seq_req_msg_t*)payload;
					uint32_t id;
					if(call CMI.isSimple(imsg->seq))
					{
						id = call ConfSeq.getId[imsg->seq]();
					}
					else
					{
						id = call BBConfSeq.getId[imsg->seq]();
					}
					if(id != 0)
					{
						sendInfo(call AMPacket.source(msg), id, imsg->seq);
					}
					else
					{
						sendAck(CP_ACK_NO_PARAM, call AMPacket.source(msg), 0, imsg->seq, ERR_CM_DEFAULT);
					}
				}
				break;
			case CP_REQ_BB: // REQUEST BB VALUE
				if(m_state.state == S_IDLE)
				{
					conf_id_req_msg_t* rmsg = (conf_id_req_msg_t*)payload;
					if(call BBConf.getId[rmsg->id]() == rmsg->id)
					{
						m_state.state = S_SENDING_BB;
						m_client = call AMPacket.source(msg);
						m_conf_id = rmsg->id;
						m_offset = 0;
						post sendBBValue();
					}
				}
				break;
		}
		return msg;
	}

	event void AMSend.sendDone(message_t *msg, error_t error) {
		logger(LOG_DEBUG2, "snt");
		call MsgPool.put(msg);
		m_state.send_busy = FALSE;
		if(m_state.state == S_SENDING_LIST)
		{
			post sendList();
		}
		else if(m_state.state == S_SENDING_BB)
		{
			post sendBBValue();
		}
	}

	event void Conf.changed[uint32_t conf_id](uint32_t value) { }
	event void ConfSeq.changed[uint8_t seq](uint32_t value) { }
	event void BBConf.changed[uint32_t conf_id](uint8_t *value, uint8_t len) { }
	event void BBConfSeq.changed[uint8_t seq](uint8_t *value, uint8_t len) { }

	default command uint8_t BBConf.getSeq[uint32_t conf_id]() {
		return call CMI.totalCount();
	}

	default command uint32_t BBConf.getId[uint32_t conf_id]() {
		return 0;
	}

	default command uint8_t BBConf.maxLength[uint32_t conf_id]() {
		return 0;
	}

	default command error_t BBConf.set[uint32_t conf_id](uint8_t* buf, uint8_t len) {
		return FAIL;
	}

	default command uint8_t* BBConf.get[uint32_t conf_id]() {
		return NULL;
	}

	default command uint8_t BBConf.length[uint32_t conf_id]() {
		return 0;
	}

	default command error_t Conf.set[uint32_t conf_id](uint32_t value) {
		return FAIL;
	}

	default command uint8_t Conf.getSeq[uint32_t conf_id]() {
		return call CMI.totalCount();
	}

	default command uint32_t Conf.getId[uint32_t conf_id]() {
		return 0;
	}

	default command uint32_t ConfSeq.getId[uint8_t seq]() {
		return 0;
	}

	default command uint32_t BBConfSeq.getId[uint8_t seq]() {
		return 0;
	}

	default command uint8_t ConfSeq.getStorageType[uint8_t seq]() {
		return CPT_STORAGE_READONLY;
	}

	default command uint8_t ConfSeq.getType[uint8_t seq]() {
		return 0;
	}

	default command uint32_t ConfSeq.getDefault[uint8_t seq]() {
		return 0;
	}

	default command uint32_t ConfSeq.minValue[uint8_t seq]() {
		return 0;
	}

	default command uint32_t ConfSeq.maxValue[uint8_t seq]() {
		return 0;
	}

	default command uint32_t ConfSeq.get[uint8_t seq]() {
		return 0;
	}

	default command uint8_t BBConfSeq.getStorageType[uint8_t seq]() {
		return CPT_STORAGE_READONLY;
	}

	default command uint8_t BBConfSeq.getType[uint8_t seq]() {
		return 0;
	}

	default command uint8_t BBConfSeq.maxLength[uint8_t seq]() {
		return 0;
	}

	default command uint8_t BBConfSeq.length[uint8_t seq]() {
		return 0;
	}

}
