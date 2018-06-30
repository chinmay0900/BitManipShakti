#include<stdio.h>

unsigned int checker_32(unsigned char opcode, unsigned char funct3, unsigned int imm, unsigned int rs1, unsigned int rs2)
{

  unsigned char shamt;
  unsigned int x = rs1;
  unsigned int  y = imm & 0xc00;
  unsigned int t = 0x1;

  if(opcode == 0 && (((funct3 == 3|| funct3 == 4) && (y == 0x800 || y == 0xc00)) || funct3 == 5))
		shamt = imm & (31);
  else if(opcode == 1 && funct3 == 3 && y == 0x800)
    shamt = 0x3f; //cbrev
  else	
		shamt = rs2 & (31);

  if(opcode == 1 && funct3 == 3 && y == 0x400) //cnot
    return(~rs1);
  
  if(opcode == 1 && funct3 == 3 && y == 0x000) //cneg
    return((~rs1) + 1);

  if(opcode == 0 && funct3 == 0) //clz
    {for (int count = 0; count < 32; count++)
			{if ((rs1 << count) >> (31))
				{return count;}}
		return 64;
		}

	if(opcode == 0 && funct3 == 1) //ctz
		{for (int count = 0; count < 32; count++)
			{if ((rs1 >> count) & 1)
				{return count;}}
		return 64;
		}

  unsigned int rd = 0; 

  if(opcode == 0 && funct3 == 2)//pcnt
    {
      int count = 0;
      for (int index = 0; index < 32; index++)
         count += (rs1 >> index) & 1;
      rd = count;
    }

  if(opcode == 4 && funct3 == 0)//andc
    rd = rs1 & ~rs2;

  if((opcode == 4 && funct3 == 1 && y == 0x800) || (opcode == 0 && funct3 == 4 && y == 0x800))//sro sroi
    rd = (~(~rs1 >> shamt));

  if((opcode == 4 && funct3 == 2 && y == 0x800) || (opcode == 0 && funct3 == 3 && y == 0x800))//slo sloi
    rd = (~(~rs1 << shamt));

  if((opcode == 4 && funct3 == 1 && y == 0xc00) || (opcode == 0 && funct3 == 3 && y == 0xc00))//ror rori
    rd = ((rs1 >> shamt) | (rs1 << (32 - shamt)));

  if(opcode == 4 && funct3 == 2 && y == 0xc00)//rol
    rd = ((rs1 << shamt) | (rs1 >> (32 - shamt)));

  if((opcode == 4 && funct3 == 3)||(opcode == 0 && funct3 == 5)||(opcode == 1 && funct3 == 3 && y == 0x800))//grev grevi
    {

      if(shamt & 1)
        x = ((x & 0x55555555)<<1)|((x & 0xAAAAAAAA)>>1);
      if(shamt & 2) 
        x = ((x & 0x33333333)<<2)|((x & 0xCCCCCCCC)>>2);
      if(shamt & 4) 
        x = ((x & 0x0F0F0F0F)<<4)|((x & 0xF0F0F0F0)>>4);
      if(shamt & 8) 
        x = ((x & 0x00FF00FF)<<8)|((x & 0xFF00FF00)>>8);
      if(shamt & 16) 
        x = ((x & 0x0000FFFF)<<16)|((x & 0xFFFF0000)>>16);
      rd = x;
    }

  if(opcode == 0 && funct3 == 6)// gzip 
    {
      if(shamt & 1)
        {
          if(shamt & 2)
            x = (x & 0x99999999) | (((x << 1) & 0x44444444) | ((x >> 1) & 0x22222222));
          if(shamt & 4)
            x = (x & 0xc3c3c3c3) | (((x << 2) & 0x30303030) | ((x >> 2) & 0x0c0c0c0c));
          if(shamt & 8)
            x = (x & 0xf00ff00f) | (((x << 4) & 0x0f000f00) | ((x >> 4) & 0x00f000f0));
          if(shamt & 16)
            x = (x & 0xff0000ff) | (((x << 8) & 0x00ff0000) | ((x >> 8) & 0x0000ff00));
         }

      else
        {  
          if(shamt & 16)
            x = (x & 0xff0000ff) | (((x << 8) & 0x00ff0000) | ((x >> 8) & 0x0000ff00));
          if(shamt & 8)
            x = (x & 0xf00ff00f) | (((x << 4) & 0x0f000f00) | ((x >> 4) & 0x00f000f0));
          if(shamt & 4)
            x = (x & 0xc3c3c3c3) | (((x << 2) & 0x30303030) | ((x >> 2) & 0x0c0c0c0c));
          if(shamt & 2)
            x = (x & 0x99999999) | (((x << 1) & 0x44444444) | ((x >> 1) & 0x22222222));      
        }

      rd = x;
    }

  if(opcode == 4 && funct3 == 4)//bit extract
    {
     unsigned int r = 0;
     for (int i = 0, j = 0; i < 32; i++)
       if ((rs2 >> i) & 1) 
         {
          if ((rs1 >> i) & 1)
            { r = r | (t << j); }
            j++;
         }
     rd = r;
    }

  else if(opcode == 4 && funct3 == 5)//bit deposit
    {
      unsigned int r = 0;
      for (int i = 0, j = 0; i < 32; i++)
        if ((rs2 >> i) & 1) 
          {
           if ((rs1 >> j) & 1)
           { r = r | (t << i); }
           j++;
          }
      rd = r;
    }
  
	return rd;

}
