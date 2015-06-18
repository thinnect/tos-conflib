/**
 * SmallBlockStorage EEPROM module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "crc8.h"
generic module SmallBlockStorageP(uint16_t g_startAddr, uint8_t g_blockSize, uint8_t g_blockCount) {
	provides interface SmallBlockStorage;
	uses interface InternalFlash;
}
implementation {

	// EEPROM STORAGE with 2 byte overhead
	// SIZE BB .. BB CRC
	// endAddr = g_startAddr + g_blockCount*(2 + g_blockSize)

	enum {
		BLOCK_SIZE = 1 + g_blockSize + 1,
		BLOCK_FIRST_BYTE = 1,
		BLOCK_CRC_BYTE = 1 + g_blockSize,
		BLOCK_SIZE_BYTE = 0,
	};

	uint8_t m_blockNum = g_blockCount;

	task void writeDone() {
		m_blockNum = g_blockCount;
		signal SmallBlockStorage.writeDone(SUCCESS);
	}

	command error_t SmallBlockStorage.writeBlock(uint8_t blockNum, uint8_t* block, uint8_t blockSize) {
		if(m_blockNum == g_blockCount) {
			uint16_t maxSize = g_blockSize; // g_blockSize can be 255, and compiler will give a warning in a <= comparison
			if((blockNum < g_blockCount) && (blockSize <= maxSize)) {
				uint8_t i;
				uint8_t crc = crc8Byte(0, blockSize);
				for(i=0;i<blockSize;i++) {
					crc = crc8Byte(crc, block[i]);
				}
				call InternalFlash.write((void*)(g_startAddr + (size_t)blockNum*BLOCK_SIZE), (void*)&blockSize, sizeof(uint8_t));
				call InternalFlash.write((void*)(g_startAddr + (size_t)blockNum*BLOCK_SIZE + sizeof(uint8_t)), (void*)block, blockSize);
				call InternalFlash.write((void*)(g_startAddr + (size_t)blockNum*BLOCK_SIZE + BLOCK_SIZE - sizeof(uint8_t)), (void*)&crc, sizeof(uint8_t));
				post writeDone();
				return SUCCESS;
			}
			return FAIL;
		}
		return EBUSY;
	}

	command uint8_t SmallBlockStorage.maxSize() {
		return g_blockSize;
	}

	task void readDone() {
		uint8_t block[BLOCK_SIZE];
		uint8_t blockNum = m_blockNum;
		error_t err = FAIL;
		if(call InternalFlash.read((void*)(g_startAddr + (size_t)blockNum*BLOCK_SIZE), &block, BLOCK_SIZE) == SUCCESS) {
			uint16_t maxSize = g_blockSize; // g_blockSize can be 255, and compiler will give a warning in a <= comparison
			if(block[BLOCK_SIZE_BYTE] > 0 && block[BLOCK_SIZE_BYTE] <= maxSize) {
				uint8_t crc = 0;
				uint16_t i; // max count is 256 = 255 + size
				for(i=0;i<block[BLOCK_SIZE_BYTE] + 1;i++) {
					crc = crc8Byte(crc, block[i]);
				}
				if(crc == block[BLOCK_CRC_BYTE]) {
					err = SUCCESS;
				}
			}
		}
		m_blockNum = g_blockCount;
		signal SmallBlockStorage.readDone(blockNum, &block[BLOCK_FIRST_BYTE], block[BLOCK_SIZE_BYTE], err);
	}

	command error_t SmallBlockStorage.readBlock(uint8_t blockNum) {
		if(m_blockNum == g_blockCount) {
			if(blockNum < g_blockCount) {
				m_blockNum = blockNum;
				post readDone();
				return SUCCESS;
			}
		}
		return EBUSY;
	}

}
