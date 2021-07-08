-------------------------------------------------------------------------------
-- Title      : dataram.vhd
-- Project    :
-------------------------------------------------------------------------------
-- File       : dataRam.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-07-04
-- Last update: 2021-07-08
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
    iClk        : in  std_logic;
    iRst        : in  std_logic;
    iMemOp      : in  tMemOp;
    oRegOp      : out tRegOp;
    -- data 2 load
    iData2Write : in  std_logic_vector(cXLen-1 downto 0);
    iWEn        : in  std_logic
    );

end entity dataRam;
architecture rtl of dataRam is
  signal ramEn      : std_logic                                      := '0';
  signal ramWEn     : std_logic                                      := '0';
  signal ramAddr    : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal ramDataIn  : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal ramDataOut : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal rdAddri1   : std_logic_vector(cRegSelBitW-1 downto 0)       := (others => '0');
  signal dvi1       : std_logic                                      := '0';
  signal data2Write : std_logic_vector(cXLen-1 downto 0)             := (others => '0');
  signal dataWen    : std_logic                                      := '0';
  signal dataAddr   : std_logic_vector(log2(cRamDepth-1)-1 downto 0) := (others => '0');
begin  -- architecture rtl

  oRegOp.addr <= rdAddri1;
  oRegOp.data <= ramDataOut;
  oRegOp.dv   <= dvi1;

  ramCtrlPro : process (all) is
  begin  -- process ramCtrlPro
    ramEn   <= iMemOp.readDv or iMemOp.writeDv;
    ramWEn  <= iMemOp.writeDv;
    ramAddr <= iMemOp.addr;
    case iMemOp.opType is
      when "000" =>
        ramDataIn <= std_logic_vector(resize(signed(iMemOp.data(7 downto 0)), cXLen));
      when "001" =>
        ramDataIn <= std_logic_vector(resize(signed(iMemOp.data(15 downto 0)), cXLen));
      when "010" =>
        ramDataIn <= std_logic_vector(resize(unsigned(iMemOp.data(15 downto 0)), cXLen));
      when others =>
        ramDataIn <= (others => '0');
    end case;
  end process ramCtrlPro;


  destRegPro : process (iClk) is
  begin  -- process destAddrRegPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      rdAddri1 <= iMemOp.rdAddr;
      dvi1     <= iMemOp.readDv and not(iMemOp.writeDv);
    end if;
  end process destRegPro;

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
      iRstB  => '0',
      iEnB   => '1',
      iWEnB  => dataWen,
      iAddrB => dataAddr,
      iDataB => data2Write,
      oDataB => open
      );

-- data 2 load
  data2LoadPro : process (iClk) is
  begin  -- process instr2LoadPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iRst = '1') then
        dataAddr   <= (others => '0');
        dataWen    <= '0';
        data2Write <= (others => '0');
      else
        data2Write <= iData2Write;
        dataWen    <= iWEn;
        if(iWEn = '1') then
          dataAddr <= std_logic_vector(unsigned(dataAddr) + 1);
        end if;
      end if;
    end if;
  end process data2LoadPro;




end architecture rtl;
