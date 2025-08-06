ADD_SCRIPT = add_to_iptables.sh
GET_IPS_SCRIPT = grab_latest_ips.sh
PERMISSIONS = 755

.PHONY: run
run: grab-latest-ips
	./$(ADD_SCRIPT)

.PHONY: grab-latest-ips
grab-latest-ips: chmod-script
	./$(GET_IPS_SCRIPT)

.PHONY: chmod-script
chmod-script: grab-latest-ips
	chmod $(PERMISSIONS) $(ADD_SCRIPT)
	chmod $(PERMISSIONS) $(GET_IPS_SCRIPT)

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  run          - Make scripts executable and run them"
	@echo "  grab-latest-ips - Fetch the latest UptimeRobot IPs and make scripts executable"
	@echo "  chmod-script - Only make scripts executable"
	@echo "  help         - Show this help message"