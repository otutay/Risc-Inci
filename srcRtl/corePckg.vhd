-------------------------------------------------------------------------------
-- Title      : corePckg
-- Project    :
-------------------------------------------------------------------------------
-- File       : corePckg.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-16
-- Last update: 2021-03-20
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
  -- attributes
  attribute enum_encoding : string;

  -- constants
  constant cRegSelBitW : integer := 5;
  constant cXLen       : integer := 32;
  constant cRegNum     : integer := 2**cRegSelBitW;
  constant cRamDepth   : integer := 1024;

  -- opcode Constants
  -- constant cOpLoad   : std_logic_vector(6 downto 0) := "000" & x"3";
  -- constant cOpStore  : std_logic_vector(6 downto 0) := "010" & x"3";
  -- constant cOpRtype  : std_logic_vector(6 downto 0) := "011" & x"3";
  -- constant cOpImmedi : std_logic_vector(6 downto 0) := "001" & x"3";
  -- constant cOpJalR   : std_logic_vector(6 downto 0) := "110" & x"7";
  -- constant cOpJal    : std_logic_vector(6 downto 0) := "110" & x"F";
  -- constant cOpLui    : std_logic_vector(6 downto 0) := "011" & x"7";
  -- constant cOpAuIpc  : std_logic_vector(6 downto 0) := "001" & x"7";
  -- constant cOpBranch : std_logic_vector(6 downto 0) := "110" & x"3";
  -- constant cOpCtrlSt : std_logic_vector(6 downto 0) := "111" & x"3";
  -- constant cOpNoOp   : std_logic_vector(6 downto 0) := "111" & x"f";




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
    opCode : std_logic_vector(6 downto 0);
    curPc  : std_logic_vector(cXLen-1 downto 0);
  end record tDecodedInst;
  constant cDecodedInst : tDecodedInst := (cRegOp, cRegOp, (others => '0'), (others => '0'), (others => '0'),
                                           (others                 => '0'), (others => '0'), (others => '0'));

  type tDecodedMem is record            -- decoded mem operation
    load  : std_logic;
    store : std_logic;
    dv    : std_logic;
  end record tDecodedMem;
  constant cDecodedMem : tDecodedMem := ('0', '0', '0');

  type tArithEnum is (eAdd, eSub, eShftLeft, eCompareSigned,
                      eCompareUnsigned, eXor, eShftRight,
                      eShftRightArit, eOr, eAnd, eNoArithOp);

  attribute enum_encoding of tArithEnum : type is "0000 1000 0001 0010 0011
    0100 0101 1101 0110 0111 1111 ";

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

  attribute enum_encoding of tBranchEnum : type is "000 001 100 101 110 111 010 011";

  type tDecodedBranch is record
    branchOp : tBranchEnum;
    dv       : std_logic;
  end record;
  constant cDecodedBranch : tDecodedBranch := (eEqual, '0');


  function to_opcodeEnum(
    signal opcodeData : std_logic_vector(7 downto 0)
    )
    return tOpcodeEnum;

  function to_arithEnum (
    signal aritData : std_logic_vector(3 downto0)
    )
    return tArithEnum;



end package corePckg;

package body corePckg is

  function to_opcodeEnum(
    signal opcodeData : std_logic_vector(7 downto 0))
    return tOpcodeEnum is
    variable retVal : tOpcodeEnum;
  begin
    case opcodeData is
      when "000" & x"3" =>
        retVal := eOpLoad;
      when "010" & x"3" =>
        retVal := eOpStore;
      when "011" & x"3" =>
        retVal := eOpRtype;
      when "001" & x"3" =>
        retVal := eOpImmedi;
      when "110" & x"7" =>
        retVal := eOpJalr;
      when "110" & x"F" =>
        retVal := eOpJal;
      when "011" & x"7" =>
        retVal := eOpLui;
      when "001" & x"7" =>
        retVal := eOpAuIpc;
      when "110" & x"3" =>
        retVal := eOpBranch;
      when "111" & x"3"=>
        retVal := eOpCtrlSt;
      when "111" & x"f" =>
        retVal := eNOOP;
      when others =>
        retVal := eNOOP;
    end case;
    return retVal;
  end function to_opcodeEnum;

  function to_arithEnum (
    signal arithData : std_logic_vector(3 downto 0))
    return tArithEnum is
    variable retVal : tArithEnum;

  begin  -- function to_arithEnum
    case arithData is
      when "0000" =>
        retVal := eAdd;
      when "1000" =>
        retVal := eSub;
      when "0001" =>
        retVal := eShftLeft;
      when "0010" =>
        retVal := eCompareSigned;
      when "0011" =>
        retVal := eCompareUnsigned;
      when "0100" =>
        retVal := eXor;
      when "0101" =>
        retVal := eShftRight;
      when "1101" =>
        retVal := eShftRightArit;
      when "0110" =>
        retVal := eOr;
      when "0111" =>
        retVal := eAnd;
      when "1111" =>
        retVal := eNoArithOp;
    end case;
    return retVal;
  end function to_arithEnum;

end package body corePckg;
