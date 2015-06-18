#
# Makefile for test application.
# @author Raido Pahtma
# @license MIT
#
COMPONENT=ConfModuleTestC

CFLAGS += -I$(PWD)

PLATFORM_BAUDRATE ?= 500000UL
ifneq ($(PLATFORM_BAUDRATE),0)
	CFLAGS += -DPLATFORM_BAUDRATE=$(PLATFORM_BAUDRATE)
endif

BASE_LOG_LEVEL ?= 0xFFFF

CFLAGS +=-DCONF_COMMUNICATION_UNSECURE

include ../../tos/confmodule.mk

include ../../submodule.tosgroundlib/tos/groundlib.mk

# InternalFlash.h
CFLAGS += -I$(TOSDIR)/lib/net/Deluge/extra/micaz
# InternalFlashC.nc
CFLAGS += -I$(TOSDIR)/lib/net/Deluge/extra/avr

# Avoid strange TinyOS issues
CFLAGS += -DTASKLET_IS_TASK

include $(MAKERULES)
