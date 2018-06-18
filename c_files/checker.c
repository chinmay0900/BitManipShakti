#include<stdio.h>

unsigned long long gzipstage(unsigned long long src, unsigned long long maskL, unsigned long long maskR, unsigned int N)
{
  unsigned long long x = src & ~(maskL | maskR);
  x |= ((src << N) & maskL) | ((src >> N) & maskR);
 return x;
}

unsigned long long checker(unsigned char opcode, unsigned char funct3, unsigned int imm, unsigned long long rs1, unsigned long long rs2)
{

  unsigned char shamt = rs2 & (63);
  unsigned long long x = rs1;
  
  if(opcode == 0 && funct3 == 2)//pcnt
    {
      int count = 0;
      for (int index = 0; index < 64; index++)
         count += (rs1 >> index) & 1;
      return count;
    }

  if(opcode == 1 && funct3 == 0)//andc
    return rs1 & ~rs2;

  if((opcode == 1 && funct3 == 1 && imm[11:10] == 2) || (opcode == 0 && funct3 == 4 && imm[11:10] == 2))//sro sroi
    return ~(~rs1 >> shamt);

  if((opcode == 1 && funct3 == 2 && imm[11:10] == 2) || (opcode == 0 && funct3 == 3 && imm[11:10] == 2))//slo sloi
    return ~(~rs1 >> shamt);

  if((opcode == 1 && funct3 == 1 && imm[11:10] == 3) || (opcode == 0 && funct3 == 3 && imm[11:10] == 3))//ror rori
    return (rs1 >> shamt) | (rs1 << (63 - shamt));

  if(opcode == 1 && funct3 == 2 && imm[11:10] == 3)//rol
    return (rs1 << shamt) | (rs1 >> (63 - shamt));

  if((opcode == 1 && funct3 == 3)||(opcode == 0 && (funct3 == 5 || funct3 == 0)))//grev grevi
    {

      if(shamt & 1)
        x = ((x & 0x5555555555555555)<<1)|((x & 0xAAAAAAAAAAAAAAAA)>>1);
      if(shamt & 2) 
        x = ((x & 0x3333333333333333)<<2)|((x & 0xCCCCCCCCCCCCCCCC)>>2);
      if(shamt & 4) 
        x = ((x & 0x0F0F0F0F0F0F0F0F)<<4)|((x & 0xF0F0F0F0F0F0F0F0)>>4);
      if(shamt & 8) 
        x = ((x & 0x00FF00FF00FF00FF)<<8)|((x & 0xFF00FF00FF00FF00)>>8);
      if(shamt & 16) 
        x = ((x & 0x0000FFFF0000FFFF)<<16)|((x & 0xFFFF0000FFFF0000)>>16);
      if(shamt & 32) 
        x = ((x & 0x00000000FFFFFFFF)<<32)|((x & 0xFFFFFFFF00000000)>>32);

      return x;
    }

  if(opcode == 0 && funct3 == 6)// gzip 
    {
      if(shamt & 1)
        {
          if(shamt & 2)
            x = gzipstage(x,0x4444444444444444,0x2222222222222222,1);
          if(shamt & 4)
            x = gzipstage(x,0x3030303030303030,0x0c0c0c0c0c0c0c0c,2);
          if(shamt & 8)
            x = gzipstage(x,0x0f000f000f000f00,0x00f000f000f000f0,4);
          if(shamt & 16)
            x = gzipsatge(x,0x00ff000000ff0000,0x0000ff000000ff00,8);
          if(shamt & 32)
            x = gzipstage(x,0x0000ffff00000000,0x00000000ffff0000,16);
        }

      else
        {  
          if(shamt & 32)
            x = gzipstage(x,0x0000ffff00000000,0x00000000ffff0000,16);
          if(shamt & 16)
            x = gzipsatge(x,0x00ff000000ff0000,0x0000ff000000ff00,8);
          if(shamt & 8)
            x = gzipstage(x,0x0f000f000f000f00,0x00f000f000f000f0,4);
          if(shamt & 4)
            x = gzipstage(x,0x3030303030303030,0x0c0c0c0c0c0c0c0c,2);
          if(shamt & 2)
            x = gzipstage(x,0x4444444444444444,0x2222222222222222,1);      
        }

      return x;
    }

  if(opcode == 1 && funct3 == 4)//bit extract
    {
     unsigned long long r = 0;
     for (int i = 0, j = 0; i < 64; i++)
       if ((rs2 >> i) & 1) 
         {
          if ((rs1 >> i) & 1)
            r |= unsigned long long(1) << j;
            j++;
         }
     return r;
    }

  else if(opcode == 1 && funct3 == 5)//bit deposit
    {
      unsigned long long r = 0;
      for (int i = 0, j = 0; i < 64; i++)
        if ((rs2 >> i) & 1) 
          {
           if ((rs1 >> j) & 1)
           r |= unsigned long long(1) << i;
           j++;
          }
      return r;
    }
  

}
