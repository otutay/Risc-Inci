-------------------------------------------------------------------------------
-- Title      : alu.vhd
-- Project    :
-------------------------------------------------------------------------------
-- File       : alu.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-22
-- Last update: 2021-03-23
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: alu code for risc inci
-------------------------------------------------------------------------------
-- Copyright (c) 2021
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-03-22  1.0      otutay  Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.corePckg.all;
entity alu is

  port (
    iClk           : in  std_logic;
    iRst           : in  std_logic;
    iDecoded       : in  tDecoded;
    iDecodedMem    : in  tDecodedMem;
    iDecodedReg    : in  tDecodedReg;
    iDecodedBranch : in  tDecodedBranch;
    oMemWB         : out tMemOp;
    oRegWB         : out tRegOp;
    oBranchWB      : out tBranchOp
    );


end entity alu;

architecture rtl of alu is
  signal memOut : tMemOp := cMemOp;
begin  -- architecture rtl

  -- load store op

  loadStorePro : process (iClk) is
  begin  -- process loadStorePro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iDecodedMem.dv and iDecodedMem.load) then
        memOut.addr   <= signed(iDecoded.rs1) + signed(iDecoded.imm);
        memOut.rdAddr <= iDecoded.rdAddr;
        memOut.opType <= iDecoded.funct3;
        memOut.readDv <= '1';
      elsif(iDecodedMem.dv and iDecodedMem.store) then
        memOut.addr    <= signed(iDecoded.rs1) + signed(iDecoded.imm);
        memOut.data    <= iDecoded.rs2Data;
        memOut.opType  <= iDecoded.funct3;
        memOut.writeDv <= '1';
      else
        memOut <= cMemOp;
      end if;
    end if;
  end process loadStorePro;


end architecture rtl;
