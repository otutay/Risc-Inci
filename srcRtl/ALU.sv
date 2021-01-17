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
    input tDecodedBranch iDecodedBranchOp,
    output tMemOp oMemWB,
    output tRegOp oRegWB,
    output tBranchOp oBranchWB

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


    // branch operation
    logic equal;
    logic lessThan;
    logic lessThanUns;
    tDecodedBranch branchOpi1;

    logic [cXLEN-1:0] curPc;
    logic [cXLEN-1:0] imm;
    logic [cXLEN-1:0] data1;

    tBranchOp branchOut;
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

    always_ff @(posedge iClk)
    begin : LoadStoreOperation_reg
        memOuti1 <= memOut;
    end

    assign oMemWB = memOuti1;
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

    assign oRegWB = regOut;
    //---------------------------- Branch Operation ----------------------------------
    always_ff @(posedge iClk)
    begin : branchCompare
        equal        <= iDecoded.rs1Data == iDecoded.rs2Data; // beq and bne comparison
        lessThanUns  <= iDecoded.rs1Data < iDecoded.rs2Data; // bltu and bgeu comparison
        lessThan     <= signed'(iDecoded.rs1Data) < signed'(iDecoded.rs2Data); // blt and bge comparison

        curPC <= iDecoded.curPc;
        imm  <= iDecoded.imm;
        data1 <= iDecoded.rs1Data;

        branchOpi1 <= iDecodedBranchOp;
    end


    always_ff @(posedge iClk)
    begin : branchOp
        if(branchOpi1.dv)
            begin
                case (branchOpi1.branchOp)
                    eEqual 			:
                    branchOut <= {equal,equal,equal,signed'(curPc) + signed'(imm)};

                    eNEqual 		:
                    branchOut <= {~equal,~equal,~equal,signed'(curPc) + signed'(imm)};

                    eLessThan 		:
                    branchOut <= {lessThan,lessThan,lessThan,signed'(curPc) + signed'(imm)};

                    eGreatEqual 	:
                    branchOut <= {~lessThan,~lessThan,~lessThan,signed'(curPc) + signed'(imm)};

                    eLessThanUns 	:
                    branchOut <= {lessThanUns,lessThanUns,lessThanUns,signed'(curPc) + signed'(imm)};

                    eGreatEqualUns 	:
                    branchOut <= {~lessThanUns,~lessThanUns,~lessThanUns,signed'(curPc) + signed'(imm)};

                    eJal 			:
                    branchOut <= {1'b1,1'b1,1'b1,signed'(curPc) + signed'(imm)};

                    eJalr 			:
                    branchOut <= {1'b1,1'b1,1'b1,((signed'(data1) + signed'(imm)) & {{cXLEN-1{1'b1}},1'b0})};

                    default : branchOut <= {1'b0,1'b0,1'b0,cXLEN'(0)};
                endcase
            end
        else
            branchOut <= {1'b0,1'b0,1'b0,cXLEN'(0)};

    end
    assign oBranchWB = branchOut;
endmodule
	





