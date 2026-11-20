class fix_sequence extends base_sequence;
	`uvm_object_utils(fix_sequence)

	function new(string name = "fix_sequence");
		super.new(name);
	endfunction

	task body();
		axi_transaction tr;
		bit [31:0] my_wdata[$];
		bit [3:0] my_wstrb[$];
		bit [15:0] cur_addr;
		bit [1:0] my_burst;
    bit [15:0] base_addr;
    bit [7:0] my_len;
    bit [2:0] my_size;

		my_burst = 2'b00;
		
		reset();
  //base overwrite 
    `uvm_info(get_type_name,"base overwrite 2byte",UVM_MEDIUM)
    base_addr    = 16'h1000;
		my_len	= 8'd3;
		my_size	= 3'd1;

		for(int i=0;i <= my_len;i++) begin
			cur_addr = calc_addr(base_addr,i,my_size,my_burst);
			my_wdata.push_back(32'h0000_0000 + i);
			my_wstrb.push_back(calc_wstrb (cur_addr,my_size));
		end

		write(8'h00,base_addr,my_len,my_size,my_burst,my_wstrb,my_wdata);
    `uvm_info(get_type_name(),"start fix write",UVM_MEDIUM)

		#10;
		
		read(8'h00,base_addr,my_len,my_size,my_burst);
    `uvm_info(get_type_name(),"start fix read",UVM_MEDIUM)

    `uvm_info(get_type_name(),"base overwrite 1byte",UVM_MEDIUM)
    my_wdata.delete();
    my_wstrb.delete();
    base_addr = 16'h2000;
    my_len = 8'd2;
    my_size = 8'd0;
    for(int i=0;i <= my_len;i++) begin
			cur_addr = calc_addr(base_addr,i,my_size,my_burst);
			my_wdata.push_back(32'h0000_0000 + i);
			my_wstrb.push_back(calc_wstrb (cur_addr,my_size));
		end

    write(8'h01,base_addr,my_len,my_size,my_burst,my_wstrb,my_wdata);
    `uvm_info(get_type_name(),"start fix write",UVM_MEDIUM)

		#10;
		
		read(8'h01,base_addr,my_len,my_size,my_burst);
    `uvm_info(get_type_name(),"start fix read",UVM_MEDIUM)

    //WSTRB Masking
    `uvm_info(get_type_name(),"WSTRB Masking",UVM_MEDIUM)
    my_wdata.delete();
    my_wstrb.delete();
    base_addr = 16'h1100;
    my_len = 8'd3;
    my_size = 8'd2;
    for(int i=0;i <= my_len;i++) begin
      case (i)
        0: my_wdata.push_back(32'hAAAA_AAAA);
        1: my_wdata.push_back(32'hBBBB_BBBB);
        2: my_wdata.push_back(32'hCCCC_CCCC);
        3: my_wdata.push_back(32'hDDDD_DDDD);
    endcase
    end
    //0xDDCCBBAA
    for(int i=0;i <= my_len;i++) begin
      case (i)
        0: my_wstrb.push_back(4'b0001);
        1: my_wstrb.push_back(4'b0010);
        2: my_wstrb.push_back(4'b0100);
        3: my_wstrb.push_back(4'b1000);
    endcase
    end

    write(8'h02,base_addr,my_len,my_size,my_burst,my_wstrb,my_wdata);
    `uvm_info(get_type_name(),"start fix write",UVM_MEDIUM)

		#10;
		
		read(8'h02,base_addr,my_len,my_size,my_burst);
    `uvm_info(get_type_name(),"start fix read",UVM_MEDIUM)

    //narrow transfer
    my_wdata.delete();
    my_wstrb.delete();
    base_addr = 16'h1102;
		my_len	= 8'd1;
		my_size	= 3'd1;
    //0xFFBBBBAA
		for(int i=0;i <= my_len;i++) begin
			cur_addr = calc_addr(base_addr,i,my_size,my_burst);
			 case (i)
        0: my_wdata.push_back(32'hEEAA_AAAA);
        1: my_wdata.push_back(32'hFFBB_BBBB);
    endcase
			my_wstrb.push_back(calc_wstrb (cur_addr,my_size));
		end

    write(8'h03,base_addr,my_len,my_size,my_burst,my_wstrb,my_wdata);
    `uvm_info(get_type_name(),"start fix write",UVM_MEDIUM)

		#10;
		
		read(8'h03,16'h1100,my_len,3'd2,my_burst);
    `uvm_info(get_type_name(),"start fix read",UVM_MEDIUM)

    //BUG test

    //overflow?
    base_addr = 16'hFFFC;
    my_size = 3'd2;
    my_len = 8'd3;

    for(int i=0;i <= my_len;i++) begin
			cur_addr = calc_addr(base_addr,i,my_size,my_burst);
			my_wdata.push_back(32'h0000_0000 + i);
			my_wstrb.push_back(calc_wstrb (cur_addr,my_size));
		end

		write(8'h04,base_addr,my_len,my_size,my_burst,my_wstrb,my_wdata);
    `uvm_info(get_type_name(),"start fix write",UVM_MEDIUM)

		#10;
		
		read(8'h04,base_addr,my_len,my_size,my_burst);
    `uvm_info(get_type_name(),"start fix read",UVM_MEDIUM)

    //wstrb = 0??
    my_wstrb.delete();
    for(int i=0;i <= my_len;i++) begin
      case (i)
        0: my_wstrb.push_back(4'b0000);
        1: my_wstrb.push_back(4'b0000);
        2: my_wstrb.push_back(4'b0000);
        3: my_wstrb.push_back(4'b0000);
    endcase
    end

    write(8'h05,base_addr,my_len,my_size,my_burst,my_wstrb,my_wdata);
    `uvm_info(get_type_name(),"start fix write",UVM_MEDIUM)

		#10;
		
		read(8'h05,base_addr,my_len,my_size,my_burst);
    `uvm_info(get_type_name(),"start fix read",UVM_MEDIUM)

	endtask
endclass

	
