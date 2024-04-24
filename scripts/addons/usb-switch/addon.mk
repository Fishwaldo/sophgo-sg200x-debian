$(BUILDDIR)/usb-switch-stamp:
	@echo "$(COLOUR_GREEN)Installing USB Switch for $(BOARD)$(END_COLOUR)"
	@mkdir -p /rootfs/etc/systemd/system/ 
	@cp -a addons/usb-switch/usb-switch.service /rootfs/etc/systemd/system/ 
	@mkdir -p /rootfs/tmp/install/
	@touch $@
