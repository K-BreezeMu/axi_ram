class incr_sequence extends base_sequence;
    `uvm_object_utils(incr_sequence)

    function new(string name = "incr_sequence");
        super.new(name);
    endfunction

    task body();
        bit [31:0] my_wdata[$];
        bit [3:0]  my_wstrb[$];
        bit [15:0] cur_addr;
        bit [1:0]  my_burst;
        bit [15:0] base_addr;
        bit [7:0]  my_len;
        bit [2:0]  my_size;

        my_burst = 2'b01; 
        reset();

        `uvm_info(get_type_name(), "INCR Unaligned 4-byte Start at 0x1002", UVM_MEDIUM)
        my_wdata.delete();
        my_wstrb.delete();
        
        base_addr = 16'h1002; 
        my_len    = 8'd3;     
        my_size   = 3'd2;     

        for(int i=0; i <= my_len; i++) begin
            cur_addr = calc_addr(base_addr, i, my_size, my_burst);
            my_wdata.push_back(32'hAABB0000 + i); 
            my_wstrb.push_back(calc_wstrb(cur_addr, my_size));
        end
        write(8'h20, base_addr, my_len, my_size, my_burst, my_wstrb, my_wdata);
        #10;
        read(8'h20, base_addr, my_len, my_size, my_burst);
        #20;

        `uvm_info(get_type_name(), "INCR Max Length 256 Beats", UVM_MEDIUM)
        my_wdata.delete();
        my_wstrb.delete();
        
        base_addr = 16'h4000; 
        my_len    = 8'd255;    
        my_size   = 3'd1;      

        for(int i=0; i <= my_len; i++) begin
            cur_addr = calc_addr(base_addr, i, my_size, my_burst);
            my_wdata.push_back(32'h5555_0000 + i); 
            my_wstrb.push_back(calc_wstrb(cur_addr, my_size));
        end
        write(8'h21, base_addr, my_len, my_size, my_burst, my_wstrb, my_wdata);
        #50;
        read(8'h21, base_addr, my_len, my_size, my_burst);
        #20;

        `uvm_info(get_type_name(), "INCR Multi-packet Overwrite", UVM_MEDIUM)
        my_wdata.delete();
        my_wstrb.delete();
        base_addr = 16'h2000;
        my_len    = 8'd3;
        my_size   = 3'd2;
        for(int i=0; i <= my_len; i++) begin
            cur_addr = calc_addr(base_addr, i, my_size, my_burst);
            my_wdata.push_back(32'h1111_1111); 
            my_wstrb.push_back(4'b1111); 
        end
        write(8'h22, base_addr, my_len, my_size, my_burst, my_wstrb, my_wdata);
        #10;

        my_wdata.delete();
        my_wstrb.delete();
        for(int i=0; i <= my_len; i++) begin
            cur_addr = calc_addr(base_addr, i, my_size, my_burst);
            my_wdata.push_back(32'h2222_2222); 
            my_wstrb.push_back(4'b1111); 
        end
        write(8'h22, base_addr, my_len, my_size, my_burst, my_wstrb, my_wdata);
        #10;
        
        read(8'h22, base_addr, my_len, my_size, my_burst);
        #20;

        `uvm_info(get_type_name(), "INCR Partial Overwrite with Mask", UVM_MEDIUM)
        my_wdata.delete();
        my_wstrb.delete();
        base_addr = 16'h3000;
        my_len    = 8'd1;
        my_size   = 3'd2;
        for(int i=0; i <= my_len; i++) begin
            cur_addr = calc_addr(base_addr, i, my_size, my_burst);
            my_wdata.push_back(32'hFFFFFFFF); 
            my_wstrb.push_back(4'b1111); 
        end
        write(8'h23, base_addr, my_len, my_size, my_burst, my_wstrb, my_wdata);
        #10;

        my_wdata.delete();
        my_wstrb.delete();
        base_addr = 16'h3004;
        my_len    = 8'd0; 
        my_size   = 3'd2;
        my_wdata.push_back(32'h1234_AAAA); 
        my_wstrb.push_back(4'b0011); 
        write(8'h23, base_addr, my_len, my_size, my_burst, my_wstrb, my_wdata);
        #10;

        read(8'h23, base_addr, my_len, my_size, my_burst);
        #20;

        `uvm_info(get_type_name(), "INCR 4KB Boundary Danger", UVM_MEDIUM)
        my_wdata.delete();
        my_wstrb.delete();
        base_addr = 16'h1FFC; 
        my_len    = 8'd0;     
        my_size   = 3'd2;
        my_wdata.push_back(32'h9999_9999); 
        my_wstrb.push_back(4'b1111);
        write(8'h24, base_addr, my_len, my_size, my_burst, my_wstrb, my_wdata);
        #10;
        read(8'h24, base_addr, my_len, my_size, my_burst);
        #20;

    endtask
endclass
