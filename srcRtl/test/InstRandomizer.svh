//-------------------------------------------------------------------------------
// Title      : instruction randomizer
// Project    :
// -----------------------------------------------------------------------------
// File       : InstRandomizer.svh
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 05.04.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description: instruction randomize for testing
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 05.04.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------
import corePckg::*;
class InstRandomizer;
   rand tOpcodeEnum opcode;
   rand logic [cRegSelBitW-1:0] src1Addr;
   rand logic [cRegSelBitW-1:0] src2Addr;
   rand logic [cRegSelBitW-1:0] destAddr;
   rand logic [2:0]		   funct3;
   rand logic [6:0]		   funct7;
   rand logic [cXlen-1:0] imm;
   logic [cXlen-1:0] instruction;


   constraint funct3Const {
      opcode == eOpJalr -> funct3 = 3'b000;
      opcode == eOpBranch -> funct3 inside {3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111 };
      opcode == eOpLoad -> funct3 inside {3'b000, 3'b001, 3'b010, 3'b100, 3'b101};
      opcode == eOpStore -> funct3 inside {3'b000, 3'b001, 3'b010};
      opcode == eOpImmedi -> funct3 inside {3'b000, 3'b010, 3'b011,3'b100,3'b110,3'b111,3'b001, 3'b101};
      opcode == eOpRtype -> funct3 inside {3'b000, 3'b001, 3'b010,3'b011,3'b100,3'b101,3'b110, 3'b111};
      opcode == eOpFence -> funct3 inside {3'b000, 3'b001}
	      };

   constraint funct7Const {
      (opcode == eOpImmedi | opcode == eOpRtype) ->  funct7 inside {7'h00 , 7'h20}
	       };

   function logic [cXlen-1:0] formInst();
      instruction[6:0] = opcode;
      if (opcode == eOpLui | opcode == eOpAuIpc)
	begin
	   instruction[11:7] = destAddr;
	   instruction[31:12] = imm[31:12];
	end

      else if (opcode == eOpJal)
	begin
	   instruction[11:7] = destAddr;
	   instruction[31:12] = {imm[20],imm[10:1],imm[11],imm[19:12]};
	end

      else if (opcode == eOpJalr)
	begin
	   instruction[11:7] = destAddr;
	   instruction[14:12] = funct3;
	   instruction[19:15] = src1Addr;
	   instruction[31:20] = imm[11:0];
	end
      else if (opcode == eOpBranch)
	begin
	   instruction[11:7] = {imm[4:1],imm[11]};
	   instruction[14:12] = funct3;
	   instruction[19:15] = src1Addr;
	   instruction[24:20] = src2Addr;
	   instruction[31:25] = {imm[12],imm[10:5]};
	end
      else if (opcode == eOpLoad)
	begin
	   instruction[11:7] = destAddr;
	   instruction[14:12] = funct3;
	   instruction[19:15] = src1Addr;
	   instruction[31:20] = imm[11:0];
	end
      else if (opcode == eOpStore)
	begin
	   instruction[11:7] = imm[4:0];
	   instruction[14:12] = funct3;
	   instruction[19:15] = src1Addr;
	   instruction[24:20] = src2Addr;
	   instruction[31:25] = imm[11:5];
	end
      else if (opcode == eOpImmedi )
	begin
	   instruction[11:7] = destAddr;
	   instruction[14:12] = funct3;
	   instruction[19:15] = src1Addr;
	   if(funct3 == 3'b001 | funct3 == 3'b101)
	     instruction[31:20] = { funct7,imm[4:0]};
	   else
	     instruction[31:20] = imm[11:0];
	end
      else if (opcode == eOpRtype)
	begin
	   instruction[11:7] = destAddr;
	   instruction[14:12] = funct3;
	   instruction[19:15] = src1Addr;
	   instruction[24:20] = src2Addr;
	   instruction[31:25] = funct7;


	end

   endfunction
endclass
