ROOT := $(shell pwd)

DUT_FILE = $(wildcard $(ROOT)/dut/*.v)

PKG_FILE = $(ROOT)/component/axi_pkg.sv
VIF_FILE = $(ROOT)/component/axi_interface.sv
TOP_FILE = $(ROOT)/component/top_tb.sv

SRC = $(VIF_FILE) $(PKG_FILE) $(DUT_FILE) $(TOP_FILE)

INCDIR = +incdir+$(ROOT)/component +incdir+$(ROOT)/sequence_test

TOP	= top_tb
OUTPUT  = simv

VCS_OPTS = -full64 -sverilog -debug_access+all -kdb -ntb_opts uvm-1.2 -lca -Mupdate -timescale=1ns/1ps

TEST ?= incr_sequence_test

ALL_TESTS = base_sequence_test fix_sequence_test incr_sequence_test random_test

DUMP ?= 0
ifeq ($(DUMP), 1)
    RUN_OPTS = +fsdb
else
    RUN_OPTS = 
endif

.PHONY: all compile run run_all clean verdi

all: compile

compile: $(OUTPUT)

$(OUTPUT): $(SRC)
	@echo "========================================"
	@echo ">>> Compiling AXI RAM UVM with VCS..."
	@echo "========================================"
	vcs $(VCS_OPTS) $(INCDIR) $(SRC) -top $(TOP) -o $(OUTPUT) -l compile.log
	@if [ -f $(OUTPUT) ]; then \
		echo "✅ Compile Success! Output: $(OUTPUT)"; \
	else \
		echo "❌ Compile Failed! Please check compile.log"; exit 1; \
	fi

run: compile
	@echo "========================================"
	@echo ">>> Running Test: $(TEST)"
	@echo "========================================"
	./$(OUTPUT) +UVM_TESTNAME=$(TEST) +ntb_random_seed_automatic $(RUN_OPTS) -l sim_$(TEST).log

run_all: compile
	@for t in $(ALL_TESTS); do \
		echo ""; \
		echo "========================================"; \
		echo ">>> Running Test: $$t"; \
		echo "========================================"; \
		./$(OUTPUT) +UVM_TESTNAME=$$t +ntb_random_seed_automatic $(RUN_OPTS) -l sim_$$t.log; \
	done
	@echo ""
	@echo "All tests finished! Please check sim_*.log for details."

clean:
	@echo ">>> Cleaning up..."
	rm -rf $(OUTPUT) csrc *.log *.vpd *.fsdb ucli.key simv.daidir vc_hdrs.h DVEfiles novas* verdiLog

verdi:
	@echo ">>> Launching Verdi..."
	verdi -sv -ntb_opts uvm-1.2 $(INCDIR) $(SRC) -ssf *.fsdb &
