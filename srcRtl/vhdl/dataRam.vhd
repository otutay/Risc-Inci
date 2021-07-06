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
  signal ramEn      : std_logic                          := '0';
  signal ramWEn     : std_logic                          := '0';
  signal ramAddr    : std_logic_vector(cXLen-1 downto 0) := (others => '0');
  signal ramDataIn  : std_logic_vector(cXLen-1 downto 0) := (others => '0');
  signal ramDataOut : std_logic_vector(cXLen-1 downto 0) := (others => '0');


begin  -- architecture rtl

  ramCtrlPro : process (all) is
  begin  -- process ramCtrlPro
    ramEn     <= iMemOp.readDv or iMemOp.writeDv;
    ramWEn    <= iMemOp.writeDv;
    ramAddr   <= iMemOp.addr;
    ramDataIn <= iMemOp.data;
  end process ramCtrlPro;



  InstRam : entity work.ram
    generic map (
      cRamPerformance => "HIGH_PERFORMANCE",
      cRamWidth       => cXLen,
      cRamDepth       => cRamDepth
      )
    port map (
      iClk   => iClk,
      iRstA  => iRst,
      iEnA   => ramEn,
      iWEnA  => ramWEn,
      iAddrA => ramAddr(log2(cRamDepth-1)-1 downto 0),
      iDataA => ramDataIn,
      oDataA => ramDataOut,
      iRstB  => '0,
      iEnB   => '1'
      iWEnB  => instWen,
      iAddrB => instAddr,
      iDataB => instData,
      oDataB => open
      );



end architecture rtl;
