/**
 * @author Raido Pahtma
 * @license MIT
*/
#include "conf_id.h"
configuration BuildInfoConfC {

}
implementation {

	components new ConfROUint32C(CONFID_IDENT_TIMESTAMP, IDENT_TIMESTAMP) as Timestamp;
	components new ConfROUint32C(CONFID_IDENT_UIDHASH, IDENT_UIDHASH) as Uidhash;

	components new ConfROStringC(CONFID_IDENT_APPNAME, IDENT_APPNAME) as Appname;

#ifndef IDENT_PLATFORM
	#if defined(PLATFORM_IRIS)
		#define IDENT_PLATFORM "iris"
	#elif defined(PLATFORM_DENODE)
		#define IDENT_PLATFORM "denode"
	#elif defined(PLATFORM_MICAZ)
		#define IDENT_PLATFORM "micaz"
	#elif defined(PLATFORM_PONY)
		#define IDENT_PLATFORM "pony"
	#else
		#define IDENT_PLATFORM "?"
	#endif
#endif /* IDENT_PLATFORM */

	components new ConfROStringC(CONFID_IDENT_PLATFORM, IDENT_PLATFORM) as Platform;

	components new ConfBootLockFuseC(CONFID_BOOT_LOCK_FUSE_BITS);

}
