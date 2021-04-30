//-------------------------------------------------------------------------------
// Title      : InstDecoderIntf.sv
// Project    :
// -----------------------------------------------------------------------------
// File       : InstDecoderIntf.sv
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 26.04.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description: decoder insterface code for testing purposes.
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 26.04.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------

import corePckg::*;
`include "InstRandomizer.sv"
class instDecoderIntf;

   logic [cXLEN-1:0] iInst;
   rand logic [cXLEN-1:0] iCurPc;
   logic	     iFlushPipe;

   rand InstRandomizer randInst;


   function new();
      this.randInst = new();
   endfunction


   task directedInst(logic [8:0] shftReg);
      case (shftReg)
	9'b000000001 : // lbu
	  begin
	     iInst[6:0] = eOpLoad;
	     iInst[11:7] = 5'b00001;
	     iInst[14:12] = 3'b100;
	     iInst[19:15] = 5'b00011;
	     iInst[31:20] = 12'hbab;
	  end
	9'b000000010 : // sw
	  begin
	     iInst[6:0] = eOpStore;
	     iInst[11:7] = 5'b11111;
	     iInst[14:12] = 3'b010;
	     iInst[19:15] = 5'b00111;
	     iInst[24:20] = 5'b01111;
	     iInst[31:25] = 7'b1101011;
	  end
	9'b000000100 : // slli
	  begin
	     iInst[6:0] = eOpImmedi;
	     iInst[11:7] = 5'b11111;
	     iInst[14:12] = 3'b001;
	     iInst[19:15] = 5'b01111;
	     iInst[31:20] = 12'hbaf;
	  end
	9'b000001000 : // sltu
	  begin
	     iInst[6:0] = eOpRtype;
	     iInst[11:7] = 5'b00001;
	     iInst[14:12] = 3'b011;
	     iInst[19:15] = 5'b00001;
	     iInst[24:20] = 5'b00010;
	     iInst[31:25] = 7'b0000000;
	  end
	9'b000010000: // JALR
	  begin
	     iInst[6:0] = eOpJalr;
	     iInst[11:7] = 5'b10001;
	     iInst[14:12] = 3'b000;
	     iInst[19:15] = 5'b01001;
	     iInst[31:20] = 12'hcaf;
	  end
	9'b000100000:
	  begin
	     iInst[6:0] = eOpJal;
	     iInst[11:7] = 5'b11001;
	     iInst[14:12] = 3'b000;
	     iInst[19:15] = 5'b11101;
	     iInst[31:20] = 12'hfff;
	  end
	9'b001000000:
	  begin
	     iInst[6:0] = eOpLui;
	     iInst[11:7] = 5'b11111;
	     iInst[31:12] = 20'hbeafc;
	  end
	9'b010000000:
	  begin
	     iInst[6:0] = eOpAuIpc;
	     iInst[11:7] = 5'b11100;
	     iInst[31:12] = 20'habcde;
	  end
	9'b100000000 : // BGE
	  begin
	     iInst[6:0] = eOpBranch;
	     iInst[11:7] = 5'b11010;
	     iInst[14:12] = 3'b101;
	     iInst[19:15] = 5'b10001;
	     iInst[24:20] = 5'b10010;
	     iInst[31:25] = 7'b1010101;
	  end
	default :
	  begin
	     iInst[31:6] = 26'hdeadbea;
	  end

      endcase
      $display("opcode %s",tOpcodeEnum'(iInst[6:0]));
   endtask // directedInst

   function display();
      iInst = randInst.formInst();
      $display("randomized datas are iInst = %h, iCurPc = %h, iFlushPipe = %b, opcode = %s \n",iInst,iCurPc,iFlushPipe,tOpcodeEnum'(iInst[6:0]));

   endfunction // display


endclass
