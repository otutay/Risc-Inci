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
	
	
	tRegControl destiReg;//TODO not implemented

	
	logic [cPCBitW-1:0] inst;
	logic [cXLEN-1:0] curPc;
	logic [cXLEN-1:0] rs1Data;
	logic [cXLEN-1:0] rs2Data;
	logic [cXLEN-1:0] rdData;//TODO not implemented
	
	tDecodedInst decodedInst;
	tDecoded decoded;
	tDecodedMem memOp;
	tDecodedReg regOp;
	tDecodedBranch branchOp;
	
	regFile Registers(
			.iClk(iClk),
			.iRst(iRst),
			.rs1Cntrl(decodedInst.rs1),
			.rs2Cntrl(decodedInst.rs2),
			.rdCntrl(destiReg),
			.rs1Data(rs1Data),
			.rs2Data(rs2Data),
			.rdData(rdData)
		);
		
	InstDecoder #(
		.cycleNum(1)
	) InstDecoder_instance (
		.iClk(iClk),
		.iRst(iRst),
		.iInst(inst),
		.iCurPc(curPc),
		.oDecoded(decodedInst),
		.oMemOp(memOp),
		.oRegOp(regOp),
		.oBranchOp(branchOp)
	);	
	ALU arith(
		.iClk(iClk),
		.iRst(iRst),
		.iDecoded(decoded)
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
		
		

endmodule


