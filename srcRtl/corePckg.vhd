-------------------------------------------------------------------------------
-- Title      : corePckg
-- Project    :
-------------------------------------------------------------------------------
-- File       : corePckg.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-16
-- Last update: 2021-03-16
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

  constant cOpLoad   : std_logic_vector(6 downto 0) := "000" & x"3";
  constant cOpStore  : std_logic_vector(6 downto 0) := "010" & x"3";
  constant cOpRtype  : std_logic_vector(6 downto 0) := "011" & x"3";
  constant cOpImmedi : std_logic_vector(6 downto 0) := "001" & x"3";
  constant cOpJalR   : std_logic_vector(6 downto 0) := "110" & x"7";
  constant cOpJal    : std_logic_vector(6 downto 0) := "110" & x"F";
  constant cOpLui    : std_logic_vector(6 downto 0) := "011" & x"7";
  constant cOpAuIpc  : std_logic_vector(6 downto 0) := "001" & x"7";
  constant cOpBranch : std_logic_vector(6 downto 0) := "110" & x"3";
  constant cOpCtrlSt : std_logic_vector(6 downto 0) := "111" & x"3";
  constant cOpNoOp   : std_logic_vector(6 downto 0) := "111" & x"f";




  -- typedefs
  type tRegOp is record                 -- regOp
    dv   : std_logic;
    addr : std_logic_vector(cRegSelBitW-1 downto 0);
    data : std_logic_vector(cXLen-1 downto 0);
  end record tRegOp;
  constant cRegOp : tRegOp := ('0',(others => '0'),(others => '0'));  -- initZero

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


end package corePckg;

package body corePckg is



end package body corePckg;
