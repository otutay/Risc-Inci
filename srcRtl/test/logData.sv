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
class logData;
   int fid;

     function new (string fileName);
	fid = $fopen(fileName,"w");
	$fwrite(fid,"file -> %s opened at time %t",fileName,$time);
     endfunction // new

     function log (string Name,)

endclass
