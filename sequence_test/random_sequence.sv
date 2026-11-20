class random_sequence extends base_sequence;
    `uvm_object_utils(random_sequence)

    rand bit [15:0] r_addr;
    rand bit [7:0]  r_len;
    rand bit [2:0]  r_size;
    rand bit [1:0]  r_burst;
    rand int        r_wstrb_sel;

    function new(string name = "random_sequence");
        super.new(name);
    endfunction

    constraint c_random_cfg {
        r_burst dist { 2'b00 := 30, 2'b01 := 70 };
        
        r_size dist { 3'd0 := 30, 3'd1 := 40, 3'd2 := 30 };
        
        r_len dist { 
            8'd0 := 10, 
            8'd1 := 10, 
            8'd7 := 20, 
            8'd15 := 20, 
            8'd255 := 5, 
            [8'd2 : 8'd6] := 15,
            [8'd8 : 8'd14] := 10,
            [8'd16 : 8'd254] := 10
        };

        r_addr dist {
            16'h0000 := 5,
            16'hFFFC := 5,
            [16'h0001 : 16'h3FFF] := 30,
            [16'h4000 : 16'hBFFF] := 30,
            [16'hC000 : 16'hFFFB] := 30
        };

        r_wstrb_sel dist { 0 := 90, 1 := 10 };

        if (r_size == 3'd2) {
            (r_addr + ((r_len + 1) * 4)) <= 65536;
            (r_addr % 4096) + ((r_len + 1) * 4) <= 4096;
        } else if (r_size == 3'd1) {
            (r_addr + ((r_len + 1) * 2)) <= 65536;
            (r_addr % 4096) + ((r_len + 1) * 2) <= 4096;
        } else {
            (r_addr + ((r_len + 1) * 1)) <= 65536;
            (r_addr % 4096) + ((r_len + 1) * 1) <= 4096;
        }

        solve r_size before r_addr;
        solve r_size before r_len;
        solve r_len before r_addr;
    }

    task body();
        bit [31:0] my_wdata[$];
        bit [3:0]  my_wstrb[$];
        bit [15:0] cur_addr;
        bit [15:0] base_addr;
        bit [7:0]  my_len;
        bit [2:0]  my_size;
        bit [1:0]  my_burst;
        bit [31:0] rand_val;
        int        num_loops = 200;


        reset();
        `uvm_info(get_type_name(), $sformatf("Starting %0d Random Tests...", num_loops), UVM_LOW)

        repeat(num_loops) begin
            if (!this.randomize()) begin
                `uvm_fatal("SEQ", "Randomize failed!")
            end

            my_wdata.delete();
            my_wstrb.delete();

            for (int i = 0; i <= r_len; i++) begin
                cur_addr = calc_addr(r_addr, i, r_size, r_burst);
                
                rand_val = $urandom();
                
                if (i == 0) begin
                    case ($urandom_range(0, 4))
                        0: rand_val = 32'h0000_0000;
                        1: rand_val = 32'hFFFF_FFFF;
                        2: rand_val = 32'hAAAA_AAAA;
                        3: rand_val = 32'h5555_5555;
                        4: rand_val = r_addr; 
                    endcase
                end

                if (r_wstrb_sel == 1 && r_len == 0) begin
                    my_wstrb.push_back($urandom_range(0, 15));
                end else begin
                    my_wstrb.push_back(calc_wstrb(cur_addr, r_size));
                end
                
                my_wdata.push_back(rand_val);
            end

            if (num_loops <= 10 || ($urandom_range(0, 9) == 0)) begin
                `uvm_info("SEQ", $sformatf("Rand Pkt: addr=0x%04h, len=%0d, size=%0d, burst=%0d, wstrb[0]=%04b", 
                          r_addr, r_len, r_size, r_burst, my_wstrb[0]), UVM_MEDIUM)
            end

            write(8'hAA, r_addr, r_len, r_size, r_burst, my_wstrb, my_wdata);
            #5; 
            read(8'hAA, r_addr, r_len, r_size, r_burst);
            #5;
        end

        `uvm_info(get_type_name(), "Coverage Boost: Special WSTRB & WDATA", UVM_LOW)
        my_wdata.delete();
        my_wstrb.delete();
        base_addr = 16'h5000;
        my_len    = 8'd3;
        my_size   = 3'd2; 
        my_burst  = 2'b01;

        my_wdata.push_back(32'h0000_0000); my_wstrb.push_back(4'b0000);
        my_wdata.push_back(32'hFFFF_FFFF); my_wstrb.push_back(4'b1111);
        my_wdata.push_back(32'hAAAA_AAAA); my_wstrb.push_back(4'b0011);
        my_wdata.push_back(32'h5555_5555); my_wstrb.push_back(4'b1100);
        
        write(8'hBB, base_addr, my_len, my_size, my_burst, my_wstrb, my_wdata);
        #10;
        read(8'hBB, base_addr, my_len, my_size, my_burst);
        #20;

        `uvm_info(get_type_name(), "Coverage Boost: Max Length 255", UVM_LOW)
        my_wdata.delete();
        my_wstrb.delete();
        base_addr = 16'h6000;
        my_len    = 8'd255;
        my_size   = 3'd0;
        for(int i=0; i<=my_len; i++) begin
            my_wdata.push_back(32'h1234_5678);
            my_wstrb.push_back(4'b0001);
        end
        write(8'hCC, base_addr, my_len, my_size, my_burst, my_wstrb, my_wdata);
        #10;
        read(8'hCC, base_addr, my_len, my_size, my_burst);
        #20;
        `uvm_info(get_type_name(), "Coverage Boost: Hit All WDATA Bins", UVM_LOW)
        my_wdata.delete();
        my_wstrb.delete();
        base_addr = 16'h7000;
        my_len    = 8'd11; 
        my_size   = 3'd2;

        my_wdata.push_back(32'h0000_0000); // zero
        my_wdata.push_back(32'hFFFF_FFFF); // full
        my_wdata.push_back(32'hAAAA_AAAA); // mode_aa
        my_wdata.push_back(32'h5555_5555); // mode_55
        my_wdata.push_back(32'h1234_5678); // low
        my_wdata.push_back(32'h2345_6789); // mid_1
        my_wdata.push_back(32'h4567_89AB); // mid_2
        my_wdata.push_back(32'h6789_ABCD); // mid_3
        my_wdata.push_back(32'h89AB_CDEF); // mid_4
        my_wdata.push_back(32'hA123_4567); // mid_5
        my_wdata.push_back(32'hC123_4567); // mid_6
        my_wdata.push_back(32'hE123_4567); // high

        for(int i=0; i<=my_len; i++) begin
            my_wstrb.push_back(4'b1111);
        end

        write(8'hDD, base_addr, my_len, my_size, 2'b01, my_wstrb, my_wdata);
        #10;
        read(8'hDD, base_addr, my_len, my_size, 2'b01);
        #20;

        coverage_boost();
    endtask
        task coverage_boost();
        bit [31:0] my_wdata[$];
        bit [3:0]  my_wstrb[$];
        bit [15:0] base_addr;
        bit [7:0]  my_len;
        bit [2:0]  my_size;
        bit [1:0]  my_burst;

        `uvm_info(get_type_name(), "--- STAGE 1: Data Pattern Boost ---", UVM_LOW)
         my_wdata.delete(); my_wstrb.delete();
        base_addr = 16'h7000; 
        my_len    = 8'd11;         
        my_size   = 3'd2;
        my_burst  = 2'b01;
        my_wdata.push_back(32'h0000_0000); // zero
        my_wdata.push_back(32'hFFFF_FFFF); // full
        my_wdata.push_back(32'hAAAA_AAAA); // mode_aa
        my_wdata.push_back(32'h5555_5555); // mode_55
        my_wdata.push_back(32'h1000_0000); // low
        my_wdata.push_back(32'h2500_0000); // mid_1
        my_wdata.push_back(32'h4500_0000); // mid_2
        my_wdata.push_back(32'h6500_0000); // mid_3
        my_wdata.push_back(32'h8500_0000); // mid_4
        my_wdata.push_back(32'hA500_0000); // mid_5
        my_wdata.push_back(32'hC500_0000); // mid_6
        my_wdata.push_back(32'hE500_0000); // high
        
        for(int i=0; i<=my_len; i++) my_wstrb.push_back(4'b1111);
        write(8'hD1, base_addr, my_len, my_size, my_burst, my_wstrb, my_wdata);
        #10; read(8'hD1, base_addr, my_len, my_size, my_burst); #20;

        `uvm_info(get_type_name(), "--- STAGE 2: Extreme ID & Addr Boost ---", UVM_LOW)
        base_addr = 16'h0000;         my_len    = 8'd0;
        my_size   = 3'd2;
        
        write(8'h00, base_addr, my_len, my_size, 2'b01, '{4'b1111}, '{32'h1234_5678});
        #10; read(8'h00, base_addr, my_len, my_size, 2'b01); #10;

        write(8'hFF, base_addr, my_len, my_size, 2'b01, '{4'b1111}, '{32'h1234_5678});
        #10; read(8'hFF, base_addr, my_len, my_size, 2'b01); #10;

        base_addr = 16'hFFFC;         write(8'hFF, base_addr, my_len, my_size, 2'b01, '{4'b1111}, '{32'h1234_5678});
        #10; read(8'hFF, base_addr, my_len, my_size, 2'b01); #10;


        `uvm_info(get_type_name(), "--- STAGE 3: Extreme Lengths Boost ---", UVM_LOW)
         my_wdata.delete(); my_wstrb.delete();
        base_addr = 16'h8000; my_size = 3'd2; my_burst = 2'b01;
        
        my_len = 8'd15;
        for(int i=0; i<=my_len; i++) begin
            my_wdata.push_back($urandom()); my_wstrb.push_back(4'b1111);
        end
        write(8'hAA, base_addr, my_len, my_size, my_burst, my_wstrb, my_wdata);
        #20; read(8'hAA, base_addr, my_len, my_size, my_burst); #20;

        my_wdata.delete(); my_wstrb.delete();
        base_addr = 16'h9000; my_size = 3'd0;         my_len = 8'd255;
        for(int i=0; i<=my_len; i++) begin
            my_wdata.push_back($urandom()); my_wstrb.push_back(4'b0001);
        end
        write(8'hAA, base_addr, my_len, my_size, my_burst, my_wstrb, my_wdata);
        #50; read(8'hAA, base_addr, my_len, my_size, my_burst); #20;


        `uvm_info(get_type_name(), "--- STAGE 4: Cross Coverage (FIXED) Boost ---", UVM_LOW)
        base_addr = 16'hA000; my_len = 8'd0; my_burst = 2'b00;
        
        // FIXED + 1 byte
        write(8'hBB, base_addr, my_len, 3'd0, my_burst, '{4'b0001}, '{32'h1111_1111}); #10;
        // FIXED + 2 byte
        write(8'hBB, base_addr, my_len, 3'd1, my_burst, '{4'b0011}, '{32'h2222_2222}); #10;
        // FIXED + 4 byte
        write(8'hBB, base_addr, my_len, 3'd2, my_burst, '{4'b1111}, '{32'h3333_3333}); #10;

    endtask

endclass
