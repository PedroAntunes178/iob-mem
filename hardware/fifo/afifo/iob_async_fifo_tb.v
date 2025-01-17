`timescale 1ns / 1ps

`define DATA_W 8
`define ADDR_W 4

module iob_async_fifo_tb;
   
   //Inputs
   reg reset;
   reg read;
   bit rclk;
   reg [`DATA_W-1:0] w_data;
   reg write;
   bit wclk;
     
   //Outputs
   reg [`DATA_W-1:0] r_data;
   wire empty_out;
   wire [`ADDR_W-1:0] level_r;
   wire full_out;
   wire [`ADDR_W-1:0] level_w;

   integer i;

   parameter clk_per = 10; // clk period = 10 timeticks
   

   initial begin
       // optional VCD
       `ifdef VCD
            $dumpfile("iob_async_fifo.vcd");
            $dumpvars();
       `endif
         
       //Initialize Inputs
       rclk = 0;
       wclk = 1;
       reset = 0;
       w_data = 0;
       read = 0;
       write = 0;

       //Write all the locations of FIFO
       #clk_per;
       @(posedge wclk) #1;
       reset = 1;
       @(posedge wclk) #1;
       reset = 0;
       
       @(posedge wclk) #1;
       write = 1;
       for(i=0; i < 15; i = i + 1) begin
           if(level_w !=i ) begin
               $display("Test failed: write error in w_data.\n \t i=%0d; data=%0d; level_w=%0d", i, w_data, level_w);
               $finish;
           end
           w_data = i;
           @(posedge wclk) #1;
       end
     
       @(posedge wclk) #1;
       write = 0; //Fifo is now full
       if(full_out!=1 || level_w!=15) begin
           $display("Test failed: fifo not full.");
           $finish;
       end
       
       #clk_per
       @(posedge rclk) #1;
       read=1;
       //Read all the locations of RAM.
       for(i=0; i < 15; i = i + 1) begin
           // Result will only be available in the next cycle
           @(posedge rclk) #1;
           if(r_data != i || level_r != 14-i) begin
               $display("Test failed: read error in r_data.\n \t i=%0d; data=%0d", i, r_data);
               $finish;
           end
       end

       @(posedge rclk) #1;
       read = 0; //Fifo is now empty
       @(posedge rclk) #1;
       if(empty_out!=1 || level_r!=0) begin
           $display("Test failed: fifo not empty.\n \t");
           $finish;
       end

       #clk_per
        $display("%c[1;34m",27);
        $display("Test completed successfully.");
        $display("%c[0m",27);
       #(5*clk_per) $finish;

   end

      // Instantiate the Unit Under Test (UUT)
   iob_async_fifo #(
       .DATA_WIDTH(`DATA_W),
       .ADDRESS_WIDTH(`ADDR_W)
   ) uut (
       .rst(reset),
       .r_data(r_data),
       .empty(empty_out),
       .level_r(level_r),
       .read_en(read),
       .rclk(rclk),
       .w_data(w_data),
       .full(full_out),
       .level_w(level_w),
       .write_en(write),
       .wclk(wclk)
   );
   
   // system clock
   always #(clk_per/2) wclk = ~wclk;
   always #(clk_per/2) rclk = ~rclk;

endmodule // iob_async_fifo_tb
