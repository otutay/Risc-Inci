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


   constraint funct3Const {funct3 == 3'b0 -> opcode == eOpJalr;
			   funct3 inside {3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111 }  -> opcode == eOpBranch;
			   funct3 inside {3'b000, 3'b001, 3'b010, 3'b100, 3'b101}-> opcode == eOpLoad;
			   funct3 inside {3'b000, 3'b001, 3'b010}-> opcode == eOpStore;
			   funct3 inside {3'b000, 3'b010, 3'b011,3'b100,3'b110,3'b111,3'b001, 3'b101 }-> opcode == eOpImmedi;
			   funct3 inside {3'b000, 3'b001, 3'b010,3'b011,3'b100,3'b101,3'b110, 3'b111 }-> opcode == eOpRtype;
			   funct3 inside {3'b000, 3'b001 }-> opcode == eOpFence
			   };

   constraint funct7Const {funct7 inside {7'h00 , 7'h20} -> (opcode == eOpImmedi | opcode == eOpRtype);
   };

   function logic [cXlen-1:0] formInst();
      if (opcode == eOpLui | opcode == eOpAuIpc)  begin
	 instruction[6:0] = opcode;
	 instruction[11:7] = destAddr;
	 instruction[31:12] = imm[31:12];
      end else if (opcode == eOpJalr) begin

      end else if (opcode == eOp) begin

      end else if (other_condition) begin

      end else begin

      end


   endfunction
endclass
