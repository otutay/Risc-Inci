//-------------------------------------------------------------------------------
// Title      : logData class
// Project    :
// -----------------------------------------------------------------------------
// File       : logData.sv
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 02.05.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description: log simulation data class
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 02.05.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------
import corePckg::*;

class logData;
   int fid;
   int disp;


   function new (string fileName,integer disp);
      this.disp = disp;
      fid = $fopen(fileName,"w");
      $fwrite(fid,"%0t ns file -> %s opened  \n",$time,fileName);
   endfunction // new

   function addInstLog(string name,logic [cXLEN-1:0] inst);
      $fwrite(fid,"%0t ns, %s, inst -> %h \n",$time, name, inst);

      if(disp == 1) begin
	 $display("\t\t\t inst -> %h",inst);
      end

   endfunction // addInstLog

   function addDecodeRtypeLog(logic [6:0] opcode, logic[cRegSelBitW-1:0] src1,logic[cRegSelBitW-1:0] src2,
			logic [cRegSelBitW-1:0] dest,logic [2:0] f3, logic[6:0] f7);

      $fwrite(fid,"\t Type -> Rtype,opcode-> %s,  src1 -> %h, src2 -> %h, dest %h, f3-> %h, f7-> %h \n",
	      tOpcodeEnum'(opcode), src1,src2 ,dest,f3,f7);

      if(disp == 1) begin
	 $display("\t\t\t Type -> Rtype,,opcode-> %s , src1 -> %h, src2 -> %h, dest %h, f3-> %h, f7-> %h \n",
		  tOpcodeEnum'(opcode), src1,src2 ,dest,f3,f7);
      end

   endfunction // addRtypeLog

   function addDecodeItypeLog(logic [6:0] opcode, logic[cRegSelBitW-1:0] src1, logic[cRegSelBitW-1:0] dest,
			logic [2:0] f3,logic[cXLEN-1:0] imm);

      $fwrite(fid,"\t Type -> Itype,opcode-> %s, src1 -> %h, dest %h, f3-> %h, imm-> %h \n",
	      tOpcodeEnum'(opcode),src1,dest,f3,imm);

      if(disp == 1) begin
	 $display("\t\t\t Type -> Itype,opcode-> %s,src1 -> %h, dest %h, f3-> %h, imm-> %h \n",
		  tOpcodeEnum'(opcode),src1,dest,f3,imm);
      end

   endfunction // addItypeLog

   function addDecodeSBtypeLog(logic [6:0] opcode, logic[cRegSelBitW-1:0] src1,logic[cRegSelBitW-1:0] src2,
			 logic [2:0] f3, logic[cXLEN-1:0] imm);

      $fwrite(fid,"\t Type -> SBtype,opcode-> %s, src1 -> %h, src2 %h, f3-> %h, imm-> %h \n",
	      tOpcodeEnum'(opcode),src1,src2,f3,imm);

      if(disp == 1) begin
	 $display("\t\t\t Type -> SBtype,opcode-> %s,src1 -> %h, src2 %h, f3-> %h, imm-> %h \n",
		  tOpcodeEnum'(opcode),src1,src2,f3,imm);
      end

   endfunction // addStypeLog

   function addDecodeUJtypeLog(logic [6:0] opcode, logic[cRegSelBitW-1:0] dest, logic[cXLEN-1:0] imm);
      $fwrite(fid,"\t Type -> UJtype, opcode-> %s, dest -> %h, imm-> %h \n",tOpcodeEnum'(opcode), dest,imm);

      if( disp == 1) begin
	 $display("\t\t\t Type -> UJType, opcode-> %s,dest -> %h, imm-> %h \n",tOpcodeEnum'(opcode), dest,imm);
      end
   endfunction // addUtypeLog

   function addDecodeTypeError(logic [6:0] opcode);

      $fwrite(fid,"\t -------------------- ERROR------------------------------- \n");
      $fwrite(fid,"\t ERROR TYPE -> UNKNOWN UJtype, opcode-> %s, \n",tOpcodeEnum'(opcode));
      $fwrite(fid,"\t -------------------- ERROR------------------------------- \n");

      if(disp == 1) begin
	 $display("\t -------------------- ERROR------------------------------- \n");
	 $display("\t\t\t ERROR TYPE -> UNKNOWN, opcode-> %s \n",tOpcodeEnum'(opcode));
	 $display("\t -------------------- ERROR------------------------------- \n");
      end

   endfunction // addError


endclass
