// ****************************************************************************
// * InstDecoder.sv
// * osmant 
// * parameter selected decoder 1 or 2 cycle
// ****************************************************************************/

import corePckg::*;
module InstDecoder
		#(parameter cycleNum = 2)
		(
	input logic iClk,
	input logic iRst,
	input logic [cXLEN-1:0] iInst,
	input logic [cXLEN-1:0] iCurPc,
	output tDecodedInst oDecoded,
	output tDecodedMem oMemOp,
	output tDecodedReg oRegOp,
	output tDecodedBranch oBranchOp
);

	logic [2:0] funct3;
	logic [6:0] funct7;
	logic [cRegSelBitW-1:0] destAddr;
	logic [cRegSelBitW-1:0] src1Addr;
	logic [cRegSelBitW-1:0] src2Addr;
	logic [cXLEN-1:0] insti1;
	logic [cXLEN-1:0] curPci1;
	tOpcodeEnum opcode;
	logic[3:0] rSelection;
	tDecodedInst dInst;
	tDecodedMem memOp;
	tDecodedReg regOp;
	tDecodedBranch branchOp;

	generate
		if(cycleNum == 1)
		begin : cycle1
			assign opcode 	   = tOpcodeEnum'(iInst[6:0]);
			assign src1Addr	   = iInst[19:15];
			assign src2Addr    = iInst[24:20];
			assign destAddr    = iInst[11:7];
			assign funct3 	   = iInst[14:12];
			assign funct7	   = iInst[31:25];
			assign insti1 	   = iInst;
			assign curPci1     = iCurPc;
			assign rSelection  = {iInst[30],iInst[14:12]};
		end

		if (cycleNum == 2)
		begin : cycle2
			always_ff @(posedge iClk) // opcode and input flops
			begin :flop
				opcode 	  	<= tOpcodeEnum'(iInst[6:0]);
				src1Addr	<= iInst[19:15];
				src2Addr 	<= iInst[24:20];
				destAddr 	<= iInst[11:7];
				funct3 	  	<= iInst[14:12];
				funct7	  	<= iInst[31:25];
				insti1 		<= iInst;
				curPci1     <= iCurPc;
				rSelection  <= {iInst[30],iInst[14:12]};
			end
		end
	endgenerate


	assign oDecoded = dInst;
	assign oMemOp   = memOp;
	assign oRegOp = regOp;
	assign oBranchOp = branchOp;

	always_ff @(posedge iClk)
	begin : operationDecide
		case (opcode)
			eOpLoad:
			begin
				// memOpDecode
				memOp.load <= 1'b1;
				memOp.store <= 1'b0;
				memOp.dv <= 1'b1;

				// regOpDecode
				regOp <= {eNoOp,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
				// branchOpDecode
				branchOp <= {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
			end
			eOpStore:
			begin
				// memOpDecode			
				memOp.load <= 1'b0;
				memOp.store <= 1'b1;
				memOp.dv <= 1'b1;

				// regOpDecode
				regOp <= {eNoOp,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
				// branchOpDecode
				branchOp <= {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
			end
			eOpRtype:
			begin
				// regOpDecode
				regOp.arithType <= tArithEnum'{rSelection};
				regOp.opRs1 <= 1'b1;
				regOp.opRs2 <= 1'b1;
				regOp.opImm <= 1'b0;
				regOp.opPc <= 1'b0;
				regOp.opConst <= 1'b0;
				regOp.dv <= 1'b1;


				// memOpDecode
				memOp <= {1'b0,1'b0,1'b0};

				// branchOpDecode
				branchOp <= {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
			end
			eOpImmedi:
			begin
				// regOpDecode
				case (funct3)
					3'b000 : regOp.arithType <= eAdd;
					3'b010 : regOp.arithType <= eCompareSigned;
					3'b011 : regOp.arithType <= eCompareUnsigned;
					3'b100 : regOp.arithType <= eXor;
					3'b110 : regOp.arithType <= eOr;
					3'b111 : regOp.arithType <= eAnd;
					3'b001 : regOp.arithType <= eShftLeft;
					3'b101 : regOp.arithType <= funct7[5] ? eShftRight : eShftRightArit;
					default : regOp.arithType <= eNoOp;
				endcase
				regOp.opRs1 <= 1'b1;
				regOp.opRs2 <= 1'b0;
				regOp.opImm <= 1'b1;
				regOp.opPc <= 1'b0;
				regOp.opConst <= 1'b0;
				regOp.dv <= 1'b1;
				// memOp
				memOp <= {1'b0,1'b0,1'b0};
				// branchOpDecode
				branchOp <= {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
			end
			eOpJal:
			begin
				//regOpCode
				regOp.arithType <= eAdd;
				regOp.opRs1 <= 1'b0;
				regOp.opRs2 <= 1'b0;
				regOp.opImm <= 1'b0;
				regOp.opPc <= 1'b1;
				regOp.opConst <= 1'b1;
				regOp.dv <= 1'b1;

				// branchOpDecode
				branchOp.branchTaken <= 1'b1;
				branchOp.flushPipe   <= 1'b1;
				branchOp.curPc 		 <= 1'b1;
				branchOp.imm 		 <= 1'b1;
				branchOp.rs1		 <= 1'b0;
				branchOp.decide		 <= 1'b0;
				branchOp.dv 		 <= 1'b1;

				//memOp
				memOp <= {1'b0,1'b0,1'b0};


			end
			eOpJalr:
			begin
				//regOpCode
				regOp.arithType <= eAdd;
				regOp.opRs1 <= 1'b0;
				regOp.opRs2 <= 1'b0;
				regOp.opImm <= 1'b0;
				regOp.opPc <= 1'b1;
				regOp.opConst <= 1'b1;
				regOp.dv <= 1'b1;
				
				// branchOpDecode
				branchOp.branchTaken <= 1'b1;
				branchOp.flushPipe   <= 1'b1;
				branchOp.curPc 		 <= 1'b0;
				branchOp.imm 		 <= 1'b1;
				branchOp.rs1		 <= 1'b1;
				branchOp.decide		 <= 1'b0;
				branchOp.dv 		 <= 1'b1;

				//memOp
				memOp <= {1'b0,1'b0,1'b0};
			end
			eOpLui:
			begin
				regOp.arithType <= eNoOp;
				regOp.opRs1 <= 1'b0;
				regOp.opRs2 <= 1'b0;
				regOp.opImm <= 1'b1;
				regOp.opPc <= 1'b0;
				regOp.opConst <= 1'b0;
				regOp.dv <= 1'b1;

				//memOp
				memOp <= {1'b0,1'b0,1'b0};
				
				// branchOpDecode
				branchOp <= {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
			end
			eOpAuIpc:
			begin
				regOp.arithType <= eAdd;
				regOp.opRs1 <= 1'b0;
				regOp.opRs2 <= 1'b0;
				regOp.opImm <= 1'b1;
				regOp.opPc <= 1'b1;
				regOp.opConst <= 1'b0;
				regOp.dv <= 1'b1;

				//memOp
				memOp <= {1'b0,1'b0,1'b0};
				
				// branchOpDecode
				branchOp <= {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
			end
			
			eOpBranch:
			begin
				// branchOpDecode
				branchOp.branchTaken <= 1'b0;
				branchOp.flushPipe   <= 1'b0;
				branchOp.curPc 		 <= 1'b1;
				branchOp.imm 		 <= 1'b1;
				branchOp.rs1		 <= 1'b0;
				branchOp.decide		 <= 1'b1;
				branchOp.dv 		 <= 1'b1;
				// regOpDecode
				regOp <= {eNoOp,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
				//memOp
				memOp <= {1'b0,1'b0,1'b0};
			end
			
			eOpFence : NULL;// not implemented
			eOpCntrlSt : NULL;// not implemented
			
			default : begin
				//memOp
				memOp <= {1'b0,1'b0,1'b0};
				// regOpDecode
				regOp <= {eNoOp,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
				// branchOpDecode
				branchOp <= {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
			end
			
		endcase
	end


	always_ff @(posedge iClk) // instructionDecode
	begin : decode
		dInst.rs1Addr <= src1Addr;
		dInst.rs2Addr <= src2Addr;
		dInst.rdAddr <= destAddr;
		dInst.funct3 <= funct3;
		dInst.funct7 <= funct7;
		dInst.opcode <= opcode;
		dInst.curPc <= curPci1;

		case (opcode)
			eOpLoad   :dInst.imm <= cXLEN'(signed'(insti1[31:20]));
			eOpStore  :dInst.imm <=  cXLEN'(signed'({insti1[31:25],insti1[11:7]}));
			eOpRtype  :dInst.imm <= cXLEN'(0);
			eOpFence  :dInst.imm <= cXLEN'(0);// not implemented yet
			eOpImmedi :dInst.imm <=  cXLEN'(signed'(insti1[31:20]));  
			eOpAuIpc  :dInst.imm <= {insti1[31:12],{12{1'b0}}};
			eOpLui    :dInst.imm <= {insti1[31:12],{12{1'b0}}};
			eOpBranch :dInst.imm <= {{cXLEN-12{insti1[31]}},insti1[7],insti1[30:25],insti1[11:8],1'b0};
			eOpJalr   :dInst.imm <= cXLEN'(signed'(insti1[31:20])); //{{20{1'b0}},insti1[31:20]};
			eOpJal    :dInst.imm <= cXLEN'(signed'({insti1[31],insti1[19:12],insti1[20],insti1[30:21],1'b0}));
			eOpCntrlSt:dInst.imm <= cXLEN'(0);// not implemented yet
			default   :dInst.imm <= cXLEN'(0);
		endcase
	end





endmodule


