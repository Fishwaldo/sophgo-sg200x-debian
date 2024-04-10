$(BUILDDIR)/usb-gadget-stamp:
	@echo "$(COLOUR_GREEN)Installing usb-gadget for $(BOARD)$(END_COLOUR)"
	@mkdir -p /rootfs/usr/sbin /rootfs/etc/systemd/system/ /rootfs/etc/network/interfaces.d/
	@cp -a addons/usb-gadget/run_usb.sh /rootfs/usr/sbin/
	@chmod +x /rootfs/usr/sbin/run_usb.sh
	@cp -a addons/usb-gadget/usb-gadget*.service /rootfs/etc/systemd/system/
	@cp -a addons/usb-gadget/usb0 /rootfs/etc/network/interfaces.d/
	@mkdir -p /rootfs/tmp/install/
	@echo "usb-gadget-rndis usb-gadget-rndis-usb0 usb-gadget" >> /rootfs/tmp/install/systemd-enable
	@touch $@
