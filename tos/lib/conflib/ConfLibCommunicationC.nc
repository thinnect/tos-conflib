/**
 * ConfLib communication module configuration.
 *
 * @author Raido Pahtma
 * @license MIT
 */
#include "ConfLibMessages.h"
configuration ConfLibCommunicationC { }
implementation {

	components ConfLibCommunicationP;

	components ConfLibSetupC;
	ConfLibCommunicationP.ConfParameters -> ConfLibSetupC;

	components new AMSenderC(AMID_CONFLIB);
	components new AMReceiverC(AMID_CONFLIB);
	ConfLibCommunicationP.AMSend -> AMSenderC;
	ConfLibCommunicationP.AMPacket -> AMSenderC;
	ConfLibCommunicationP.Receive -> AMReceiverC;

	components new TimerMilliC();
	ConfLibCommunicationP.Timer -> TimerMilliC;

	components GlobalPoolC;
	ConfLibCommunicationP.MsgPool -> GlobalPoolC;

}
