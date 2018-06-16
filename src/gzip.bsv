package gzip;

  interface Ifc_gzip#(type size_t);
    method Action ma_start(Bit #(size_t) rs1,Bit #(size_t) rs2);
    method Bit #(size_t) mn_done;	    
  endinterface	  

  module mkgzip(Ifc_gzip#(size_t)); 
    
    Reg #(Bit #(size_t)) rg_rd <- mkReg(0);
    Reg #(Bit #(size_t)) rg_work <- mkReg(0);

    Integer n = valueOf (size_t);	    

    method Action ma_start(Bit #(size_t) rs1,Bit #(size_t) rs2) if(rg_work == 0);
      Bit#(size_t) a = 0, b = 0, c = 0, d = 0, e = 0;
      rg_work <= 1;
      if(rs2[0] == 1 && n == 64) begin
        if(rs2[1] == 1) a = (rs1 & 'h9999999999999999) | (((rs1 << 1) & 'h4444444444444444) | ((rs1 >> 1) & 'h2222222222222222));
        else a = rs1;
        if(rs2[2] == 1) b = (a & 'hc3c3c3c3c3c3c3c3) | (((a << 2) & 'h3030303030303030) | ((a >> 2) & 'h0c0c0c0c0c0c0c0c));
        else b = a;
        if(rs2[3] == 1) c = (b & 'hf00ff00ff00ff00f) | (((b << 4) & 'h0f000f000f000f00) | ((b >> 4) & 'h00f000f000f000f0));
        else c = b;
        if(rs2[4] == 1) d = (c & 'hff0000ffff0000ff) | (((c << 8) & 'h00ff000000ff0000) | ((c >> 8) & 'h0000ff000000ff00));
        else d = c;
        if(rs2[5] == 1) e = (d & 'hffff00000000ffff) | (((d << 16) & 'h0000ffff00000000) | ((d >> 16) & 'h00000000ffff0000));
        else e = d;
        rg_rd <= e;
      end  
      else if(rs2[0] == 0 && n == 64) begin
        if(rs2[5] == 1) a = (rs1 & 'hffff00000000ffff) | (((rs1 << 16) & 'h0000ffff00000000) | ((rs1 >> 16) & 'h00000000ffff0000));
        else a = rs1;
        if(rs2[4] == 1) b = (a & 'hff0000ffff0000ff) | (((a << 8) & 'h00ff000000ff0000) | ((a >> 8) & 'h0000ff000000ff00));
        else b = a;
        if(rs2[3] == 1) c = (b & 'hf00ff00ff00ff00f) | (((b << 4) & 'h0f000f000f000f00) | ((b >> 4) & 'h00f000f000f000f0));
        else c = b;
        if(rs2[2] == 1) d = (c & 'hc3c3c3c3c3c3c3c3) | (((c << 2) & 'h3030303030303030) | ((c >> 2) & 'h0c0c0c0c0c0c0c0c));
        else d = c;
        if(rs2[1] == 1) e = (d & 'h9999999999999999) | (((d << 1) & 'h4444444444444444) | ((d >> 1) & 'h2222222222222222));
        else e = d;
        rg_rd <= e;
      end
      else if(rs2[0] == 1 && n == 32) begin
        if(rs2[1] == 1) a = (rs1 & 'h99999999) | (((rs1 << 1) & 'h44444444) | ((rs1 >> 1) & 'h22222222));
        else a = rs1;
        if(rs2[2] == 1) b = (a & 'hc3c3c3c3) | (((a << 2) & 'h30303030) | ((a >> 2) & 'h0c0c0c0c));
        else b = a;
        if(rs2[3] == 1) c = (b & 'hf00ff00f) | (((b << 4) & 'h0f000f00) | ((b >> 4) & 'h00f000f0));
        else c = b;
        if(rs2[4] == 1) d = (c & 'hff0000ff) | (((c << 8) & 'h00ff0000) | ((c >> 8) & 'h0000ff00));
        else d = c;
        rg_rd <= d;
      end  
      else if(rs2[0] == 0 && n == 64) begin
        if(rs2[4] == 1) a = (rs1 & 'hff0000ff) | (((rs1 << 8) & 'h00ff0000) | ((rs1 >> 8) & 'h0000ff00));
        else a = rs1;
        if(rs2[3] == 1) b = (a & 'hf00ff00f) | (((a << 4) & 'h0f000f00) | ((a >> 4) & 'h00f000f0));
        else b = a;
        if(rs2[2] == 1) c = (b & 'hc3c3c3c3) | (((b << 2) & 'h30303030) | ((b >> 2) & 'h0c0c0c0c));
        else c = b;
        if(rs2[1] == 1) d = (c & 'h99999999) | (((c << 1) & 'h44444444) | ((c >> 1) & 'h22222222));
        else d = c;
        rg_rd <= d;
      end
      rg_work <= 1;
    endmethod

    method Bit #(size_t) mn_done if(rg_work == 1);
      return rg_rd;
    endmethod

  endmodule

endpackage  
