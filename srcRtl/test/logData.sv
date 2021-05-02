//-------------------------------------------------------------------------------
// Title      : logData class
// Project    :
// -----------------------------------------------------------------------------
// File       : logData.sv
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 02.05.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description: log simulation data class
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 02.05.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------
import corePckg::*;

class logData;
   int fid;

   function new (string fileName);
      fid = $fopen(fileName,"w");
      $fwrite(fid,"file -> %s opened at time %t ns \n",fileName,$time);
   endfunction // new

   function addLog(string name,logic [cXLEN-1:0] inst);
      $fwrite(fid,"%s,inst -> %h,  time-> %t ns \n",name, inst, $time);
   endfunction



endclass
