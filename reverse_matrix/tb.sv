`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2023 10:56:38
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb();

 parameter SIZE_tb=6;
    parameter DATA_WIDTH_tb= 8;

   reg clk_tb; 
   reg rst_tb;
   reg  [DATA_WIDTH_tb-1:0] in_tdata_tb;
   reg in_tvalid_tb;
   reg in_tlast_tb;
   wire in_tread_tby;
   wire  [DATA_WIDTH_tb-1:0] out_tdata_tb;
   reg out_tready_tb;
   wire out_tvalid_tb;
   wire out_tlast_tb;
wire [2:0] state_tb;
wire [6:0] num_tb;

reverse_matrix   #(.SIZE(6), .DATA_WIDTH(8)) inst_1  ( clk_tb, 
                            rst_tb,
                            in_tdata_tb,
                            in_tvalid_tb,
                            in_tlast_tb,
                            in_tready_tb,
                            out_tdata_tb,
                            out_tready_tb,
                            out_tvalid_tb,
                            out_tlast_tb
                            );
                            
  initial
  begin
    clk_tb=1'b0;
    forever #10 clk_tb=~clk_tb;
  end

task in_data();
begin
    //@(posedge clk_tb)
    in_tdata_tb<=$random;
    in_tvalid_tb<=1'b1;
    //@(posedge clk_tb)
    if(in_tready_tb)
    begin
        @(posedge clk_tb)
        in_tvalid_tb<=1'b0;
    end
    else
    begin
        while(!in_tready_tb)
        begin
            @(posedge clk_tb)
            in_tvalid_tb<=1'b1;
        end
        @(posedge clk_tb)
        in_tvalid_tb<=1'b0;
    end
end
endtask

task in_data_not();
begin
    //@(posedge clk_tb)
    in_tdata_tb<=$random;
    in_tvalid_tb<=1'b0;
    //@(posedge clk_tb)
    if(in_tready_tb)
    begin
        @(posedge clk_tb)
        in_tvalid_tb<=1'b0;
    end
    else
    begin
        while(!in_tready_tb)
        begin
            @(posedge clk_tb)
            in_tvalid_tb<=1'b0;
        end
        @(posedge clk_tb)
        in_tvalid_tb<=1'b0;
    end
end
endtask

task in_rst(input rst);
begin
    rst_tb<=rst;
end
endtask

initial
begin
    in_rst(1);
    #20;
    in_rst(0);
    #10;
   repeat(3)
   begin
        
        repeat(36)
        begin
            in_data();
        end
        //in_tlast_tb<=1'b1;
        //in_data_not();
        //@(posedge clk_tb)
        //in_tlast_tb<=1'b0;
        //in_data_not();
        //in_data_not();
//        repeat(10)
//        begin
//            in_data();
//        end
        in_tlast_tb<=1'b1;
        in_data();
        //@(posedge clk_tb)
        in_tlast_tb<=1'b0;
    end
    in_tvalid_tb<=1'b0;
    
//    #650;
//    repeat(35)
//        begin
//            in_data();
//        end
end

initial
begin
     #10;
     out_tready_tb<=1'b1;
     #500;
     //out_tready_tb<=1'b0;
     #20;
     out_tready_tb<=1'b1;
     //forever #20 out_tready_tb<=~out_tready_tb;
end


endmodule
