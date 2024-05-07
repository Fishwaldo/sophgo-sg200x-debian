$(BUILDDIR)/hciattach-service-stamp:
	@echo "$(COLOUR_GREEN)Installing hciattach systemd service for $(BOARD)$(END_COLOUR)"
	@mkdir -p /rootfs/etc/systemd/system/ 
	@cp -a addons/hciattach-service/hciattach.service /rootfs/etc/systemd/system/ 
	@mkdir -p /rootfs/tmp/install/
	@echo " hciattach bluetooth" >> /rootfs/tmp/install/systemd-enable
	@touch $@
