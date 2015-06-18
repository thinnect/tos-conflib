/**
 * @author Raido Pahtma
 * @license MIT
*/
#ifndef CONFSETUP_H_
#define CONFSETUP_H_

/* Some rather implementation specific storage calculations. BE CAREFUL!!! */

/*
 * Amount of space allocated for each byte buffer in EEPROM
 */
#ifndef D_BB_MAX_LENGTH
#define D_BB_MAX_LENGTH 255
#endif

/*
 * Storage for conf param module starts at this address
 */
#ifndef D_CONF_STORAGE_START
#define D_CONF_STORAGE_START 1024
#endif

	enum SetupSettings {
		D_CONF_SYNC_DELAY = 3000,

		D_CONF_STORAGE_SIZE = 3 * sizeof(uint32_t),
		D_SIMPLE_STORAGE_START = D_CONF_STORAGE_START + D_CONF_STORAGE_SIZE,
		D_SIMPLE_STORAGE_SIZE = uniqueCount("d.conf.module.seq.num") * (sizeof(uint32_t) + 2),
		D_BB_STORAGE_START = D_SIMPLE_STORAGE_START + D_SIMPLE_STORAGE_SIZE,
		D_BB_STORAGE_SIZE = uniqueCount("d.conf.module.seq.num.bb") * (D_BB_MAX_LENGTH + 2)
	};

#endif /* CONF_SETUP_H_ */
