-------------------------------------------------------------------------------
-- Title      : ram
-- Project    :
-------------------------------------------------------------------------------
-- File       : ram.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-25
-- Last update: 2021-07-19
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: ram module for instructions
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

entity ram is

  generic (
    cRamPerformance : string  := "HIGH_PERFORMANCE";
    cRamWidth       : integer := 32;
    cRamDepth       : integer := 1024
    );
  port (
    iClk   : in  std_logic;
    -- a port
    iRstA  : in  std_logic;
    iEnA   : in  std_logic;
    iWEnA  : in  std_logic;
    iAddrA : in  std_logic_vector(log2(cRamDepth-1)-1 downto 0);
    iDataA : in  std_logic_vector(cRamWidth-1 downto 0);
    oDataA : out std_logic_vector(cRamWidth-1 downto 0);
    -- b port
    iRstB  : in  std_logic;
    iEnB   : in  std_logic;
    iWEnB  : in  std_logic;
    iAddrB : in  std_logic_vector(log2(cRamDepth-1)-1 downto 0);
    iDataB : in  std_logic_vector(cRamWidth-1 downto 0);
    oDataB : out std_logic_vector(cRamWidth-1 downto 0)
    );

end entity ram;
architecture rtl of ram is
  type tRamArray is array (0 to cRamDepth-1) of std_logic_vector(cRamWidth-1 downto 0);
  shared variable ram : tRamArray;      -- := (others => (others => '0'));
  signal ramDataA     : std_logic_vector(cRamWidth-1 downto 0) := (others => '0');
  signal ramDataB     : std_logic_vector(cRamWidth-1 downto 0) := (others => '0');
begin  -- architecture rtl
  portAPro : process (iClk) is
  begin  -- process portAPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iEnA = '1') then
        if(iWEnA = '1') then
          ram(to_integer(unsigned(iAddrA))) := iDataA;
        else
          ramDataA <= ram(to_integer(unsigned(iAddrA)));
        end if;
      end if;
    end if;
  end process portAPro;

  portBPro : process (iClk) is
  begin  -- process portAPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iEnB = '1') then
        if(iWEnB = '1') then
          ram(to_integer(unsigned(iAddrB))) := iDataB;
        else
          ramDataB <= ram(to_integer(unsigned(iAddrB)));
        end if;
      end if;
    end if;
  end process portBPro;

  ramGenLowLat : if cRamPerformance = "LOW_LATENCY" generate
    oDataA <= ramDataA;
    oDataB <= ramDataB;
  end generate ramGenLowLat;


  ramGenHighPer : if cRamPerformance = "HIGH_PERFORMANCE" generate

    outDataPro : process (iClk) is
    begin  -- process outDataPro
      if iClk'event and iClk = '1' then  -- rising clock edge
        oDataA <= ramDataA;
        oDataB <= ramDataB;
      end if;
    end process outDataPro;

  end generate ramGenHighPer;

  assert cRamPerformance = "HIGH_PERFORMANCE" or cRamPerformance = "LOW_LATENCY" report "this ram perf not supported" severity failure;

end architecture rtl;
