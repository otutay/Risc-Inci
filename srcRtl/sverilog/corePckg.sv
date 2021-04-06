// ****************************************************************************
// * corePckg.sv
// * osmant
// *
// ****************************************************************************/

/**
 * Package: corePckg
 *
 * TODO: Add package documentation
 */
package corePckg;

    parameter int unsigned cRegSelBitW = 5;
    //	parameter int unsigned cDataWidth = 32;
    //	parameter int unsigned cPCBitW = 32;
    //	parameter int unsigned cImmBitW = 32;
    parameter int unsigned cXLEN = 32;
    parameter int unsigned cRegNum = 2**cRegSelBitW;
    parameter int unsigned cRamDepth = 1024;

    typedef enum logic [6:0]{
	eOpLoad   = 7'h03, // done; //
	eOpStore  = 7'h23, // done;//
	eOpRtype  = 7'h33, // done  //
	eOpImmedi = 7'h13, // done //
	eOpJalr   = 7'h67, // done //
	eOpJal	  = 7'h6f, // done //
	eOpLui	  = 7'h37, // done //
	eOpAuIpc  = 7'h17, // done //
	eOpBranch = 7'h63, // done //
	eOpFence  = 7'h0f, //
	eOpCntrlSt = 7'h73, //
	eNOOP = 7'hff //
    }tOpcodeEnum;

    typedef struct packed {
	logic dv;
	logic [cRegSelBitW-1:0] addr;
	logic [cXLEN-1:0] data;
    }tRegOp;
    parameter tRegOp cRegOp = {1'b0,{cRegSelBitW{1'b0}},{cXLEN{1'b0}}};

    typedef struct packed {
	//		logic [cRegSelBitW-1:0] rs1Addr;
	//		logic [cRegSelBitW-1:0] rs2Addr;
	tRegOp rs1;
	tRegOp rs2;
	logic [cRegSelBitW-1:0] rdAddr;
	logic [2:0] funct3;
	logic [6:0] funct7;
	logic[cXLEN-1:0] imm;
	tOpcodeEnum opcode;
	logic [cXLEN-1:0] curPc;
    }tDecodedInst;
    parameter tDecodedInst cDecodedInst = {cRegOp,cRegOp,{cRegSelBitW{1'b0}},{3{1'b0}},{7{1'b0}},{cXLEN{1'b0}},eNOOP,{cXLEN{1'b0}}};


    typedef struct packed {
	logic [cXLEN-1:0] rs1Data;
	logic [cXLEN-1:0] rs2Data;
	logic [cRegSelBitW-1:0] rdAddr;
	logic [2:0] funct3;
	logic [6:0] funct7;
	logic[cXLEN-1:0] imm;
	tOpcodeEnum opcode;
	logic [cXLEN-1:0] curPc;
    }tDecoded;

    typedef enum logic[3:0] {
	eAdd			= 4'b0000,
	eSub			= 4'b1000,
	eShftLeft		= 4'b0001,
	eCompareSigned	= 4'b0010,
	eCompareUnsigned= 4'b0011,
	eXor			= 4'b0100,
	eShftRight      = 4'b0101,
	eShftRightArit  = 4'b1101,
	eOr			= 4'b0110,
	eAnd			= 4'b0111,
	eNoArithOp      = 4'b1111
    }tArithEnum;


    typedef struct packed {
	logic load;
	logic store;
	logic dv;
    }tDecodedMem;
    parameter tDecodedMem cDecodedMem = {1'b0,1'b0,1'b0};

    typedef struct packed{
	tArithEnum arithType;
	logic opRs1;
	logic opRs2;
	logic opImm;
	logic opPc;
	logic opConst;
	logic dv;
    }tDecodedReg;
    parameter tDecodedReg cDecodedReg = {eNoArithOp,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};


    typedef enum logic [2:0]{
	eEqual			= 3'b000,
	eNEqual			= 3'b001,
	eLessThan		= 3'b100,
	eGreatEqual	= 3'b101,
	eLessThanUns	= 3'b110,
	eGreatEqualUns	= 3'b111,
	eJal			= 3'b010,
	eJalr			= 3'b011
    }tBranchEnum;

    typedef struct packed {
	tBranchEnum branchOp;
	logic dv;
    }tDecodedBranch;
    parameter tDecodedBranch cDecodedBranch = {eEqual,1'b0};



    typedef struct packed {
	logic read;
	logic write;
	logic [cXLEN-1:0] addr;
	logic [cXLEN-1:0] data;
	logic [2:0] opType;
	logic [cRegSelBitW-1:0] rdAddr;
    }tMemOp;

    typedef struct packed {
	//		logic branchTaken;
	logic flushPipe;
	logic newPC;
	logic [cXLEN-1:0] pc;
    }tBranchOp;

    typedef struct packed {
	tMemOp memOp;
	tRegOp regOp;
	tBranchOp brchOp;
    }tAluOut;

    typedef struct packed{
	logic [cXLEN-1:0] pc;
	logic newPc;
	logic noOp;
    }tFetchCtrl;




endpackage
