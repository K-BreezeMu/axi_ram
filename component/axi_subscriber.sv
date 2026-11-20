class axi_subscriber extends uvm_subscriber #(axi_transaction);
	`uvm_component_utils(axi_subscriber)
	axi_transaction tr;
	
	covergroup cg_aw;
		option.per_instance = 1;

		cp_awsize: coverpoint tr.awsize {
			bins size_1B = {3'b000};
			bins size_2B = {3'b001};
			bins size_3B = {3'b010};
			}

		cp_awlen: coverpoint tr.awlen {
			bins len_1 = {8'd0};
			bins len_2 = {8'd1};
			bins len_8 = {8'd7};
			bins len_16 = {8'd15};
			bins len_256 = {8'd255};
			bins others = default;
			}

		cp_awburst: coverpoint tr.awburst {
			bins fixed = {2'b00};
			bins incr = {2'b01};
			}

				
		cp_op: coverpoint tr.id {
			bins zero = {8'h00};
			bins low = {[8'h01 : 8'h0F]};
			bins mid = {[8'h10 : 8'hEF]};
			bins high = {[8'hF0 : 8'hFE]};
			bins all = {8'hFF};
			}

		cp_awaddr: coverpoint tr.awaddr {
			bins zero = {16'h0000};
            		bins low = {[16'h0001 : 16'h3FFF]};
            		bins mid = {[16'h4000 : 16'hBFFF]};
            		bins high = {[16'hC000 : 16'hFFFC]};	
			}

		endgroup
	

	covergroup cg_ar;
		option.per_instance = 1;

		cp_arid: coverpoint tr.arid {
			bins zero = {8'h00};
			bins low = {[8'h01 : 8'h2F]};
			bins mid = {[8'h30 : 8'h5F]};
			bins mid_1 = {[8'h60 : 8'h9F]};
			bins mid_2 = {[8'hA0 : 8'hCF]};
			bins high = {[8'hD0 : 8'hFE]};
			bins full = {8'hFF};
			}	
		
		cp_araddr: coverpoint tr.araddr {
			bins zero = {16'h0000};
            		bins low = {[16'h0001 : 16'h3FFF]};
            		bins mid = {[16'h4000 : 16'hBFFF]};
            		bins high = {[16'hC000 : 16'hFFFC]};	
			}

		cp_arsize: coverpoint tr.arsize {
			bins size_1B = {3'b000};
			bins size_2B = {3'b001};
			bins size_3B = {3'b010};
			}

		cp_arlen: coverpoint tr.arlen {
			bins len_1 = {8'd0};
			bins len_2 = {8'd1};
			bins len_8 = {8'd7};
			bins len_16 = {8'd15};
			bins len_256 = {8'd255};
			}

		cp_arburst: coverpoint tr.arburst {
			bins fixed = {2'b00};
			bins incr = {2'b01};
			}

		endgroup

	covergroup wr_data_cg with function sample(bit [31:0] wdata);
        	option.per_instance = 1;
        
        	cp_wdata : coverpoint wdata {
            	bins zero   = {32'h0000_0000};
            	bins full   = {32'hFFFF_FFFF};
            	bins mode_aa= {32'hAAAA_AAAA};
            	bins mode_55= {32'h5555_5555};
            
            	bins low    = {[32'h0000_0001 : 32'h1FFF_FFFF]};
            	bins mid_1  = {[32'h2000_0000 : 32'h3FFF_FFFF]};
            	bins mid_2  = {[32'h4000_0000 : 32'h5FFF_FFFF]};
            	bins mid_3  = {[32'h6000_0000 : 32'h7FFF_FFFF]};
            	bins mid_4  = {[32'h8000_0000 : 32'h9FFF_FFFF]};
            	bins mid_5  = {[32'hA000_0000 : 32'hBFFF_FFFF]};
            	bins mid_6  = {[32'hC000_0000 : 32'hDFFF_FFFF]};
            	bins high   = {[32'hE000_0000 : 32'hFFFF_FFFE]};
        	}
    	endgroup

     	covergroup rd_data_cg with function sample(bit [31:0] rdata);
        	option.per_instance = 1;
        
        	cp_rdata : coverpoint rdata {
           	bins zero   = {32'h0000_0000};
            	bins full   = {32'hFFFF_FFFF};
            	bins mode_aa= {32'hAAAA_AAAA};
            	bins mode_55= {32'h5555_5555};
            
            	bins low    = {[32'h0000_0001 : 32'h1FFF_FFFF]};
            	bins mid_1  = {[32'h2000_0000 : 32'h3FFF_FFFF]};
            	bins mid_2  = {[32'h4000_0000 : 32'h5FFF_FFFF]};
            	bins mid_3  = {[32'h6000_0000 : 32'h7FFF_FFFF]};
            	bins mid_4  = {[32'h8000_0000 : 32'h9FFF_FFFF]};
           	bins mid_5  = {[32'hA000_0000 : 32'hBFFF_FFFF]};
            	bins mid_6  = {[32'hC000_0000 : 32'hDFFF_FFFF]};
            	bins high   = {[32'hE000_0000 : 32'hFFFF_FFFE]};
        	}
    	endgroup

	 covergroup cg_wstrb with function sample(bit [3:0] wstrb_val);
        	option.per_instance = 1;

        	cp_wstrb: coverpoint wstrb_val {
            	bins all_zero = {4'b0000};
            	bins byte_0 = {4'b0001};
            	bins byte_1 = {4'b0010};
            	bins byte_2 = {4'b0100};
            	bins byte_3 = {4'b1000};
            	bins half_low = {4'b0011};
            	bins half_high = {4'b1100};
            	bins all_ones = {4'b1111};
            	bins others = default;
       	 	}
    	endgroup

	function new(string name = "axi_subscriber",uvm_component parent);
		super.new(name,parent);
		cg_aw = new();
		cg_ar = new();
		wr_data_cg =new();
		rd_data_cg =new();
		cg_wstrb = new();
	endfunction

	virtual function void write(axi_transaction t);
		if (t == null) return;
		this.tr = t;

		if(t.is_write == 1'b1) begin
			cg_aw.sample();

			if(t.wstrb.size() >0) cg_wstrb.sample(tr.wstrb[0]);
			if(t.wdata.size() >0) wr_data_cg.sample(tr.wdata[0]);
		end else begin
			cg_ar.sample();

			if(t.rdata.size() >0) rd_data_cg.sample(tr.rdata[0]);
		end
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);

		`uvm_info("COV","----------------Report--------------",UVM_MEDIUM)
		`uvm_info("COV",$sformatf("cg_aw       :      %5.2f%%",cg_aw.get_coverage()),UVM_MEDIUM)
		`uvm_info("COV",$sformatf("cg_ar       :      %5.2f%%",cg_ar.get_coverage()),UVM_MEDIUM)
		`uvm_info("COV",$sformatf("wr_data_cg  :      %5.2f%%",wr_data_cg.get_coverage()),UVM_MEDIUM)
		`uvm_info("COV",$sformatf("rd_data_cg  :      %5.2f%%",rd_data_cg.get_coverage()),UVM_MEDIUM)
		`uvm_info("COV",$sformatf("cg_wstrb    :      %5.2f%%",cg_wstrb.get_coverage()),UVM_MEDIUM)
		`uvm_info("COV","------------------------------------",UVM_MEDIUM)
	endfunction

endclass











		
		
