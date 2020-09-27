// ****************************************************************************
// * ALU.sv
// * osmant 
// * 
// ****************************************************************************/

/**
 * Module: ALU
 * 
 * TODO: Add module documentation
 */
import corePckg::*;
module ALU
		(
	input logic iClk,
	input logic iRst,
	input tDecoded iDecoded

);
	tAluOut aluOut;

	logic[3:0] rSelection;
	logic equal;
	logic lessThan;
	logic lessThanUns;

	assign	rSelection = {iDecoded.funct7[5],iDecoded.funct3};
	assign	equal = iDecoded.rs1Data == iDecoded.rs2Data; // beq and bne comparison
	assign	lessThanUns = iDecoded.rs1Data < iDecoded.rs2Data; // bltu and bgeu comparison
	assign	lessThan    = signed'(iDecoded.rs1Data) < signed'(iDecoded.rs2Data); // blt and bge comparison


	always_ff @(posedge iClk)
	begin : operation
		aluOut <= '{default:'0};
		case (iDecoded.opcode)
			eOpLoad:
			begin
				aluOut.memOp.addr <= signed'(iDecoded.rs1Data) + signed'(siDecoded.imm);
				aluOut.memOp.rdAddr<= iDecoded.rdAddr;
				aluOut.memOp.opType <= iDecoded.funct3;
				aluOut.memOp.read <= 1'b1;
			end
			eOpStore:
			begin
				aluOut.addr <= signed'(iDecoded.rs1Data) + signed'(iDecoded.imm);
				aluOut.data <= iDecoded.rs2Data;
				aluOut.memOp.opType <= iDecoded.funct3;
				aluOut.memOp.write <= 1'b1;
			end
			eOpRtype :
			begin
				aluOut.regOp.addr <= iDecoded.rdAddr;
				aluOut.regOp.dv <= 1'b1;
				case (rSelection)
					4'b0000 : // add 
					begin
						aluOut.regOp.data <= signed'(iDecoded.rs1Data) + signed'(iDecoded.rs2Data);
					end
					4'b1000: // sub
					begin
						aluOut.regOp.data <= signed'(iDecoded.rs1Data) - signed'(iDecoded.rs2Data);
					end
					4'b0001 : // sll
					begin
						aluOut.regOp.data <= iDecoded.rs1Data << iDecoded.rs2Data[$clog2(cDataWidth)-1:0];
					end
					4'b0010 : // slt
					begin
						aluOut.regOp.data[cXLEN-1:1] <=  '{default:'0};
						aluOut.regOp.data[0] <=  signed'(iDecoded.rs1Data) < signed'(iDecoded.rs2Data);
					end
					4'b0011 : // sltu
					begin
						aluOut.regOp.data[cXLEN-1:1] <=  '{default:'0};
						aluOut.regOp.data[0] <=  iDecoded.rs1Data < iDecoded.rs2Data;
					end
					4'b0100 : // xor
					begin
						aluOut.regOp.data <=  iDecoded.rs1Data ^ iDecoded.rs2Data;
					end
					4'b0101 : // srl
					begin
						aluOut.regOp.data <= iDecoded.rs1Data >> iDecoded.rs2Data[$clog2(cDataWidth)-1:0];
					end
					4'b1101 : // srA
					begin
						aluOut.regOp.data <= signed'(iDecoded.rs1Data) >> iDecoded.rs2Data[$clog2(cDataWidth)-1:0];// TODO can be wrong
					end
					4'b0110 : // or
					begin
						aluOut.regOp.data <= iDecoded.rs1Data | iDecoded.rs2Data;
					end
					4'b0111 : // and
					begin
						aluOut.regOp.data <= iDecoded.rs1Data & iDecoded.rs2Data;
					end

					default : statement_or_null_2;
				endcase

			end
			eOpBranch:
			begin
				case (iDecoded.funct3)
					3'b000 : // beq 
					begin
						if(equal == 1'b1)
						begin
							aluOut.brchOp.branchTaken <= 1'b1;
							aluOut.brchOp.flushPipe   <= 1'b1;
							aluOut.brchOp.newPC 	  <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
						end
					end
					3'b001: // bne
					begin
						if(equal == 1'b0)
						begin
							aluOut.brchOp.branchTaken <= 1'b1;
							aluOut.brchOp.flushPipe   <= 1'b1;
							aluOut.brchOp.newPC 	  <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
						end
					end
					3'b100: //blt
					begin
						if(lessThan == 1'b1)
						begin
							aluOut.brchOp.branchTaken <= 1'b1;
							aluOut.brchOp.flushPipe   <= 1'b1;
							aluOut.brchOp.newPC 	  <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
						end
					end
					3'b101: //bge
					begin
						if(lessThan == 1'b0)
						begin
							aluOut.brchOp.branchTaken <= 1'b1;
							aluOut.brchOp.flushPipe   <= 1'b1;
							aluOut.brchOp.newPC 	  <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
						end
					end
					3'b110: //bltu
					begin
						if(lessThanUns == 1'b1)
						begin
							aluOut.brchOp.branchTaken <= 1'b1;
							aluOut.brchOp.flushPipe   <= 1'b1;
							aluOut.brchOp.newPC 	  <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
						end
					end
					3'b111: // bgeu
					begin
						if(lessThanUns == 1'b0)
						begin
							aluOut.brchOp.branchTaken <= 1'b1;
							aluOut.brchOp.flushPipe   <= 1'b1;
							aluOut.brchOp.newPC 	  <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
						end
					end
					default : NULL;
				endcase
			end
			eOpImmedi:
			begin
				aluOut.regOp.addr <= iDecoded.rdAddr;
				aluOut.regOp.dv  <= 1'b1;
				case (iDecoded.funct3)
					3'b000 : aluOut.regOp.data <= signed'(iDecoded.rs1Data) + signed'(iDecoded.imm);

					3'b010 :
					begin
						aluOut.regOp.data[cXLEN-1:1] <=  '{default:'0};
						aluOut.regOp.data[0] <=  signed'(iDecoded.rs1Data) < signed'(iDecoded.imm);
					end
					3'b011:
					begin
						aluOut.regOp.data[cXLEN-1:1] <=  '{default:'0};
						aluOut.regOp.data[0] <=  iDecoded.rs1Data < iDecoded.imm ;
					end
					3'b100: aluOut.regOp.data <=  iDecoded.rs1Data ^ iDecoded.imm;
					3'b110: aluOut.regOp.data <=  iDecoded.rs1Data | iDecoded.imm;
					3'b111: aluOut.regOp.data <=  iDecoded.rs1Data & iDecoded.imm;
					3'b001: aluOut.regOp.data <= iDecoded.rs1Data << iDecoded.imm[$clog2(cDataWidth)-1:0];
					3'b101:
					begin
						if (iDecoded.funct7[5] == 1'b1)
							begin
								aluOut.regOp.data <= iDecoded.rs1Data >> iDecoded.imm[$clog2(cDataWidth)-1:0];		
							end
						else
							begin
								aluOut.regOp.data <= signed'(iDecoded.rs1Data) >> iDecoded.imm[$clog2(cDataWidth)-1:0]; // TODO can be wrong
							end
						
					end
					default : statement_or_null_2;
				endcase
			end
			eOpJal:
			begin
				aluOut.brchOp.branchTaken <= 1'b1;
				aluOut.brchOp.flushPipe   <= 1'b1;
				aluOut.brchOp.newPC <= signed'(iDecoded.curPc) + signed'(iDecoded.imm);
				
				aluOut.regOp.dv <=  1'b1;
				aluOut.regOp.addr <= iDecoded.rdAddr;
				aluOut.regOp.data <= signed'(iDecoded.curPc) + 4;
				
			end
			default: begin
			end
		endcase
	end

endmodule


