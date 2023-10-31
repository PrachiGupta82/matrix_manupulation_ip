`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2023 15:12:13
// Design Name: 
// Module Name: upper_triangular
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


module upper_triangular #(parameter SIZE =4, 
                          parameter DATA_WIDTH = 32 )
                          (input clk, 
                           input rst,
                           input  [DATA_WIDTH-1:0] in_tdata,
                           input in_tvalid,
                           output  in_tready,
                           output  [DATA_WIDTH-1:0] out_tdata,
                           input out_tready,
                           output out_tvalid);

// registers for internal counting 
integer i=1;
integer j=1;
 
// register the input data, valid and ready signals in respective internal registers. 
reg  [DATA_WIDTH-1:0] in_r_tdata, out_r_tdata;
reg in_r_tvalid;
reg in_r_tready;
reg out_r_tvalid;

// register the input data, valid and ready signals in respective internal registers.
always@(posedge clk)
begin
    if(out_tready)
    begin
        in_r_tdata<=in_tdata;
        in_r_tvalid<=in_tvalid;
        in_r_tready<=in_tready;
    end
end

// to check if the input data received is the upper triangular elements of input matrix or not and if it is then sending them at the out_r_tdata register by making out_r_tvalid as  1                                                        
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
            if(j>=i)
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

