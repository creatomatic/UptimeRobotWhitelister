SCRIPT = add_to_iptables.sh
PERMISSIONS = 755

.PHONY: run
run: chmod-script
	./$(SCRIPT)

.PHONY: chmod-script
chmod-script:
	chmod $(PERMISSIONS) $(SCRIPT)

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  run          - Make script executable and run it"
	@echo "  chmod-script - Only make script executable"
	@echo "  help         - Show this help message"