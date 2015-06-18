/**
 * SmallBlockStorage wiring.
 *
 * @author Raido Pahtma
 * @license MIT
 */
generic configuration SmallBlockStorageC(uint16_t g_startAddr, uint8_t g_blockSize, uint8_t g_blockCount) {
	provides interface SmallBlockStorage;
}
implementation {

	components new SmallBlockStorageP(g_startAddr, g_blockSize, g_blockCount);
	SmallBlockStorage = SmallBlockStorageP;

	components InternalFlashC;
	SmallBlockStorageP.InternalFlash -> InternalFlashC;

}
