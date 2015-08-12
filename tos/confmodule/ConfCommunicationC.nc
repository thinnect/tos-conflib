/**
 * Configurable parameter communication module.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "ConfCommunication.h"
#ifndef CONF_COMMUNICATION_UNSECURE
#include "CertUpdateDefaultCert.h"
#ifndef DSEC_CONFCOMMUNICATION_CA
#define DSEC_CONFCOMMUNICATION_CA DSEC_CERTUPDATE_CA
#endif
#endif /* CONF_COMMUNICATION_UNSECURE */
configuration ConfCommunicationC {

}
implementation {

	components ConfCommunicationP;

#ifdef CONF_COMMUNICATION_UNSECURE
	components new AMSenderC(AMID_CONF);
	components new AMReceiverC(AMID_CONF);
	ConfCommunicationP.AMSend -> AMSenderC;
	ConfCommunicationP.AMPacket -> AMSenderC;
	ConfCommunicationP.Receive -> AMReceiverC;
#else
	components new AMConfigureSecurityC(DSEC_CONFCOMMUNICATION_CA, AMID_CONF);
	components new AMSenderReceiverC(AMID_CONF) as Comm;
	ConfCommunicationP.AMSend -> Comm;
	ConfCommunicationP.AMPacket -> Comm;
	ConfCommunicationP.Receive -> Comm;
#endif

	components GlobalPoolC;
	ConfCommunicationP.MsgPool -> GlobalPoolC;

	components ConfModuleC;
	ConfCommunicationP.Conf -> ConfModuleC.Conf;
	ConfCommunicationP.ConfSeq -> ConfModuleC.ConfSeq;
	ConfCommunicationP.BBConf -> ConfModuleC.BBConf;
	ConfCommunicationP.BBConfSeq -> ConfModuleC.BBConfSeq;
	ConfCommunicationP.CMI -> ConfModuleC.ConfModuleInfo;

	components MemChunksC;
	ConfCommunicationP.MemChunk -> MemChunksC;

	components new TimerMilliC();
	ConfCommunicationP.Timer -> TimerMilliC;

}
