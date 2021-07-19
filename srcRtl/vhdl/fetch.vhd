-------------------------------------------------------------------------------
-- Title      : fetch
-- Project    :
-------------------------------------------------------------------------------
-- File       : fetch.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-25
-- Last update: 2021-07-20
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
use work.corePackage.all;

entity fetch is

  port (
    iClk        : in  std_logic;
    iRst        : in  std_logic;
    iStart      : in  std_logic;
    -- fetch ctrl interface
    iFetchCtrl  : in  tFetchCtrl;
    oCurPc      : out std_logic_vector(cXLen-1 downto 0);
    oInstr      : out std_logic_vector(cXLen-1 downto 0);
    -- inst load interface
    iInst2Write : in  std_logic_vector(cXLen-1 downto 0);
    iInstWen    : in  std_logic
    );

end entity fetch;

architecture rtl of fetch is
  signal execute     : std_logic                                      := '0';
  signal ramAddr     : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal curPc       : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal curPci1     : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal instruction : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal instEn      : std_logic                                      := '0';
  signal instWen     : std_logic                                      := '0';
  signal instAddr    : std_logic_vector(log2(cRamDepth-1)-1 downto 0) := (others => '0');
  signal instData    : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal newPci1     : std_logic                                      := '0';
begin  -- architecture rtl

  -- output signal assignment

  oInstr <= instruction;
  outCurPcPro : process (iClk) is
  begin  -- process outCurPcPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      curPci1 <= curPC;
      oCurPc  <= curPCi1;
    end if;
  end process outCurPcPro;

  -- start execution
  startDecidePro : process (iClk) is
  begin  -- process startDecidePro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iRst = '1') then
        execute <= '0';
      elsif(unsigned(curPc) >= unsigned(instAddr)) then
        execute <= '0';
      elsif(iStart = '1') then
        execute <= '1';
      end if;
    end if;
  end process startDecidePro;


  -- pc arrangement
  pcPro : process (iClk) is
  begin  -- process pcPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iRst = '1') then
        curPC <= (others => '0');
      elsif (iFetchCtrl.newPc = '1' and execute = '1') then
        curPc <= std_logic_vector(unsigned(iFetchCtrl.pc) + 1);
      elsif(iFetchCtrl.noOp = '0' and execute = '1') then
        curPc <= std_logic_vector(unsigned(curPc) + 1);
      end if;
    end if;
  end process pcPro;

  -- ram addr selection
  ramAddrPro : process (all) is
  begin  -- process ramAddrPro
    if(iFetchCtrl.newPc = '1') then
      ramAddr <= iFetchCtrl.pc;
    else
      ramAddr <= curPc;
    end if;
  end process ramAddrPro;

  InstRam : entity work.ram
    generic map (
      cRamPerformance => "HIGH_PERFORMANCE",
      cRamWidth       => cXLen,
      cRamDepth       => cRamDepth
      )
    port map (
      iClk   => iClk,
      iRstA  => iRst,
      iEnA   => execute,
      iWEnA  => '0',
      iAddrA => ramAddr(log2(cRamDepth-1)-1 downto 0),
      iDataA => (others => '0'),
      oDataA => instruction,
      iRstB  => '0',
      iEnB   => instEn,
      iWEnB  => instWen,
      iAddrB => instAddr,
      iDataB => instData,
      oDataB => open
      );

  -- instruction 2 load
  instr2LoadPro : process (iClk) is
  begin  -- process instr2LoadPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iRst = '1') then
        instAddr <= (others => '1');    -- start in 0
        instWen  <= '0';
        instData <= (others => '0');
      else
        instData <= iInst2Write;
        instWen  <= iInstWen;
        instEn   <= iInstWen;
        if(iInstWen = '1') then
          instAddr <= std_logic_vector(unsigned(instAddr) + 1);
        end if;
      end if;
    end if;
  end process instr2LoadPro;

end architecture rtl;


-- pipelined 2 clk latency

-- pcPro : process (iClk) is
-- begin  -- process pcPro
--   if iClk'event and iClk = '1' then   -- rising clock edge
--     if (iRst = '1') then
--       curPC <= (others => '0');
--     elsif(iFetchCtrl.newPc = '1') then
--       curPc <= iFetchCtrl.pc;
--     elsif(iFetchCtrl.noOp = '0') then
--       curPc <= std_logic_vector(unsigned(curPc) + 1);
--     end if;
--   end if;
-- end process pcPro;

-- newPcRegPro : process (iClk) is
-- begin  -- process newPcRegPro
--   if iClk'event and iClk = '1' then   -- rising clock edge
--     newPci1 <= iFetchCtrl.newPc;
--   end if;
-- end process newPcRegPro;

-- instrOutPro : process (all) is
-- begin  -- process instrOutPro
--   if(newPci1 = '1') then
--     oInstr <= (others => '0');
--   else
--     oInstr <= instruction;
--   end if;
-- end process instrOutPro;
