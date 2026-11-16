`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

module top_tb;

	logic clk;

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	axi_interface vif(clk);
	
	axi_ram #(
		.DATA_WIDTH(32),
		.ADDR_WIDTH(16),
		.STRB_WIDTH(4),
		.ID_WIDTH(8)
		)dut(
			.clk(vif.clk),
			.rst(vif.resetn),

		// Write Address
        		.s_axi_awid(vif.awid),
        		.s_axi_awaddr(vif.awaddr),
        		.s_axi_awlen(vif.awlen),
        		.s_axi_awsize(vif.awsize),
        		.s_axi_awburst(vif.awburst),
        		.s_axi_awlock(1'b0),
        		.s_axi_awcache(4'b0000),
        		.s_axi_awprot(3'b000),
        		.s_axi_awvalid(vif.awvalid),
        		.s_axi_awready(vif.awready),
        
        		// Write Data
        		.s_axi_wdata(vif.wdata),
        		.s_axi_wstrb(vif.wstrb),
        		.s_axi_wlast(vif.wlast),
        		.s_axi_wvalid(vif.wvalid),
        		.s_axi_wready(vif.wready),
        
        		// Write Response
        		.s_axi_bid(vif.bid),
        		.s_axi_bresp(vif.bresp),
        		.s_axi_bvalid(vif.bvalid),
        		.s_axi_bready(vif.bready),
        
        		// Read Address
        		.s_axi_arid(vif.arid),
        		.s_axi_araddr(vif.araddr),
        		.s_axi_arlen(vif.arlen),
        		.s_axi_arsize(vif.arsize),
        		.s_axi_arburst(vif.arburst),
        		.s_axi_arlock(1'b0),
        		.s_axi_arcache(4'b0000),
        		.s_axi_arprot(3'b000),
        		.s_axi_arvalid(vif.arvalid),
        		.s_axi_arready(vif.arready),
        
        		// Read Data
        		.s_axi_rid(vif.rid),
        		.s_axi_rdata(vif.rdata),
        		.s_axi_rresp(vif.rresp),
        		.s_axi_rlast(vif.rlast),
        		.s_axi_rvalid(vif.rvalid),
        		.s_axi_rready(vif.rready)
    		);
		
		initial begin
			uvm_config_db#(virtual axi_interface)::set(null,"*.env.agent.driver","vif",vif);
			uvm_config_db#(virtual axi_interface)::set(null,"*.env.agent.monitor","vif",vif);
		end

		initial begin
			run_test();
		end

		initial begin
			#1000000;
			uvm_fatal("top","simulation timeout!")
		end
		endmodule
