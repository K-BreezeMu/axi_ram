class base_sequence extends uvm_sequence #(axi_transaction);
       `uvm_object_utils(base_sequence)

	function new(string name = "base_sequence");
		super.new(name);
	endfunction

	virtual task write (bit [7:0] id,bit [15:0] awaddr,bit [7:0] awlen,bit [2:0] awsize,bit [1:0] awburst,bit [3:0] wstrb[$],bit [31:0] wdata[$]);
		 axi_transaction tr;
		 tr = axi_transaction::type_id::create("tr");
		 start_item(tr);
		 tr.is_write = 1'b1;
		 tr.id = id;
		 tr.awlen = awlen;
		 tr.awsize = awsize;
		 tr.awaddr = awaddr;
		 tr.awburst = awburst;
		 tr.wdata = wdata;
		 tr.wstrb = wstrb;
		 finish_item(tr);
	 endtask

	 virtual task read (bit [7:0] id,bit [15:0] araddr,bit [7:0] arlen,bit [2:0] arsize,bit [1:0] arburst);
		 axi_transaction tr;
		 tr = axi_transaction::type_id::create("tr");
		 start_item(tr);
		 tr.is_write = 1'b0;
		 tr.id = id;
		 tr.arlen = arlen;
		 tr.arsize = arsize;
		 tr.araddr = araddr;
		 tr.arburst = arburst;
		 finish_item(tr);
	 endtask

	 virtual task reset();
		 axi_transaction tr;
		 tr = axi_transaction::type_id::create("tr");
		 start_item(tr);
		 tr.resetn = 1'b1;
		 finish_item(tr);
	 endtask

	 function bit [3:0] calc_wstrb(bit [15:0] addr,bit [2:0] size);
		 int start_lane;
		 int num_bytes;
		 bit [3:0] strb;

		 start_lane = addr % 4;
		 num_bytes = 1 << size;
		 strb	= 4'b0000;
		 for(int i=0;i<num_bytes;i++) begin
			 if((start_lane + i)<4) begin
				 strb[start_lane + i] = 1'b1;
			 end
		 end
		 return strb;
	 endfunction

	 function bit [15:0] calc_addr(bit [15:0] base_addr,int beat,bit [2:0] size,bit [1:0] burst);
		 if(burst == 2'b00) begin
			 return base_addr;
		 end else begin
			 return base_addr + (beat * (1<<size));
		 end
	 endfunction
 endclass


		 
