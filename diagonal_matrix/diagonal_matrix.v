`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2023 12:47:36
// Design Name: 
// Module Name: diagonal_matrix
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


module diagonal_matrix #(parameter SIZE =4, 
                          parameter DATA_WIDTH = 32 )
                          (input clk, 
                           input rst,
                           input  [DATA_WIDTH-1:0] in_tdata,
                           input in_tvalid,
                           output  in_tready,
                           output  [DATA_WIDTH-1:0] out_tdata,
                           input out_tready,
                           output out_tvalid);

integer i=1;
integer j=1;
 
reg  [DATA_WIDTH-1:0] in_r_tdata, out_r_tdata;
reg in_r_tvalid;
reg in_r_tready;
reg out_r_tvalid;
//reg in_r_tready_1;

always@(posedge clk)
begin
    if(out_tready)
    begin
        in_r_tdata<=in_tdata;
        in_r_tvalid<=in_tvalid;
        in_r_tready<=in_tready;
    end
end
                           
always@(posedge clk)
begin
    if(rst)
    begin
        i<=1;
        j<=1;
        //in_r_tready_1<=1'b1;
        out_r_tdata<=32'd0;
        out_r_tvalid<=1'b0;
    end
    else
    begin
        //out_r_tdata<=in_r_tdata;
        if(in_r_tvalid && in_r_tready && out_tready)
        begin
            out_r_tdata<=in_r_tdata;
            //in_r_tready_1<=1'b1;
            if(j==i)
                out_r_tvalid<=1'b1;
            else
                out_r_tvalid<=1'b0;
            if(i<=SIZE )
            begin
                if(j<SIZE)
                    j<=j+1;
                else
                begin
                    j<=1;
                    i=i+1;
                    if(i>SIZE)
                        i<=1;
                end
            end
            else
            begin
                i<=1;
                j<=1;
            end
        end
        else if(in_r_tvalid && in_r_tready && !out_tready)
        begin
            i<=i;
            j<=j;
            if(i>=j)
                out_r_tvalid<=1'b1;
            else
                out_r_tvalid<=1'b0;
            //in_r_tready_1<=1'b0;
            out_r_tdata<=out_r_tdata;
        end
        else
        begin
            i<=i;
            j<=j;
            out_r_tvalid<=1'b0;
           // in_r_tready_1<=1'b1;
        end
    end
end


assign in_tready=out_tready;
assign out_tdata=out_r_tvalid?out_r_tdata:out_tdata;
assign out_tvalid=out_r_tvalid;

endmodule
