`timescale 1ns / 1ps

`ifndef USE_RAM
    `define USE_RAM 0
`endif

`define DATA_W 16
`define N_WORDS 8000
`define ADDR_W $clog2(`N_WORDS*`DATA_W/8)
`define TILE_ADDR_W 13

module iob_2p_ram_tiled_tb;

    // Inputs
    reg clk;
    reg w_en;
    reg r_en;
    reg [`DATA_W-1:0] w_data;
    reg [`ADDR_W-1:0] addr;

    // Outputs
    wire [`DATA_W-1:0] r_data;

    integer i, seq_ini;
    integer test, base_block;

    parameter clk_per = 10; // clk period = 10 timeticks

    // Instantiate the Unit Under Test (UUT)
    iob_2p_ram_tiled #(
        .DATA_W(`DATA_W),
        .N_WORDS(`N_WORDS),
        .USE_RAM(`USE_RAM),
        .TILE_ADDR_W(`TILE_ADDR_W)
    ) uut (
        .clk(clk), 
        .w_en(w_en),
        .r_en(r_en), 
        .w_data(w_data), 
        .addr(addr), 
        .r_data(r_data)
    );

    // system clock
    always #(clk_per/2) clk = ~clk; 

    initial begin
        // Initialize Inputs
        clk = 1;
        addr = 0;
        w_en = 0;
        r_en = 0;
        w_data = 0;

        // Number from which to start the incremental sequence to write into the RAM
        seq_ini = 32;

        // optional VCD
        `ifdef VCD
            if(`USE_RAM == 1) begin
                $dumpfile("tiled_ram.vcd");
                $dumpvars();
            end
            if(`USE_RAM == 0) begin
                $dumpfile("tiled.vcd");
                $dumpvars();
            end
        `endif

        @(posedge clk) #1;
        w_en = 1;

        //Write all the locations of RAM 
        for(i = 0; i < 16; i = i + 1) begin
            w_data = i + 32;
            addr = i;
            @(posedge clk) #1;
        end

        w_en = 0;    
        @(posedge clk) #1;

        //Read all the locations of RAM with r_en = 0
        r_en = 0;
        @(posedge clk) #1;

        if(`USE_RAM == 1) begin
            for(i = 0; i < 16; i = i + 1) begin
                addr = i;
                @(posedge clk) #1;
                if(r_data!=0) begin
                    $display("Test 1 failed: with r_en = 0, at position %0d, r_data should be 0 but is %d", i, r_data);
                    $finish;
                end
            end
        end

        r_en = 1;
        @(posedge clk) #1;

        //Read all the locations of RAM with r_en = 1
        for(i = 0; i < 16; i = i + 1) begin
            addr = i;
            @(posedge clk) #1;
            if(r_data!=i+32) begin
                $display("Test 2 failed: on position %0d, r_data is %d where it should be %0d", i, r_data, i+32);
                $finish;
            end
        end

        r_en = 0;

        #(5*clk_per);
        $display("%c[1;34m",27);
        $display("Test completed successfully.");
        $display("%c[0m",27);
        $finish;
    end
endmodule
