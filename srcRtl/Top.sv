// ****************************************************************************
// * Top.sv
// * osmant
// *
// ****************************************************************************/

/**
 * Module: Top
 *
 * TODO: Add module documentation
 */
import corePckg::*;

module Top
  (
   input logic iClk,
   input logic iRst
   );


   //    tRegControl destiReg; //TODO not implemented
   //logic [cXLEN-1:0] rdData; //TODO not implemented

   // reg file signals
   logic [cPCBitW-1:0] inst;
   logic [cXLEN-1:0]   curPc;
   logic [cXLEN-1:0]   rs1Data;
   logic [cXLEN-1:0]   rs2Data;

   // decoded instructions
   tDecodedInst decodedInst;
   tDecoded decoded;
   tDecodedMem memOp;
   tDecodedReg regOp;
   tDecodedBranch branchOp;

   // alu out signals -> WB
   tMemOp memWB;
   tRegOp regWB;
   tBranchOp branchWB;

   // ram load op
   tRegOp regMem;

   // fetch control
   tFetchCtrl fetchCtrl;

   regFile Registers(
		     .iClk(iClk),
		     .iRst(iRst),
		     .iRs1(decodedInst.rs1),
		     .iRs2(decodedInst.rs2),
		     .iRd(regWB),
		     .iRdMem(regMem),
		     .oRs1Data(rs1Data),
		     .oRs2Data(rs2Data)
		     //.rdData(rdData)
		     );

   InstDecoder #(
		 .cycleNum(1)
		 )
   InstDecoder_instance (
			 .iClk(iClk),
			 .iRst(iRst),
			 .iInst(inst),
			 .iCurPc(curPc),
			 .iFlushPipe(branchWB.flushPipe),
			 .oDecoded(decodedInst),
			 .oMemOp(memOp),
			 .oRegOp(regOp),
			 .oBranchOp(branchOp)
			 );

   always_comb
     begin : ALU
	decoded.rs1 = rs1Data;
	decoded.rs2 = rs2Data;
	decoded.rd  = decodedInst.rd;
	decoded.funct3 = decodedInst.funct3;
	decoded.funct7 = decodedInst.funct7;
	decoded.imm = decodedInst.imm;
	decoded.opcode = decodedInst.opcode;
	decoded.curPc = decodedInst.curPc;
     end

   ALU ALU_instance (
		     .iClk(iClk),
		     .iRst(iRst),
		     .iDecoded(decoded),
		     .iDecodedMem(memOp),
		     .iDecodedReg(regOp),
		     .iDecodedBranchOp(branchOp),
		     .oMemWB(memWB),
		     .oRegWB(regWB),
		     .oBranchWB(branchWB)
		     );

   fetchWB fetchWB_instance (
			     .iClk(iClk),
			     .iRst(iRst),
			     .iMemOp(memWB),
			     .iFetchCtrl(fetchCtrl),
			     .oCurPc(curPc),
			     .oInstr(inst),
			     .oRegOp(regMem)
			     );


   always_comb
     begin
	fetchCtrl.pc <= branchWB.pc;
	fetchCtrl.newPc<=  branchWB.newPC;
     end





endmodule
