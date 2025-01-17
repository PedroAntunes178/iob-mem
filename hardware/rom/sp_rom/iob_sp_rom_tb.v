`timescale 1ns / 1ps

`define DATA_W 8
`define ADDR_W 4
`define hex_file "tb1.hex"

module iob_sp_rom_tb;
	
	//Inputs
	reg clk;
    reg r_en;
    reg [`ADDR_W-1:0] addr;
   	
   	//Ouptuts
   	reg [`DATA_W-1:0] r_data;

    // .hex file
    reg [7:0] filemem [0:15];

    integer i;

    parameter clk_per = 10; // clk period = 10 timeticks
    

    initial begin
        // optional VCD
        `ifdef VCD
      	   $dumpfile("iob_sp_rom.vcd");
      	   $dumpvars();
        `endif
      	
        //Initialize Inputs
        clk = 1;
        r_en = 0;
        addr = 0;

        // store file for comparison
        #clk_per
        @(posedge clk) #1;
        $readmemh(`hex_file, filemem);


        @(posedge clk) #1;
        r_en = 1;

        @(posedge clk) #1;
        for(i = 0; i < 16; i = i + 1) begin
            addr = i;
            @(posedge clk) #1;
            if(filemem[i]!=r_data) begin
                $display("Test failed: read error in position %d, where tb.hex=%h but r_data=%h", i, filemem[i], r_data);
                $finish;
            end
        end

        @(posedge clk) #1;
        r_en = 0;
        
        #clk_per
        $display("%c[1;34m",27);
        $display("Test completed successfully.");
        $display("%c[0m",27);
        #(5*clk_per) $finish;

    end

   	// Instantiate the Unit Under Test (UUT)
    iob_sp_rom #(
    	.DATA_W(`DATA_W), 
    	.ADDR_W(`ADDR_W),
    	.FILE(`hex_file)
	) uut (
		.clk(clk), 
		.r_en(r_en), 
		.addr(addr), 
		.r_data(r_data)
	);
    
    // system clock
	always #(clk_per/2) clk = ~clk; 

endmodule // iob_sp_rom_tb
