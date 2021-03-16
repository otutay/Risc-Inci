-------------------------------------------------------------------------------
-- Title      : instDecoder
-- Project    :
-------------------------------------------------------------------------------
-- File       : instDecoder.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-16
-- Last update: 2021-03-16
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: instruction decode code for risc inci
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

entity instDecoder is
  generic (
    cycleNum : integer := 2             -- cycleNum for instruction decode.
    );
  port (
    iClk       : in  std_logic;
    iRst       : in  std_logic;
    iInst      : in  std_logic_vector(cXLen-1 downto 0);
    iCurPc     : in  std_logic_vector(cXLen-1 downto 0);
    iFlushPipe : in  std_logic;
    oDecoded   : out tDecodedInst;
    oMemOp     : out tDecodedMem;
    oRegOp     : out tDecodedReg;
    oBranchOp  : out tDecodedBranch
    );

end entity instDecoder;
architecture rtl of instDecoder is

begin  -- architecture rtl
  OneCycleGen : if cycleNum = 1 generate

    flop: process (all) is
    begin  -- process flop

    end process flop;

  end generate OneCycleGen;


end architecture rtl;
