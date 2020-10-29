// ****************************************************************************
// * ALU.sv
// * osmant 
// * 2 cycle alu
// ****************************************************************************/

/**
 * Module: ALU
 * 
 * TODO: Add module documentation
 */
import corePckg::*;
module ALU
//	#(
//	parameter cycleNum = 2
//)
	(
	input logic iClk,
	input logic iRst,
	input tDecoded iDecoded,
	input tDecodedMem iDecodedMem,
	input tDecodedReg iDecodedReg,
	input tDecodedBranch iDecodedBranchOp
);
	//	tAluOut aluOut;
	// mem op registers
	tMemOp memOut;
	tMemOp memOuti1;

	// regOp Register
	logic [cXLEN-1:0] operand1;
	logic [cXLEN-1:0] operand2;
	tArithEnum operation;
	logic regOpValid;
	logic [cRegSelBitW-1:0] regAddr;
	tRegOp regOut;

	//---------------------------- load Store Operation ----------------------------------
	always_ff @(posedge iClk)
	begin : LoadStoreOperation
		if(iDecodedMem.dv & iDecodedMem.load)
			begin
				memOut.addr <= signed'(iDecoded.rs1Data) + signed'(iDecoded.imm);
				memOut.rdAddr<= iDecoded.rdAddr;
				memOut.opType <= iDecoded.funct3;
				memOut.read <= 1'b1;
			end
		else if(iDecodedMem.dv & iDecodedMem.store)
		begin
			memOut.addr <= signed'(iDecoded.rs1Data) + signed'(iDecoded.imm);
			memOut.data <= iDecoded.rs2Data;
			memOut.opType <= iDecoded.funct3;
			memOut.write <= 1'b1;
		end
	end
	//
	//	generate
	//		if(cycleNum == 1)
	//		begin
	//			assign memOuti1 = memOut;
	//		end
	//		else if(cycleNum == 2)
	//		begin
	always_ff @(posedge iClk)
	begin : LoadStoreOperation_reg
		memOuti1 <= memOut;
	end

	//		end
	//	endgenerate

	//---------------------------- Register Operation ----------------------------------
	always_ff @(posedge iClk)
	begin: RegOpOperandSelection
		if(iDecodedReg.dv)
		begin
			if(iDecodedReg.opRs1)
				operand1 <= iDecoded.rs1Data;
			else if(iDecodedReg.opPc)
				operand1 <= iDecoded.curPc;
			else if(iDecodedReg.opImm)
				operand1 <= iDecoded.imm;

			if(iDecodedReg.opRs2)
				operand2 <= iDecoded.rs2Data;
			else if (iDecodedReg.opConst)
				operand2 <= cXLEN'(4);
			else if(iDecodedReg.opImm)
				operand2 <= iDecoded.imm;
			else if(iDecodedReg.opPc)
				operand2 <= iDecoded.curPc;
		end
	end

	always_ff @(posedge iClk)
	begin : regOpRegister
		operation <= iDecodedReg.arithType;
		regAddr <= iDecoded.rdAddr;
		regOpValid<= iDecodedReg.dv;
	end

	always_ff @(posedge iClk)
	begin : regOpOperation
		regOut.addr <= regAddr;
		regOut.dv <= regOpValid;
		case (operation)
			eAdd 			: regOut.data <= signed'(operand1) + signed'(operand2);
			eSub 			: regOut.data <= signed'(operand1) - signed'(operand2);
			eShftLeft 		: regOut.data <= operand1 << operand2[$clog2(cDataWidth)-1:0];
			eCompareSigned	: regOut.data <= {(cXLEN-1)'(0),signed'(operand1) < signed'(operand2)}; 
			eCompareUnsigned: regOut.data <= {(cXLEN-1)'(0),operand1 < operand2}; 
			eXor 			: regOut.data <= operand1 ^ operand2;
			eShftRight 		: regOut.data <= operand1 >> operand2[$clog2(cDataWidth)-1:0];
			eShftRightArit  : regOut.data <= signed'(operand1) >> signed'(operand2[$clog2(cDataWidth)-1:0]); // TODO smth wrong 
			eOr 			: regOut.data <= operand1 | operand2;
			eAnd 			: regOut.data <= operand1 & operand2;
			eNoOp			: regOut.data <= operand1;

			default : regOut.data <= cXLEN'(0);
		endcase
	end




	//	tArithEnum aluOp;
	//	logic equal;
	//	logic lessThan;
	//	logic lessThanUns;
	//
	//
	//	assign	equal = iDecoded.rs1Data == iDecoded.rs2Data; // beq and bne comparison
	//	assign	lessThanUns = iDecoded.rs1Data < iDecoded.rs2Data; // bltu and bgeu comparison
	//	assign	lessThan    = signed'(iDecoded.rs1Data) < signed'(iDecoded.rs2Data); // blt and bge comparison






endmodule
	//		aluOut <= '{default:'0};
	//		case (iDecoded.opcode)
	//			eOpRtype :
	//			begin
	//				aluOut.regOp.addr <= iDecoded.rdAddr;
	//				aluOut.regOp.dv <= 1'b1;
	//				case (rSelection)
	//					4'b0000 : // add 
	//					begin
	//						aluOut.regOp.data <= signed'(iDecoded.rs1Data) + signed'(iDecoded.rs2Data);
	//					end
	//					4'b1000: // sub
	//					begin
	//						aluOut.regOp.data <= signed'(iDecoded.rs1Data) - signed'(iDecoded.rs2Data);
	//					end
	//					4'b0001 : // sll
	//					begin
	//						aluOut.regOp.data <= iDecoded.rs1Data << iDecoded.rs2Data[$clog2(cDataWidth)-1:0];
	//					end
	//					4'b0010 : // slt
	//					begin
	//						aluOut.regOp.data[cXLEN-1:1] <=  '{default:'0};
	//						aluOut.regOp.data[0] <=  signed'(iDecoded.rs1Data) < signed'(iDecoded.rs2Data);
	//					end
	//					4'b0011 : // sltu
	//					begin
	//						aluOut.regOp.data[cXLEN-1:1] <=  '{default:'0};
	//						aluOut.regOp.data[0] <=  iDecoded.rs1Data < iDecoded.rs2Data;
	//					end
	//					4'b0100 : // xor
	//					begin
	//						aluOut.regOp.data <=  iDecoded.rs1Data ^ iDecoded.rs2Data;
	//					end
	//					4'b0101 : // srl
	//					begin
	//						aluOut.regOp.data <= iDecoded.rs1Data >> iDecoded.rs2Data[$clog2(cDataWidth)-1:0];
	//					end
	//					4'b1101 : // srA
	//					begin
	//						aluOut.regOp.data <= signed'(iDecoded.rs1Data) >> iDecoded.rs2Data[$clog2(cDataWidth)-1:0];// TODO can be wrong
	//					end
	//					4'b0110 : // or
	//					begin
	//						aluOut.regOp.data <= iDecoded.rs1Data | iDecoded.rs2Data;
	//					end
	//					4'b0111 : // and
	//					begin
	//						aluOut.regOp.data <= iDecoded.rs1Data & iDecoded.rs2Data;
	//					end
	//
	//					default : statement_or_null_2;
	//				endcase
	//
	//			end
	//			eOpImmedi:
	//			begin
	//				aluOut.regOp.addr <= iDecoded.rdAddr;
	//				aluOut.regOp.dv  <= 1'b1;
	//				case (iDecoded.funct3)
	//					3'b000 : aluOut.regOp.data <= signed'(iDecoded.rs1Data) + signed'(iDecoded.imm);
	//
	//					3'b010 :
	//					begin
	//						aluOut.regOp.data[cXLEN-1:1] <=  '{default:'0};
	//						aluOut.regOp.data[0] <=  signed'(iDecoded.rs1Data) < signed'(iDecoded.imm);
	//					end
	//					3'b011:
	//					begin
	//						aluOut.regOp.data[cXLEN-1:1] <=  '{default:'0};
	//						aluOut.regOp.data[0] <=  iDecoded.rs1Data < iDecoded.imm ;
	//					end
	//					3'b100: aluOut.regOp.data <=  iDecoded.rs1Data ^ iDecoded.imm;
	//					3'b110: aluOut.regOp.data <=  iDecoded.rs1Data | iDecoded.imm;
	//					3'b111: aluOut.regOp.data <=  iDecoded.rs1Data & iDecoded.imm;
	//					3'b001: aluOut.regOp.data <= iDecoded.rs1Data << iDecoded.imm[$clog2(cDataWidth)-1:0];
	//					3'b101:
	//					begin
	//						if (iDecoded.funct7[5] == 1'b1)
	//							begin
	//								aluOut.regOp.data <= iDecoded.rs1Data >> iDecoded.imm[$clog2(cDataWidth)-1:0];		
	//							end
	//						else
	//							begin
	//								aluOut.regOp.data <= signed'(iDecoded.rs1Data) >> iDecoded.imm[$clog2(cDataWidth)-1:0]; // TODO can be wrong
	//							end
	//						
	//					end
	//					default : statement_or_null_2;
	//				endcase
	//			end
	//			eOpBranch:
	//			begin
	//				case (iDecoded.funct3)
	//					3'b000 : // beq 
	//					begin
	//						if(equal == 1'b1)
	//						begin
	//							aluOut.brchOp.branchTaken <= 1'b1;
	//							aluOut.brchOp.flushPipe   <= 1'b1;
	//							aluOut.brchOp.newPC 	  <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
	//						end
	//					end
	//					3'b001: // bne
	//					begin
	//						if(equal == 1'b0)
	//						begin
	//							aluOut.brchOp.branchTaken <= 1'b1;
	//							aluOut.brchOp.flushPipe   <= 1'b1;
	//							aluOut.brchOp.newPC 	  <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
	//						end
	//					end
	//					3'b100: //blt
	//					begin
	//						if(lessThan == 1'b1)
	//						begin
	//							aluOut.brchOp.branchTaken <= 1'b1;
	//							aluOut.brchOp.flushPipe   <= 1'b1;
	//							aluOut.brchOp.newPC 	  <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
	//						end
	//					end
	//					3'b101: //bge
	//					begin
	//						if(lessThan == 1'b0)
	//						begin
	//							aluOut.brchOp.branchTaken <= 1'b1;
	//							aluOut.brchOp.flushPipe   <= 1'b1;
	//							aluOut.brchOp.newPC 	  <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
	//						end
	//					end
	//					3'b110: //bltu
	//					begin
	//						if(lessThanUns == 1'b1)
	//						begin
	//							aluOut.brchOp.branchTaken <= 1'b1;
	//							aluOut.brchOp.flushPipe   <= 1'b1;
	//							aluOut.brchOp.newPC 	  <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
	//						end
	//					end
	//					3'b111: // bgeu
	//					begin
	//						if(lessThanUns == 1'b0)
	//						begin
	//							aluOut.brchOp.branchTaken <= 1'b1;
	//							aluOut.brchOp.flushPipe   <= 1'b1;
	//							aluOut.brchOp.newPC 	  <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
	//						end
	//					end
	//					default : NULL;
	//				endcase
	//			end
	//			eOpJal:
	//			begin
	//				aluOut.brchOp.branchTaken <= 1'b1;
	//				aluOut.brchOp.flushPipe   <= 1'b1;
	//				aluOut.brchOp.newPC <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
	//				
	//				aluOut.regOp.dv <=  1'b1;
	//				aluOut.regOp.addr <= iDecoded.rdAddr;
	//				aluOut.regOp.data <= signed'(iDecoded.curPc) + 4;
	//				
	//			end
	//			eOpJalr: 
	//			begin
	//				aluOut.brchOp.branchTaken <= 1'b1;
	//				aluOut.brchOp.flushPipe   <= 1'b1;
	//				aluOut.brchOp.newPC <= (signed'(iDecoded.rs1Data) + signed'(iDecoded.imm)) & {{cXLEN-1{1'b1}},1'b0};
	//				
	//				
	//				aluOut.regOp.dv <=  1'b1;
	//				aluOut.regOp.addr <= iDecoded.rdAddr;
	//				aluOut.regOp.data <= signed'(iDecoded.curPc) + 4;
	//					
	//			end
	//			eOpLui :
	//			begin
	//				aluOut.regOp.dv <=  1'b1;
	//				aluOut.regOp.addr <= iDecoded.rdAddr;
	//				aluOut.regOp.data <= iDecoded.imm;
	//			end
	//			eOpAuIpc:
	//			begin
	//				aluOut.regOp.dv <=  1'b1;
	//				aluOut.regOp.addr <= iDecoded.rdAddr;
	//				aluOut.regOp.data <= signed'(iDecoded.imm) + signed'(iDecoded.curPc);
	//			end
	//			
	//			
	//			default: begin
	//			end
	//		endcase
	//	end
	//	





