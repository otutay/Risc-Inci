-------------------------------------------------------------------------------
-- Title      : fetchWB
-- Project    :
-------------------------------------------------------------------------------
-- File       : fetchWb.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-25
-- Last update: 2021-04-01
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: fetch wb stage
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

entity fetchWb is

  port (
    iClk       : in  std_logic;
    iRst       : in  std_logic;
    iMemOp     : in  tMemOp;
    iFetchCtrl : in  iFetchCtrl;
    oCurPc     : out std_logic_vector(cXLen-1 downto 0);
    oInstr     : out std_logic_vector(cXLen-1 downto 0);
    oRegOp     : out tRegOp
    );

end entity fetchWb;

architecture rtl of fetchWb is
  signal LSWen       : std_logic                                      := '0';
  signal LSEn        : std_logic                                      := '0';
  signal LSAddr      : std_logic_vector(log2(cRamDepth-1)-1 downto 0) := (others => '0');
  signal LSStoreData : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal LSLoadData  : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal readDv      : std_logic                                      := '0';
  signal rdAddri1    : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal regOp       : tRegOp                                         := cRegOp;
  signal instruction : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal readAddr    : std_logic_vector(log2(cRamDepth-1)-1 downto 0) := (others => '0');
  signal curPc       : std_logic_vector(cXLen-1 downto 0)             := (others => '0');

begin  -- architecture rtl

  loadStorePro : process (iClk) is
  begin  -- process loadStorePro
    if iClk'event and iClk = '1' then   -- rising clock edge
      LSAddr <= iMemOp.addr;
      LSEn   <= iMemOp.readDv or iMemOp.writeDv;
      LSWen  <= iMemOp.writeDv;
      case (iMemOp.opType) is
        when "000"  => LSStoreData <= std_logic_vector(resize(signed(iMemOp.data(7 downto 0))));
        when "001"  => LSStoreData <= std_logic_vector(resize(signed(iMemOp.data(15 downto 0))))
        when "010"  => LSStoreData <= iMemOp.data(15 downto 0);  -- TODO ERROR
                                                                 -- here
        when others => LSStoreData <= (others => '0');
      end case;
    end if;
  end process loadStorePro;

  ramDataCollectPro : process (iClk) is
  begin  -- process ramDataCollectPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      readDvi1 <= iMemOp.readDv;
      rdAddri1 <= iMemOp.rdAddr;


      regOp.dv   <= readi1;
      regOp.addr <= rdAddri1;
      regOp.data <= LSLoadData;
    end if;
  end process ramDataCollectPro;

  ram_1 : entity work.ram
    generic map (
      cRamPerformance => "LOW_LATENCY",
      cRamWidth       => cXLen,
      cRamDepth       => cRamDepth
      )
    port map (
      iClk   => iClk,
      iRstA  => '0',
      iEnA   => '1',
      iWEnA  => '0',
      iAddrA => readAddr,
      iDataA => (others => '0'),
      oDataA => instruction,
      iRstB  => '0',
      iEnB   => LSEn,
      iWEnB  => LSWen,
      iAddrB => LSAddr,
      iDataB => LSStoreData,
      oDataB => LSLoadData
      );

  pcCounterPro : process (iClk) is
  begin  -- process pcCounterPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iFetchCtrl.noOp = '1') then
        curPc <= curPc;
      elsif(iFetchCtrl.newPc = '1') then
        curPc <= iFetchCtrl.pc;
      else
        curPc <= std_logic_vector(unsigned(curPc) + 4);
      end if;
    end if;
  end process pcCounterPro;

  process (all) is                      -- begenmedim
  begin  -- process
    readAddr <= curPc(log2(cRamDepth-1)-1 downto 0);
    if(iFetchCtrl.newPc = '1') then
      oInstr <= instruction;
      oCurPc <= iFetchCtrl.pc
    else
      oInstr <= (others => '0');
      oCurPc <= std_logic_vector(unsigned(curPc)-4);
    end if;
  end process;

end architecture rtl;
