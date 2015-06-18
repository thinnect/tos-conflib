/**
 * SmallBlockStorage interface.
 *
 * @author Raido Pahtma
 * @license MIT
 */
interface SmallBlockStorage {

	command error_t readBlock(uint8_t blockNum);

	event void readDone(uint8_t blockNum, uint8_t* block, uint8_t blockSize, error_t err);

	command error_t writeBlock(uint8_t blockNum, uint8_t* block, uint8_t blockSize);

	event void writeDone(error_t err);

	command uint8_t maxSize();

}
