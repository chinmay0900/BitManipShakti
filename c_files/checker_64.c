#include<stdio.h>

unsigned long long checker_64(unsigned char opcode, unsigned char funct3, unsigned int imm, unsigned long long rs1, unsigned long long rs2)
{

  unsigned char shamt;
  unsigned long long x = rs1;
  unsigned int  y = imm & 0xc00;
  unsigned int s1 = (rs1) & 0xffffffff;
  unsigned int s2 = (rs2) & 0xffffffff;

  if((opcode == 0x13 && (((funct3 == 3|| funct3 == 4) && (y == 0x800 || y == 0xc00)) || funct3 == 5)) || ((opcode == 0x1b && (funct3 == 3 || funct3 == 4 || funct3 == 5))))
		shamt = imm & (63);
  else if(opcode == 1 && funct3 == 3 && y == 0x800)
    shamt = 0x3f; //cbrev
  else	
		shamt = rs2 & (63);

  if(opcode == 1 && funct3 == 3 && y == 0x400) //cnot
    return(~rs1);
  
  if(opcode == 1 && funct3 == 3 && y == 0x000) //cneg
    return((~rs1) + 1);

  if(opcode == 0x13 && funct3 == 0) //clz
    {for (int count = 0; count < 64; count++)
			{if ((rs1 << count) >> (63))
				{return count;}}
		return 64;
		}

  if(opcode == 0x1b && funct3 == 0) //clzw
    {for (int count = 0; count < 32; count++)
			{if ((s1 << count) >> (31))
				{return count;}}
		return 32;
		}

  if(opcode == 0x13 && funct3 == 1) //ctz
		{for (int count = 0; count < 64; count++)
			{if ((rs1 >> count) & 1)
				{return count;}}
		return 64;
		}
  if(opcode == 0x1b && funct3 == 1) //ctzw
		{for (int count = 0; count < 32; count++)
			{if ((s1 >> count) & 1)
				{return count;}}
		return 32;
		}

  unsigned long long rd = 0; 

  if(opcode == 0x13 && funct3 == 2)//pcnt
    {
      int count = 0;
      for (int index = 0; index < 64; index++)
         count += (rs1 >> index) & 1;
      rd = count;
    }
  
  if(opcode == 0x1b && funct3 == 2)//pcntw
    {
      int count = 0;
      for (int index = 0; index < 32; index++)
         count += (s1 >> index) & 1;
      rd = count;
    }

  if(opcode == 0x33 && funct3 == 0)//andc
    rd = rs1 & ~rs2;

  if((opcode == 0x33 && funct3 == 1 && y == 0x800) || (opcode == 0x13 && funct3 == 4 && y == 0x800))//sro sroi
    rd = (~(~rs1 >> shamt));

  if((opcode == 0x3b && funct3 == 0) || (opcode == 0x1b && funct3 == 4))//srow sroiw
    rd = (~(~s1 >> shamt));

  if((opcode == 0x33 && funct3 == 2 && y == 0x800) || (opcode == 0x13 && funct3 == 3 && y == 0x800))//slo sloi
    rd = (~(~rs1 << shamt));

  if((opcode == 0x3b && funct3 == 1) || (opcode == 0x1b && funct3 == 3))//slow sloiw
    rd = (~(~s1 << shamt));

  if((opcode == 0x33 && funct3 == 1 && y == 0xc00) || (opcode == 0x13 && funct3 == 3 && y == 0xc00))//ror rori
    rd = ((rs1 >> shamt) | (rs1 << (64 - shamt)));

  if((opcode == 0x3b && funct3 == 2) || (opcode == 0x1b && funct3 == 5))//rorw roriw
    rd = ((s1 >> shamt) | (s1 << (32 - shamt)));

  if(opcode == 0x33 && funct3 == 2 && y == 0xc00)//rol
    rd = ((rs1 << shamt) | (rs1 >> (64 - shamt)));

  if(opcode == 0x3b && funct3 == 3)//rolw
    rd = ((s1 << shamt) | (s1 >> (32 - shamt)));

  if((opcode == 0x33 && funct3 == 3)||(opcode == 0x13 && funct3 == 5)||(opcode == 1 && funct3 == 3 && y == 0x800))//grev grevi cbrev
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

      rd = x;
    }

  if(opcode == 0x13 && funct3 == 6)// gzip 
    {
      if(shamt & 1)
        {
          if(shamt & 2)
            x = (x & 0x9999999999999999) | (((x << 1) & 0x4444444444444444) | ((x >> 1) & 0x2222222222222222));
          if(shamt & 4)
            x = (x & 0xc3c3c3c3c3c3c3c3) | (((x << 2) & 0x3030303030303030) | ((x >> 2) & 0x0c0c0c0c0c0c0c0c));
          if(shamt & 8)
            x = (x & 0xf00ff00ff00ff00f) | (((x << 4) & 0x0f000f000f000f00) | ((x >> 4) & 0x00f000f000f000f0));
          if(shamt & 16)
            x = (x & 0xff0000ffff0000ff) | (((x << 8) & 0x00ff000000ff0000) | ((x >> 8) & 0x0000ff000000ff00));
          if(shamt & 32)
            x = (x & 0xffff00000000ffff) | (((x << 16) & 0x0000ffff00000000) | ((x >> 16) & 0x00000000ffff0000));
        }

      else
        {  
          if(shamt & 32)
            x = (x & 0xffff00000000ffff) | (((x << 16) & 0x0000ffff00000000) | ((x >> 16) & 0x00000000ffff0000));
          if(shamt & 16)
            x = (x & 0xff0000ffff0000ff) | (((x << 8) & 0x00ff000000ff0000) | ((x >> 8) & 0x0000ff000000ff00));
          if(shamt & 8)
            x = (x & 0xf00ff00ff00ff00f) | (((x << 4) & 0x0f000f000f000f00) | ((x >> 4) & 0x00f000f000f000f0));
          if(shamt & 4)
            x = (x & 0xc3c3c3c3c3c3c3c3) | (((x << 2) & 0x3030303030303030) | ((x >> 2) & 0x0c0c0c0c0c0c0c0c));
          if(shamt & 2)
            x = (x & 0x9999999999999999) | (((x << 1) & 0x4444444444444444) | ((x >> 1) & 0x2222222222222222));      
        }

      rd = x;
    }

  if(opcode == 0x33 && funct3 == 4)//bit extract
    {
     unsigned long long r = 0;
     unsigned long long t = 0x1;
     for (int i = 0, j = 0; i < 64; i++)
       if ((rs2 >> i) & 1) 
         {
          if ((rs1 >> i) & 1)
            { r = r | (t << j); }
            j++;
         }
     rd = r;
    }

  else if(opcode == 0x3b && funct3 == 4)//bit extract w
    {
     unsigned int r = 0;
     unsigned int t = 0x1;
     for (int i = 0, j = 0; i < 32; i++)
       if ((s2 >> i) & 1) 
         {
          if ((s1 >> i) & 1)
            { r = r | (t << j); }
            j++;
         }
     rd = r;
    }

  else if(opcode == 0x33 && funct3 == 5)//bit deposit
    {
      unsigned long long r = 0;
      unsigned long long t = 0x1;
      for (int i = 0, j = 0; i < 64; i++)
        if ((rs2 >> i) & 1) 
          {
           if ((rs1 >> j) & 1)
           { r = r | (t << i); }
           j++;
          }
      rd = r;
    }
  else if(opcode == 0x3b && funct3 == 5)//bit deposit w
    {
      unsigned int r = 0;
      unsigned int t = 0x1;
      for (int i = 0, j = 0; i < 32; i++)
        if ((s2 >> i) & 1) 
          {
           if ((s1 >> j) & 1)
           { r = r | (t << i); }
           j++;
          }
      rd = r;
    }
  
	return rd;

}
