-------------------------------------------------------------------------------
-- Title      : fetchWB
-- Project    :
-------------------------------------------------------------------------------
-- File       : fetchWb.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-25
-- Last update: 2021-03-30
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



end architecture rtl;
