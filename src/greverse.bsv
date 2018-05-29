package greverse;

  interface Ifc_greverse;
    method Action ma_start(Bit #(64) rs1, Bit#(64) rs2);
    method Bit#(64) mn_done;
  endinterface
  
  module mkgreverse(Ifc_greverse);

    Reg#(Bit#(64)) rg_x <- mkRegU();
    Reg#(Bit#(64)) rg_y <- mkRegU();
    Reg#(Bit#(64)) rg_work <- mkReg(0);
    
    rule rl_shift_1(rg_work==1);
      if(rg_y[0]==1) rg_x<=((rg_x&64'h5555555555555555)<<1)|((rg_x&64'hAAAAAAAAAAAAAAAA)>>1);
      $display("rl_shift_1 running rg_rs1=%h\n",rg_x);
      rg_work <= 2;
    endrule

    rule rl_shift_2(rg_work==2);
      if(rg_y[1]==1) rg_x<=((rg_x&64'h3333333333333333)<<2)|((rg_x&64'hCCCCCCCCCCCCCCCC)>>2);
      $display("rl_shift_2 running rg_rs1=%h\n",rg_x);
      rg_work <= 3;
    endrule

    rule rl_shift_3(rg_work==3);
      if(rg_y[2]==1) rg_x<=((rg_x&64'h0F0F0F0F0F0F0F0F)<<4)|((rg_x&64'hF0F0F0F0F0F0F0F0)>>4);
      $display("rl_shift_3 running rg_rs1=%h\n",rg_x);
      rg_work <= 4;
    endrule

    rule rl_shift_4(rg_work==4);
      if(rg_y[3]==1) rg_x<=((rg_x&64'h00FF00FF00FF00FF)<<8)|((rg_x&64'hFF00FF00FF00FF00)>>8);
      $display("rl_shift_4 running rg_rs1=%h\n",rg_x);
      rg_work <= 5;
    endrule

    rule rl_shift_5(rg_work==5);
      if(rg_y[4]==1) rg_x<=((rg_x&64'h0000FFFF0000FFFF)<<16)|((rg_x&64'hFFFF0000FFFF0000)>>16);
      $display("rl_shift_5 running rg_rs1=%h\n",rg_x);
      rg_work <= 6;
    endrule

    rule rl_shift_6(rg_work==6);
      if(rg_y[5]==1) rg_x<=((rg_x&64'h00000000FFFFFFFF)<<32)|((rg_x&64'hFFFFFFFF00000000)>>32);
      $display("rl_shift_6 running rg_rs1=%h\n",rg_x);
      rg_work <= 7;
    endrule

    method Action ma_start(Bit#(64) rs1, Bit#(64) rs2) if(rg_work == 0); 
      rg_work <= 1;
      rg_x <= rs1;
      rg_y <= rs2;
    endmethod

    method Bit#(64) mn_done if(rg_work==7);
      return rg_x;
    endmethod

  endmodule

endpackage
