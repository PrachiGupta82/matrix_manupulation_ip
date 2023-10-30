`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2023 14:14:22
// Design Name: 
// Module Name: matrix_tranpose
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

module reverse_matrix #(parameter SIZE =4, 
                          parameter DATA_WIDTH = 32 )
                          (input clk, 
                           input rst,
                           input  [DATA_WIDTH-1:0] in_tdata,
                           input in_tvalid,
                           input in_tlast,
                           output in_tready,
                           output  [DATA_WIDTH-1:0] out_tdata,
                           input out_tready,
                           output out_tvalid,
                           output out_tlast);
                           
   reg [DATA_WIDTH-1:0] mem1 [0:SIZE-1][0:SIZE-1];     
   reg [DATA_WIDTH-1:0] mem2 [0:SIZE-1][0:SIZE-1];     
   
   integer read_count_mem1, read_count_mem2, read_r_mem1, read_r_mem2;
   
   reg [DATA_WIDTH-1:0] L1_r_data;
   reg L1_r_tvalid;
   reg L1_r_tready;
   
   parameter half_size=DATA_WIDTH/2;
      
   integer i_1;
   integer j_1;
   integer i_2;
   integer j_2;
   
   wire [DATA_WIDTH-1:0] r_out_tdata;
   reg r_out_tvalid;
   reg L4_r_tlast;
   

   reg [0:0] sel_mem_wr, sel_mem_rd;
   parameter count=SIZE*SIZE;
   integer loop_num;
   integer out_count;
   
   always@(posedge clk)                                                                                                 //  L1 stage
    begin
        if(rst)
        begin
            L1_r_data<=32'd0;
        end
        else 
        begin
            if(in_tready)
            begin
                L1_r_data<=in_tdata;
                L1_r_tready<=in_tready;
                L1_r_tvalid<=in_tvalid;
            end
            else
            begin
                L1_r_data<=L1_r_data;
                L1_r_tvalid<=L1_r_tvalid;
                L1_r_tready<=L1_r_tready;
            end
        end
    end

    integer write_count1, write_count2;
    

    reg mem1_ready=0;
    reg mem2_ready=0;
    
    always@(posedge clk)                                                                                                        //writing in mem1  
    begin
        if(rst)
        begin
            i_1<=SIZE-1;
            j_1<=SIZE-1;
            sel_mem_wr<=0;
            write_count1<=0;
        end
        else
        begin
            if(!sel_mem_wr && !mem1_ready)
            begin
                if((i_1>=0) && L1_r_tready && L1_r_tvalid)
                begin
                    if((j_1>0))
                    begin
                        mem1[i_1][j_1]<=L1_r_data;
                        j_1<=j_1-1;
                        write_count1<=write_count1+1;
                    end
                    else if( (j_1==0) && (i_1==0))
                    begin
                        mem1[i_1][j_1]<=L1_r_data;
                        j_1<=SIZE-1;
                        i_1<=SIZE-1;
                        write_count1<=0;
                    end
                    else
                    begin
                        mem1[i_1][j_1]<=L1_r_data;
                        j_1<=SIZE-1;
                        if((i_1==0))
                        begin
                            i_1<=SIZE-1;
                            write_count1<=0;
                        end
                        else
                        begin
                            i_1<=i_1-1;
                            write_count1<=write_count1+1;
                        end
                    end
                    
                end
                else 
                begin
                    if(i_1==0 && j_1==0)
                    begin
                        i_1<=SIZE-1;
                        j_1<=SIZE-1;
                        write_count1<=0;
                    end
                    else
                    begin
                        i_1<=i_1;
                        j_1<=j_1;
                    end
                end 
             end
             
        end
    end


   always@(posedge clk)                                                                            //writing in mem2
    begin
        if(rst)
        begin
            i_2<=SIZE-1;
            j_2<=SIZE-1;
            write_count2<=0;
        end
        else 
        begin
            //L4_r_tlast<=L3_r_tlast;
            if(sel_mem_wr && !mem2_ready)
            begin
                if((i_2>=0) && L1_r_tready && L1_r_tvalid)
                begin
                    if((j_2>0) )
                    begin
                        mem2[i_2][j_2]<=L1_r_data;
                        j_2<=j_2-1;
                        write_count2<=write_count2+1;
                    end
                    else if( (j_2==SIZE-1) && (i_2==SIZE-1))
                    begin
                        mem2[i_2][j_2]<=L1_r_data;
                        j_2<=SIZE-1;
                        i_2<=SIZE-1;
                        write_count2<=0;
                    end
                    else
                    begin
                        mem2[i_2][j_2]<=L1_r_data;
                        j_2<=SIZE-1;
                        if((i_2==0))
                        begin
                            i_2<=SIZE-1;
                            write_count2<=0;
                        end
                        else
                        begin
                            i_2<=i_2-1;
                            write_count2<=write_count2+1;
                        end
                    end
                end
                else
                begin
                    i_2<=i_2;
                    j_2<=j_2;
                end  
             end            
        end
    end
    
    

    reg reg_ready1;
    reg reg_ready2;
    
    always@(posedge clk)
    begin
        reg_ready1<=mem1_ready;
        reg_ready2<=mem2_ready;
    end
    
    always@(posedge clk)
    begin
        if(rst)
            sel_mem_wr<=0;
        else
        begin
            if(((write_count1==count-1) || (write_count2==count-1)) && L1_r_tvalid && L1_r_tready)
                sel_mem_wr<=!sel_mem_wr;
//            else if((write_count1==0) || (write_count2==0))
//                sel_mem_wr<=1'b0;
            else 
                sel_mem_wr<=sel_mem_wr;
        end
    end
    
//    always@(posedge clk)
//    begin
//        if(rst)
//            sel_mem_wr<=0;
//        else
//        begin
//            if((loop_num==count-1) && L1_r_tvalid && L1_r_tready && !(mem1_ready && mem2_ready))
//                sel_mem_wr<=!sel_mem_wr;
////            else if(!mem1_ready && !mem2_ready && (loop_num==0))
////                sel_mem_wr<=1'b0;
//            else
//                sel_mem_wr<=sel_mem_wr;
//        end
//    end
    
    always@(posedge clk)
    begin
        if(rst)
        begin
            read_r_mem1<=0;
            read_r_mem2<=0;
        end
        else
        begin
            if(out_tready)
            begin
                read_r_mem1<=read_count_mem1;
                read_r_mem2<=read_count_mem2;
            end
        end
    end
    
    always@(posedge clk)
    begin
        if(rst)
        begin
            mem1_ready<=0;
        end
        else
        begin
            if(!mem1_ready && (i_1==0) && (j_1==0))
                mem1_ready<=1'b1;
            else if(mem1_ready &&(read_count_mem1==count-1 && out_tready))
                mem1_ready<=1'b0;
            else
                mem1_ready<=mem1_ready;
        end
    end
    
    always@(posedge clk)
    begin
        if(rst)
        begin
            mem2_ready<=0;
        end
        else
        begin
            if(!mem2_ready && (i_2==0) && (j_2==0))
                mem2_ready<=1'b1;
            else if(mem2_ready &&(read_count_mem2==count-1 && out_tready))
                mem2_ready<=1'b0;
            else
                mem2_ready<=mem2_ready;
        end
    end
    
   integer k1;
   integer l1;
   integer k2;
   integer l2;
   
   
   reg r_out_tvalid1;
   reg r_out_tvalid2;
   reg [DATA_WIDTH-1:0] r_out_tdata1;
   reg [DATA_WIDTH-1:0] r_out_tdata2;
   
   always@(posedge clk)
   begin
    if(rst)
        sel_mem_rd<=0;
    else
    begin
        if(read_count_mem1==0 && read_count_mem2==0 && !mem1_ready && !mem2_ready)
            sel_mem_rd<=sel_mem_wr;        
        else
        begin
            if(((read_count_mem1==count-1) || (read_count_mem2==count-1)) && out_tready)
                sel_mem_rd<=!sel_mem_rd;
            else
                sel_mem_rd<=sel_mem_rd;
        end
//        if(mem1_ready && (read_count_mem1==0) && mem2_ready && (read_count_mem2==0))
//            sel_mem_rd<=sel_mem_rd;
//        else if(mem1_ready && (read_count_mem2==0))
//            sel_mem_rd<=0;
//        else if(mem2_ready && (read_count_mem1==0))
//            sel_mem_rd<=1'b1;
    end
   end
   
   reg r_tlast1;
   
   always@(posedge clk)                                                                                         // output from mem1 
   begin
        if(rst)
        begin
            r_out_tdata1<=0;
            r_out_tvalid1<=0;
            k1<=0;
            l1<=0;
            read_count_mem1<=0;
        end
        else
        begin
            if(!sel_mem_rd && mem1_ready)
            begin
                if((k1<(SIZE)) && out_tready)
                begin
                    r_out_tvalid1<=1'b1;
                    if((l1<SIZE-1))
                    begin
                        r_out_tdata1<=mem1[k1][l1];
                        r_tlast1<=0;
                        l1<=l1+1;
                        read_count_mem1<=read_count_mem1+1'b1;
                    end
                    else if((k1==(SIZE-1)) && (l1==(SIZE-1)))
                    begin
                        r_out_tdata1<=mem1[k1][l1];
                        k1<=0;
                        l1<=0;
                        read_count_mem1<=1'b0;
                        r_tlast1<=1'b1;
                    end
                    else
                    begin
                        r_out_tdata1<=mem1[k1][l1];
                        k1<=k1+1;
                        l1<=0;
                        read_count_mem1<=read_count_mem1+1'b1;
                        r_tlast1<=0;
                    end
                end
                else if(out_tvalid && !out_tready)
                begin
                    k1<=k1;
                    l1<=l1;
                    r_tlast1<=0;
                    r_out_tvalid1<=1'b1;
                    r_out_tdata1<=r_out_tdata1;
//                    if(read_count_mem1==count-1)
//                        read_count_mem1<=0;
//                    else
                        read_count_mem1<=read_count_mem1;
                end
                
            end
            else
            begin
                r_out_tvalid1<=1'b0;
                r_tlast1<=0;
            end
        end
   end

    reg r_tlast2;


    always@(posedge clk)                                                                                         // output from mem2
   begin
        if(rst)
        begin
            r_out_tdata2<=0;
            r_out_tvalid2<=0;
            k2<=0;
            l2<=0;
            read_count_mem2<=0;
        end
        else
        begin
            if(sel_mem_rd && mem2_ready)
            begin
               // $display("--------------------------------------%t-----------------------", $time);
                if((k2<(SIZE)) && out_tready)
                begin
                    r_out_tvalid2<=1'b1;
                    if((l2<SIZE-1))
                    begin
                        r_out_tdata2<=mem2[k2][l2];
                        l2<=l2+1;
                        read_count_mem2<=read_count_mem2+1'b1;
                        r_tlast2<=1'b0;
                    end
                    else if((k2==(SIZE-1)) && (l2==(SIZE-1)))
                    begin
                        r_out_tdata2<=mem2[k2][l2];
                        k2<=0;
                        l2<=0;
                        read_count_mem2<=0;
                        r_tlast2<=1'b1;
                    end
                    else
                    begin
                        r_out_tdata2<=mem2[k2][l2];
                        k2<=k2+1;
                        l2<=0;
                        read_count_mem2<=read_count_mem2+1'b1;
                        r_tlast2<=1'b0;
                    end
                end
                else if(out_tvalid && !out_tready)
                begin
                    //$display("----------------------------------------%t---------------------", $time);
                    k2<=k2;
                    l2<=l2;
                    r_tlast2<=1'b0;
                    r_out_tvalid2<=1'b1;
                    r_out_tdata1<=r_out_tdata1;
//                    if(read_count_mem2==count-1)
//                        read_count_mem2<=0;
//                    else
                        read_count_mem2<=read_count_mem2;
                end
                
            end
            else
            begin
                r_out_tvalid2<=1'b0;
                r_tlast2<=1'b0;
            end
        end
   end

   
assign in_tready=((!mem1_ready || !mem2_ready) );
assign out_tdata=out_tready?r_out_tdata:out_tdata;
assign out_tlast=( r_tlast1 || r_tlast2);
assign out_tvalid=((reg_ready1 && r_out_tvalid1 ) || (reg_ready2 && r_out_tvalid2));
assign r_out_tdata = r_out_tvalid1?r_out_tdata1:r_out_tdata2;
   
endmodule


