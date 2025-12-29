device:
	$(PLAYDATE_SDK)/bin/pdc -m source/main.lua main.pdx
	$(PLAYDATE_SDK)/bin/pdutil /dev/ttyACM3 datadisk