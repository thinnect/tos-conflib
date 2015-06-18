/**
 * Configurable parameter setup module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "ConfSetup.h"
module ConfSetupP {
	provides {
		interface Boot;
	}
	uses {
		interface Conf<uint32_t>[uint8_t confSeqNum];
		interface ConfInit<uint32_t>[uint8_t confSeqNum];
		interface BBConf[uint8_t confSeqNum];
		interface BBConfInit[uint8_t confSeqNum];
		interface InternalFlash;
		interface SmallBlockStorage as IStorage;
		interface SmallBlockStorage as BStorage;
		interface Timer<TMilli>;
		interface ConfModuleInfo as CMI;
		interface Boot as SysBoot;
	}
}
implementation {

	#define __MODUUL__ "CStpP"
	#define __LOG_LEVEL__ ( LOG_LEVEL_CStpP & BASE_LOG_LEVEL )
	#include "log.h"

	uint8_t m_cb = 0;
	bool m_valid = TRUE;

	bool storageSpaceIsValid() {
		uint32_t tag[3];
		call InternalFlash.read((void*)D_CONF_STORAGE_START, tag, D_CONF_STORAGE_SIZE);
		return (tag[0] == IDENT_USERHASH) && (tag[1] == IDENT_TIMESTAMP) && (tag[2] == IDENT_UIDHASH);
	}

	void makeStorageValid() {
		m_valid = TRUE;
		if(storageSpaceIsValid() == FALSE)
		{
			uint32_t tag[3];
			tag[0] = IDENT_USERHASH;
			tag[1] = IDENT_TIMESTAMP;
			tag[2] = IDENT_UIDHASH;
			call InternalFlash.write((void*)D_CONF_STORAGE_START, tag, D_CONF_STORAGE_SIZE);
		}
		logger(LOG_DEBUG2, "valid");
	}

	task void startDone() {
		signal Boot.booted();
	}

	task void nextRead() {
		if(m_cb >= call CMI.totalCount())
		{
			post startDone();
			return;
		}
		if(call CMI.isSimple(m_cb))
		{
			if(call CMI.isPersistent(m_cb))
			{
				if(call IStorage.readBlock(m_cb) == SUCCESS)
				{
					return;
				}
				logger(LOG_DEBUG2, "rb err %u", m_cb);
			}
			call ConfInit.initDefault[m_cb]();
		}
		else
		{
			if(call CMI.isPersistent(m_cb))
			{
				if(call BStorage.readBlock(m_cb - call CMI.simpleTotalCount()) == SUCCESS)
				{
					return;
				}
				logger(LOG_DEBUG2, "rb err %u", m_cb);
			}
			call BBConfInit.initDefault[m_cb]();
		}
		m_cb++;
		post nextRead();
	}

	task void nextWrite() {
		if(m_cb >= call CMI.totalCount())
		{
			makeStorageValid();
		}
		else if(call CMI.isPersistent(m_cb))
		{
			if(call CMI.isSimple(m_cb))
			{
				uint32_t block = call Conf.get[m_cb]();
				if(call IStorage.writeBlock(m_cb, (uint8_t*)&block, sizeof(uint32_t)) != SUCCESS)
				{
					logger(LOG_DEBUG2, "err %u", m_cb);
					m_cb++;
					post nextWrite();
				}
			}
			else
			{
				if(call BStorage.writeBlock(m_cb - call CMI.simpleTotalCount(), call BBConf.get[m_cb](),
			                            call BBConf.length[m_cb]()) != SUCCESS)
				{
					logger(LOG_DEBUG2, "err %u", m_cb);
					m_cb++;
					post nextWrite();
				}
			}
		}
		else
		{
			m_cb++;
			post nextWrite();
		}
	}

	/**
	 * Sync everything to permanent storage.
	 * If called while m_valid is already FALSE, then everything needs to be restarted?
	 */
	void invalidate() {
		logger(LOG_DEBUG2, "invalid");
		m_valid = FALSE;
		m_cb = 0;
		call Timer.startOneShot(D_CONF_SYNC_DELAY);
	}

	event void IStorage.readDone(uint8_t blockNum, uint8_t *block, uint8_t blockSize, error_t err) {
		logger(LOG_DEBUG2, "%u %u e=%u", blockNum, blockSize, err);
		if(err == SUCCESS)
		{
			if(call ConfInit.init[m_cb](*(uint32_t*)block) != SUCCESS)
			{
				call ConfInit.initDefault[m_cb]();
			}
		}
		else
		{
			call ConfInit.initDefault[m_cb]();
		}
		m_cb++;
		post nextRead();
	}

	event void BStorage.readDone(uint8_t blockNum, uint8_t *block, uint8_t blockSize, error_t err) {
		logger(LOG_DEBUG2, "%u %u e=%u", blockNum, blockSize, err);
		if(err == SUCCESS)
		{
			if(call BBConfInit.init[m_cb](block, blockSize) != SUCCESS)
			{
				call BBConfInit.initDefault[m_cb]();
			}
		}
		else
		{
			call BBConfInit.initDefault[m_cb]();
		}
		m_cb++;
		post nextRead();
	}

	event void SysBoot.booted()
	{
		logger(LOG_DEBUG2, "s=%u sp=%u b=%u bp=%u t=%u", call CMI.simpleTotalCount(), call CMI.simplePersistentCount(), call CMI.bbTotalCount(), call CMI.bbPersistentCount(), call CMI.totalCount());
		if(storageSpaceIsValid() == FALSE) // First boot
		{
			uint8_t i;
			for(i=0;i<call CMI.totalCount();i++)
			{
				if(call CMI.isSimple(i))
				{
					call ConfInit.initDefault[i]();
				}
				else
				{
					call BBConfInit.initDefault[i]();
				}
			}
			invalidate();
			post startDone();
		}
		else
		{
			m_cb = 0;
			post nextRead();
		}
	}

	event void Conf.changed[uint8_t confSeqNum](uint32_t value) {
		if(call CMI.isPersistent(confSeqNum))
		{
			logger(LOG_DEBUG2, "C.c[%u] %lu", confSeqNum, value);
			if(m_valid)
			{
				if(call IStorage.writeBlock(confSeqNum, (uint8_t*)&value, sizeof(uint32_t)) != SUCCESS)
				{
					invalidate();
				}
			}
			else if(m_cb >= confSeqNum) invalidate();
		}
		else logger(LOG_DEBUG2, "C.v[%u] %lu", confSeqNum, value);
	}

	event void BBConf.changed[uint8_t confSeqNum](uint8_t *value, uint8_t len) {
		if(call CMI.isPersistent(confSeqNum))
		{
			logger(LOG_DEBUG2, "B.c[%u]", confSeqNum);
			if(m_valid)
			{
				if(call BStorage.writeBlock(confSeqNum - call CMI.simpleTotalCount(), value, len) != SUCCESS)
				{
					invalidate();
				}
			}
			else if(m_cb >= confSeqNum) invalidate();
		}
		else logger(LOG_DEBUG2, "B.v[%u]", confSeqNum);
	}

	event void Timer.fired() {
		logger(LOG_DEBUG2, "sync");
		post nextWrite();
	}

	void writeDone(error_t err) {
		if(m_valid == FALSE)
		{
			if(call Timer.isRunning() == FALSE)
			{
				m_cb++;
				post nextWrite();
			}
		}
	}

	event void IStorage.writeDone(error_t err) {
		writeDone(err);
	}

	event void BStorage.writeDone(error_t err) {
		writeDone(err);
	}

	/* The following default commands should never actually get called. */

	default command uint32_t Conf.get[uint8_t confSeqNum]() {
		return 0;
	}

	default command error_t ConfInit.init[uint8_t confSeqNum](uint32_t value) {
		return FAIL;
	}

	default command error_t ConfInit.initDefault[uint8_t confSeqNum]() {
		return SUCCESS;
	}

	default command uint8_t* BBConf.get[uint8_t confSeqNum]() {
		return NULL;
	}

	default command uint8_t BBConf.length[uint8_t confSeqNum]() {
		return 0;
	}

	default command error_t BBConfInit.init[uint8_t confSeqNum](uint8_t* value, uint8_t len) {
		return FAIL;
	}

	default command error_t BBConfInit.initDefault[uint8_t confSeqNum]() {
		return SUCCESS;
	}

	default event void Boot.booted() { }

}
