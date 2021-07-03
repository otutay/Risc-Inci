-------------------------------------------------------------------------------
-- Title      : fetch
-- Project    :
-------------------------------------------------------------------------------
-- File       : fetch.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-25
-- Last update: 2021-07-04
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: fetch stage
-------------------------------------------------------------------------------
-- Copyright (c) 2021
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-03-25  1.0      otutay  Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.corePckg.all;

entity fetch is

  port (
    iClk        : in  std_logic;
    iRst        : in  std_logic;
    -- fetch ctrl interface
    iFetchCtrl  : in  iFetchCtrl;
    oCurPc      : out std_logic_vector(cXLen-1 downto 0);
    oInstr      : out std_logic_vector(cXLen-1 downto 0);
    -- inst load interface
    iInst2Write : in  std_logic_vector(cXLen-1 downto 0);
    iInstWen    : in  std_logic
    );

end entity fetch;

architecture rtl of fetch is
  -- signal LSWen       : std_logic                                      := '0';
  -- signal LSEn        : std_logic                                      := '0';
  -- signal LSAddr      : std_logic_vector(log2(cRamDepth-1)-1 downto 0) := (others => '0');
  -- signal LSStoreData : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  -- signal LSLoadData  : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  -- signal readDv      : std_logic                                      := '0';
  -- signal rdAddri1    : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  -- signal regOp       : tRegOp                                         := cRegOp;

  -- signal readAddr    : std_logic_vector(log2(cRamDepth-1)-1 downto 0) := (others => '0');
  signal curPc       : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal instruction : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal instWen     : std_logic                                      := '0';
  signal instAddr    : std_logic_vector(log2(cRamDepth-1)-1 downto 0) := (others => '0');
  signal instData    : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
begin  -- architecture rtl

  pcPro : process (iClk) is
  begin  -- process pcPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iFetchCtrl.noOp = '1') then
        curPc <= curPc;
      elsif(iFetchCtrl.newPc = '1') then
        curPc <= iFetchCtrl.pc;
      else
        curPc <= std_logic_vector(unsigned(curPc) + 1);
      end if;
    end if;
  end process pcPro;

  instrOutPro : process (iClk) is
  begin  -- process instrOutPro
     if iClk'event and iClk = '1' then   -- rising clock edge
    if(iFetchCtrl.newPc = '1') then
      oInstr <= (others => '0');
    else
      oInstr <= instruction;
    end if;
   end if;
  end process instrOutPro;

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

  instr2LoadPro : process (iClk) is
  begin  -- process instr2LoadPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iRst = '1') then
        instAddr <= (others => '0');
        instWen  <= '0';
        instData <= (others => '0');
      else
        instData <= iInst2Write;
        instWen  <= iInstWen;
        if(iInstWen = '1') then
          instAddr <= std_logic_vector(unsigned(instAddr) + 1);
        end if;
      end if;
    end if;
  end process instr2LoadPro;

end architecture rtl;
