package gzip;

  interface Ifc_gzip#(type size_t);
    method Action ma_start(Bit #(size_t) rs1,Bit #(size_t) rs2);
    method Bit #(size_t) mn_done;	    
  endinterface	  

  module mkgzip(Ifc_gzip#(size_t)); 
    
    Reg #(Bit #(size_t)) rg_x <- mkReg(0);
    Reg #(Bit #(size_t)) rg_y <- mkReg(0);
    Reg #(Bit #(size_t)) rg_pc <- mkReg(0);


    Integer n = valueOf (size_t);	    
   
    rule rl_1(rg_pc == 1);
      if(rg_y[1] == 1) begin 
         if(n == 64) 
           rg_x <= (rg_x & 'h9999999999999999) | (((rg_x << 1) & 'h4444444444444444) | ((rg_x >> 1) & 'h2222222222222222));
         else
           rg_x <= (rg_x & 'h99999999) | (((rg_x << 1) & 'h44444444) | ((rg_x >> 1) & 'h22222222));
      end
      rg_pc <= 3;      
    endrule
   
    rule rl_2(rg_pc == 3);
      if(rg_y[2] == 1) begin
        if(n == 64)
          rg_x <= (rg_x & 'hc3c3c3c3c3c3c3c3) | (((rg_x << 2) & 'h3030303030303030) | ((rg_x >> 2) & 'h0c0c0c0c0c0c0c0c));
        else
          rg_x <= (rg_x & 'hc3c3c3c3) | (((rg_x << 2) & 'h30303030) | ((rg_x >> 2) & 'h0c0c0c0c));
      end 
      rg_pc <= 5;
    endrule

    rule rl_3(rg_pc == 5);
      if(rg_y[3] == 1) begin 
        if(n == 64)
          rg_x <= (rg_x & 'hf00ff00ff00ff00f) | (((rg_x << 4) & 'h0f000f000f000f00) | ((rg_x >> 4) & 'h00f000f000f000f0));
        else
          rg_x <= (rg_x & 'hf00ff00f) | (((rg_x << 4) & 'h0f000f00) | ((rg_x >> 4) & 'h00f000f0));
      end
      rg_pc <= 7;
    endrule
       

    rule rl_4(rg_pc == 7);
      if(rg_y[4] == 1) begin
        if(n == 64)
          rg_x <= (rg_x & 'hff0000ffff0000ff) | (((rg_x << 8) & 'h00ff000000ff0000) | ((rg_x >> 8) & 'h0000ff000000ff00));
        else
          rg_x <= (rg_x & 'hff0000ff) | (((rg_x << 8) & 'h00ff0000) | ((rg_x >> 8) & 'h0000ff00));
      end
      rg_pc <= 9; 
    endrule

    
    rule rl_5(rg_pc == 9);
      if(rg_y[5] == 1 && n == 64)
        rg_x <= (rg_x & 'hffff00000000ffff) | (((rg_x << 16) & 'h0000ffff00000000) | ((rg_x >> 16) & 'h00000000ffff0000));
        rg_pc <= 11;
    endrule

     rule rl_6(rg_pc == 2);
      if(rg_y[5] == 1 && n == 64)
        rg_x <= (rg_x & 'hffff00000000ffff) | (((rg_x << 16) & 'h0000ffff00000000) | ((rg_x >> 16) & 'h00000000ffff0000));
        rg_pc <= 4;
    endrule


    rule rl_7(rg_pc == 4);
      if(rg_y[4] == 1) begin
        if(n == 64)
          rg_x <= (rg_x & 'hff0000ffff0000ff) | (((rg_x << 8) & 'h00ff000000ff0000) | ((rg_x >> 8) & 'h0000ff000000ff00));
        else
          rg_x <= (rg_x & 'hff0000ff) | (((rg_x << 8) & 'h00ff0000) | ((rg_x >> 8) & 'h0000ff00));
      end
      rg_pc <= 6;  
    endrule

    rule rl_8(rg_pc == 6);
      if(rg_y[3] == 1) begin
        if(n == 64)
          rg_x <= (rg_x & 'hf00ff00ff00ff00f) | (((rg_x << 4) & 'h0f000f000f000f00) | ((rg_x >> 4) & 'h00f000f000f000f0));
        else
          rg_x <= (rg_x & 'hf00ff00f) | (((rg_x << 4) & 'h0f000f00) | ((rg_x >> 4) & 'h00f000f0));
      end
      rg_pc <= 8;  
    endrule

    rule rl_9(rg_pc == 8);
      if(rg_y[2] == 1) begin
        if(n == 64) 
          rg_x <= (rg_x & 'hc3c3c3c3c3c3c3c3) | (((rg_x << 2) & 'h3030303030303030) | ((rg_x >> 2) & 'h0c0c0c0c0c0c0c0c));
        else
          rg_x <= (rg_x & 'hc3c3c3c3) | (((rg_x << 2) & 'h30303030) | ((rg_x >> 2) & 'h0c0c0c0c));
      end
      rg_pc <= 10;
    endrule

    rule rl_10(rg_pc == 10);
      if(rg_y[1] == 1) begin
        if(n == 64)
          rg_x <= (rg_x & 'h9999999999999999) | (((rg_x << 1) & 'h4444444444444444) | ((rg_x >> 1) & 'h2222222222222222));
        else
          rg_x <= (rg_x & 'h99999999) | (((rg_x << 1) & 'h44444444) | ((rg_x >> 1) & 'h22222222));
      end
      rg_pc <= 11;
    endrule
    
    
    method Action ma_start(Bit #(size_t) rs1,Bit #(size_t) rs2) if(rg_pc == 0);
      rg_x <= rs1;
      rg_y <= truncate(rs2);
      if(rs2[0] == 1)
        rg_pc <= 1;
      else
        rg_pc <= 2;
    endmethod

    method Bit #(size_t) mn_done if(rg_pc == 11);
      return rg_x;
    endmethod	    
  endmodule

endpackage  
