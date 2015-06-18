#
# Makefile extension to include all the stuff in this repository.
# @author Raido Pahtma
# @license MIT
#

THIS_CONFMODULE_MK_DIR := $(realpath $(dir $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))))

# --------------------------------------------------------------------
#            ConfModule
# --------------------------------------------------------------------
CFLAGS += -I$(THIS_CONFMODULE_MK_DIR)/confmodule
CFLAGS += -DENABLE_CONF_MODULE
