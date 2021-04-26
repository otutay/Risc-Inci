-------------------------------------------------------------------------------
-- Title      : corePckg
-- Project    :
-------------------------------------------------------------------------------
-- File       : corePckg.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-16
-- Last update: 2021-04-27
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: package for riscInci
-------------------------------------------------------------------------------
-- Copyright (c) 2021
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-03-16  1.0      otutay  Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package corePckg is

  -- constants
  constant cRegSelBitW : integer := 5;
  constant cXLen       : integer := 32;
  constant cRegNum     : integer := 2**cRegSelBitW;
  constant cRamDepth   : integer := 1024;



  -- opcode constants
  constant cOpLoad   : std_logic_vector(6 downto 0) := "000" & x"3";
  constant cOpStore  : std_logic_vector(6 downto 0) := "010" & x"3";
  constant cOpRType  : std_logic_vector(6 downto 0) := "011" & x"3";
  constant cOpImmedi : std_logic_vector(6 downto 0) := "001" & x"3";
  constant cOpJalR   : std_logic_vector(6 downto 0) := "110" & x"7";
  constant cOpJal    : std_logic_vector(6 downto 0) := "110" & x"F";
  constant cOpLui    : std_logic_vector(6 downto 0) := "011" & x"7";
  constant cOpAuIpc  : std_logic_vector(6 downto 0) := "001" & x"7";
  constant cOpBranch : std_logic_vector(6 downto 0) := "110" & x"3";
  constant cOpCtrlSt : std_logic_vector(6 downto 0) := "111" & x"3";
  constant cOpNoop   : std_logic_vector(6 downto 0) := "111" & x"f";

  -- branchConstants;
  constant cBrEqual      : std_logic_vector(2 downto 0) := "000";
  constant cBrNEqual     : std_logic_vector(2 downto 0) := "001";
  constant cBrLessTh     : std_logic_vector(2 downto 0) := "100";
  constant cBrGreatEq    : std_logic_vector(2 downto 0) := "101";
  constant cBrLessThUns  : std_logic_vector(2 downto 0) := "110";
  constant cBrGreatEqUns : std_logic_vector(2 downto 0) := "111";
  constant cBrJal        : std_logic_vector(2 downto 0) := "010";
  constant cBrJalR       : std_logic_vector(2 downto 0) := "011";

  -- arithConstants
  constant cAdd             : std_logic_vector(3 downto 0) := "0000";
  constant cSub             : std_logic_vector(3 downto 0) := "1000";
  constant cShftLeft        : std_logic_vector(3 downto 0) := "0001";
  constant cCompareSigned   : std_logic_vector(3 downto 0) := "0010";
  constant cCompareUnSigned : std_logic_vector(3 downto 0) := "0011";
  constant cXor             : std_logic_vector(3 downto 0) := "0100";
  constant cShftRight       : std_logic_vector(3 downto 0) := "0101";
  constant cShftRightArith  : std_logic_vector(3 downto 0) := "1101";
  constant cOr              : std_logic_vector(3 downto 0) := "0110";
  constant cAnd             : std_logic_vector(3 downto 0) := "0111";
  constant cNoArith         : std_logic_vector(3 downto 0) := "1111";
  -- typedefs
  type tOpcodeEnum is (eOpLoad, eOpStore, eOpRtype, eOpImmedi,
                       eOpJalr, eOpJal, eOpLui, eOpAuIpc,
                       eOpBranch, eOpFence, eOpCtrlSt, eNOOP);

  type tRegOp is record                 -- regOp
    dv   : std_logic;
    addr : std_logic_vector(cRegSelBitW-1 downto 0);
    data : std_logic_vector(cXLen-1 downto 0);
  end record tRegOp;
  constant cRegOp : tRegOp := ('0', (others => '0'), (others => '0'));  -- initZero

  type tDecodedInst is record           -- decoded instruction
    rs1    : tRegOp;
    rs2    : tRegOp;
    rdAddr : std_logic_vector(cRegSelBitW-1 downto 0);
    funct3 : std_logic_vector(2 downto 0);
    funct7 : std_logic_vector(6 downto 0);
    imm    : std_logic_vector(cXLen-1 downto 0);
    opCode : tOpcodeEnum;
    curPc  : std_logic_vector(cXLen-1 downto 0);
  end record tDecodedInst;
  constant cDecodedInst : tDecodedInst := (cRegOp, cRegOp, (others => '0'), (others => '0'), (others => '0'),
                                           (others                 => '0'), eNOOP, (others => '0'));

  type tDecodedMem is record            -- decoded mem operation
    load  : std_logic;
    store : std_logic;
    dv    : std_logic;
  end record tDecodedMem;
  constant cDecodedMem : tDecodedMem := ('0', '0', '0');

  type tArithEnum is (eAdd, eSub, eShftLeft, eCompareSigned,
                      eCompareUnsigned, eXor, eShftRight,
                      eShftRightArit, eOr, eAnd, eNoArithOp);

  type tDecodedReg is record            -- decoded register operation
    arithType : tArithEnum;
    opRs1     : std_logic;
    opRs2     : std_logic;
    opImm     : std_logic;
    opPc      : std_logic;
    opConst   : std_logic;
    dv        : std_logic;
  end record tDecodedReg;
  constant cDecodedReg : tDecodedReg := (eNoArithOp, '0', '0', '0', '0', '0', '0');


  type tBranchEnum is (eEqual, eNEqual, eLessThan, eGreatEqual,
                       eLessThanUns, eGreatEqualUns, eJal, eJalr);

  type tDecodedBranch is record
    op : tBranchEnum;
    dv : std_logic;
  end record;
  constant cDecodedBranch : tDecodedBranch := (eEqual, '0');


  type tDecoded is record
    rs1Data : std_logic_vector(cXLen-1 downto 0);
    rs2Data : std_logic_vector(cXLen-1 downto 0);
    rdAddr  : std_logic_vector(cRegSelBitW-1 downto 0);
    funct3  : std_logic_vector(2 downto 0);
    funct7  : std_logic_vector(6 downto 0);
    imm     : std_logic_vector(cXLen-1 downto 0);
    opcode  : tOpcodeEnum;
    curPc   : std_logic_vector(cXLen-1 downto 0);
  end record;
  constant cDecoded : tDecoded := ((others => '0'), (others => '0'), (others => '0'), (others => '0'),
                                   (others => '0'), (others => '0'), eNOOP, (others => '0'));


  type tMemOp is record
    readDv  : std_logic;
    writeDv : std_logic;
    addr    : std_logic_vector(cXLen-1 downto 0);
    data    : std_logic_vector(cXLen-1 downto 0);
    opType  : std_logic_vector(2 downto 0);
    rdAddr  : std_logic_vector(cRegSelBitW-1 downto 0);
  end record;
  constant cMemOp : tMemOp := ('0', '0', (others => '0'), (others => '0'), (others => '0'), (others => '0'));

  type tBranchOp is record
    flushPipe : std_logic;
    newPc     : std_logic;
    pc        : std_logic_vector(cXLen-1 downto 0);
    dv        : std_logic;
  end record;
  constant cBranchOp : tBranchOp := ('0', '0', (others => '0'), '0');

  type tFetchCtrl is record
    pc    : std_logic_vector(cXLen-1 downto 0);
    newPc : std_logic;
    noOp  : std_logic;
  end record tFetchCtrl;
  constant cFetchCtrl : tFetchCtrl := ((others => '0'), '0', '0');


  -- function declarations
  -- function to_opcodeEnum(
  --   opcodeData : std_logic_vector(6 downto 0)
  --   )
  --   return tOpcodeEnum;

  -- function to_arithEnum (
  --   aritData : std_logic_vector(3 downto 0)
  --   )tDecodedBranch
  --   return tArithEnum;

  -- function to_branchEnum(
  --   branchData : std_logic_vector(2 downto 0)
  --   )
  --   return tBranchEnum;

  function log2(
    dataVal : natural
    )
    return natural;

end package corePckg;

package body corePckg is
  function log2(dataVal : natural)
    return natural is
    variable width : natural := 0;
    variable cnt   : natural := 1;

  begin
    while (cnt < dataVal) loop
      width := width + 1;
      cnt   := cnt * 2;
    end loop;
    return width;
  end function log2;



  -- function to_branchEnum(
  --   branchData : std_logic_vector(2 downto 0))
  --   return tBranchEnum is
  --   variable retVal : tBranchEnum;
  -- begin
  --   case branchData is
  --     when "000" =>
  --       retVal := eEqual;
  --     when "001" =>
  --       retVal := eNEqual;
  --     when "100" =>
  --       retVal := eLessThan;
  --     when "101" =>
  --       retVal := eGreatEqual;
  --     when "110" =>
  --       retVal := eLessThanUns;
  --     when "111" =>
  --       retVal := eGreatEqualUns;
  --     when "010" =>
  --       retVal := eJal;
  --     when "011" =>
  --       retVal := eJalr;
  --   end case;

  --   return retVal;
  -- end function to_branchEnum;


  -- function to_opcodeEnum(
  --   opcodeData : std_logic_vector(6 downto 0))
  --   return tOpcodeEnum is
  --   variable retVal : tOpcodeEnum;
  -- begin
  --   case opcodeData is
  --     when "000" & x"3" =>
  --       retVal := eOpLoad;
  --     when "010" & x"3" =>
  --       retVal := eOpStore;
  --     when "011" & x"3" =>
  --       retVal := eOpRtype;
  --     when "001" & x"3" =>
  --       retVal := eOpImmedi;
  --     when "110" & x"7" =>
  --       retVal := eOpJalr;
  --     when "110" & x"F" =>
  --       retVal := eOpJal;
  --     when "011" & x"7" =>
  --       retVal := eOpLui;
  --     when "001" & x"7" =>
  --       retVal := eOpAuIpc;
  --     when "110" & x"3" =>
  --       retVal := eOpBranch;
  --     when "111" & x"3"=>
  --       retVal := eOpCtrlSt;
  --     when "111" & x"f" =>
  --       retVal := eNOOP;
  --     when others =>
  --       retVal := eNOOP;
  --   end case;
  --   return retVal;
  -- end function to_opcodeEnum;

  -- function to_arithEnum (
  --   arithData : std_logic_vector(3 downto 0))
  --   return tArithEnum is
  --   variable retVal : tArithEnum;

  -- begin  -- function to_arithEnum
  --   case arithData is
  --     when "0000" =>
  --       retVal := eAdd;
  --     when "1000" =>
  --       retVal := eSub;
  --     when "0001" =>
  --       retVal := eShftLeft;
  --     when "0010" =>
  --       retVal := eCompareSigned;
  --     when "0011" =>
  --       retVal := eCompareUnsigned;
  --     when "0100" =>
  --       retVal := eXor;
  --     when "0101" =>
  --       retVal := eShftRight;
  --     when "1101" =>
  --       retVal := eShftRightArit;
  --     when "0110" =>
  --       retVal := eOr;
  --     when "0111" =>
  --       retVal := eAnd;
  --     when "1111" =>
  --       retVal := eNoArithOp;
  --   end case;
  --   return retVal;
  -- end function to_arithEnum;

end package body corePckg;
