-------------------------------------------------------------------------------
-- Title      : ram
-- Project    :
-------------------------------------------------------------------------------
-- File       : ram.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-25
-- Last update: 2021-03-25
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: ram module for instructions
-------------------------------------------------------------------------------
-- Copyright (c) 2021
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-03-25  1.0      otutay	Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.corePckg.all;

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
    oDataA : out std_logic_vector(cRamWidth-1 downto 0);
    -- b port
    iRstB  : in  std_logic;
    iEnB   : in  std_logic;
    iWenB  : in  std_logic;
    iAddrB : in  std_logic_vector(log2(cRamDepth-1)-1 downto 0);
    oDataB : out std_logic_vector(cRamWidth-1 downto 0)
    );

end entity ram;
architecture rtl of ram is

begin  -- architecture rtl



end architecture rtl;
