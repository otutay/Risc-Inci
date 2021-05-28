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

   // opcode constants
   parameter logic [6:0]  cOpLoad = 7'h03;
   parameter logic [6:0]  cOpStore = 7'h23;
   parameter logic [6:0]  cOpRtype = 7'h33;
   parameter logic [6:0]  cOpImmedi = 7'h13;
   parameter logic [6:0]  cOpJalr = 7'h67;
   parameter logic [6:0]  cOpJal = 7'h6f;
   parameter logic [6:0]  cOpLui = 7'h37;
   parameter logic [6:0]  cOpAuIpc = 7'h17;
   parameter logic [6:0]  cOpBranch = 7'h63;
   parameter logic [6:0]  cOpFence = 7'h0f;
   parameter logic [6:0]  cOpCtrlSt = 7'h73;
   parameter logic [6:0]  cOpNOOP = 7'h7f;

   // arithtype constants
   parameter logic [3:0]  cAdd = 4'b0000;
   parameter logic [3:0]  cSub = 4'b1000;
   parameter logic [3:0]  cShftLeft = 4'b0001;
   parameter logic [3:0]  cCompareSigned	= 4'b0010;
   parameter logic [3:0]  cCompareUnsigned = 4'b0011;
   parameter logic [3:0]  cXor = 4'b0100;
   parameter logic [3:0]  cShftRight = 4'b0101;
   parameter logic [3:0]  cShftRightArit  = 4'b1101;
   parameter logic [3:0]  cOr = 4'b0110;
   parameter logic [3:0]  cAnd = 4'b0111;
   parameter logic [3:0]  cNoArithOp = 4'b1111;
   // branch type
   parameter logic [2:0]  cEqual	= 3'b000;
   parameter logic [2:0]  cNEqual	= 3'b001;
   parameter logic [2:0]  cLessThan	= 3'b100;
   parameter logic [2:0]  cGreatEqual	= 3'b101;
   parameter logic [2:0]  cLessThanUns	= 3'b110;
   parameter logic [2:0]  cGreatEqualUns	= 3'b111;
   parameter logic [2:0]  cJal	= 3'b010;
   parameter logic [2:0]  cJalr	= 3'b011;

   typedef enum		  logic [6:0]{
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
				      eNOOP = 7'h7f //
				      }tOpcodeEnum;

   typedef struct	  packed {
      logic		  dv;
      logic [cRegSelBitW-1:0] addr;
      logic [cXLEN-1:0]       data;
   }tRegOp;
   parameter tRegOp cRegOp = {1'b0,{cRegSelBitW{1'b0}},{cXLEN{1'b0}}};

   typedef struct	      packed {
      //		logic [cRegSelBitW-1:0] rs1Addr;
      //		logic [cRegSelBitW-1:0] rs2Addr;
      tRegOp rs1;
      tRegOp rs2;
      logic [cRegSelBitW-1:0] rdAddr;
      logic [2:0]	      funct3;
      logic [6:0]	      funct7;
      logic [cXLEN-1:0]       imm;
      //	tOpcodeEnum opcode;
      logic [6:0]	      opcode;
      logic [cXLEN-1:0]       curPc;
   }tDecodedInst;
   parameter tDecodedInst cDecodedInst = {cRegOp,cRegOp,{cRegSelBitW{1'b0}},{3{1'b0}},{7{1'b0}},{cXLEN{1'b0}},cOpNOOP,{cXLEN{1'b0}}};


   typedef struct	      packed {
      logic [cXLEN-1:0]       rs1Data;
      logic [cXLEN-1:0]       rs2Data;
      logic [cRegSelBitW-1:0] rdAddr;
      logic [2:0]	      funct3;
      logic [6:0]	      funct7;
      logic [cXLEN-1:0]       imm;
//      tOpcodeEnum opcode;
      logic [6:0]	      opcode;
      logic [cXLEN-1:0]       curPc;
   }tDecoded;

   typedef enum		      logic[3:0] {
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


   typedef struct	      packed {
      logic		      load;
      logic		      store;
      logic		      dv;
   }tDecodedMem;
   parameter tDecodedMem cDecodedMem = {1'b0,1'b0,1'b0};

   typedef struct	      packed{
      //tArithEnum arithType;
      logic [3:0]	      arithType;
      logic		      opRs1;
      logic		      opRs2;
      logic		      opImm;
      logic		      opPc;
      logic		      opConst;
      logic		      dv;
   }tDecodedReg;
   parameter tDecodedReg cDecodedReg = {cNoArithOp,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};


   typedef enum		      logic [2:0]{
					  eEqual			= 3'b000,
					  eNEqual			= 3'b001,
					  eLessThan		= 3'b100,
					  eGreatEqual	= 3'b101,
					  eLessThanUns	= 3'b110,
					  eGreatEqualUns	= 3'b111,
					  eJal			= 3'b010,
					  eJalr			= 3'b011
					  }tBranchEnum;

   typedef struct	      packed {
      logic [2:0] op;
      logic		      dv;
   }tDecodedBranch;
   parameter tDecodedBranch cDecodedBranch = {cEqual,1'b0};



   typedef struct	      packed {
      logic		      read;
      logic		      write;
      logic [cXLEN-1:0]       addr;
      logic [cXLEN-1:0]       data;
      logic [2:0]	      opType;
      logic [cRegSelBitW-1:0] rdAddr;
   }tMemOp;

   typedef struct	      packed {
      //		logic branchTaken;
      logic		      flushPipe;
      logic		      newPC;
      logic [cXLEN-1:0]       pc;
      logic		      dv;
   }tBranchOp;

   typedef struct	      packed {
      tMemOp memOp;
      tRegOp regOp;
      tBranchOp brchOp;
   }tAluOut;

   typedef struct	      packed{
      logic [cXLEN-1:0]       pc;
      logic		      newPc;
      logic		      noOp;
   }tFetchCtrl;




endpackage
