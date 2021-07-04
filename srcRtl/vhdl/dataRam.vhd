-------------------------------------------------------------------------------
-- Title      : dataram.vhd
-- Project    :
-------------------------------------------------------------------------------
-- File       : dataRam.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-07-04
-- Last update: 2021-07-05
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: data ram for store and load
-------------------------------------------------------------------------------
-- Copyright (c) 2021
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-07-04  1.0      otutay  Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.corePackage.all;
entity dataRam is

  port (
    iClk   : in std_logic;
    iRst   : in std_logic;
    iMemOp : in tMemOp
    );

end entity dataRam;
architecture rtl of dataRam is
  signal


begin  -- architecture rtl
  InstRam : entity work.ram
    generic map (
      cRamPerformance => "HIGH_PERFORMANCE",
      cRamWidth       => cXLen,
      cRamDepth       => cRamDepth
      )
    port map (
      iClk   => iClk,
      iRstA  => iRst,
      iEnA   => '1',
      iWEnA  => '0',
      iAddrA => curPc(log2(cRamDepth-1)-1 downto 0),
      iDataA => (others => '0'),
      oDataA => instruction,
      iRstB  => '0,
      iEnB   => '1'
      iWEnB  => instWen,
      iAddrB => instAddr,
      iDataB => instData,
      oDataB => open
      );



end architecture rtl;
