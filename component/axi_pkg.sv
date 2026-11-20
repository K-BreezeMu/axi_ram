`timescale 1ns/1ps
package axi_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "axi_transaction.sv"
	`include "axi_sequencer.sv"
	
	`include "axi_driver.sv"
	`include "axi_monitor.sv"
	`include "axi_agent.sv"

	`include "axi_refmodel.sv"
	`include "axi_scoreboard.sv"
	`include "axi_subscriber.sv"

	`include "axi_env.sv"

	`include "base_sequence.sv"
	`include "fix_sequence.sv"
  `include "incr_sequence.sv"
  `include "random_sequence.sv"

	`include "base_sequence_test.sv"
	`include "fix_sequence_test.sv"
  `include "incr_sequence_test.sv"
  `include "random_sequence_test.sv"

endpackage
