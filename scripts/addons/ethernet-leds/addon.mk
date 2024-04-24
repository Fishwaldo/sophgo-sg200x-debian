$(BUILDDIR)/ethernet-leds-stamp:
	@echo "$(COLOUR_GREEN)Installing ethernet leds for $(BOARD)$(END_COLOUR)"
	@mkdir -p /rootfs/etc/systemd/system/ 
	@cp -a addons/ethernet-leds/ethernet-leds.service /rootfs/etc/systemd/system/ 
	@mkdir -p /rootfs/tmp/install/
	@echo " ethernet-leds" >> /rootfs/tmp/install/systemd-enable
	@touch $@
