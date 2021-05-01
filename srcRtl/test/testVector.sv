//-------------------------------------------------------------------------------
// Title      : testVector class
// Project    :
// -----------------------------------------------------------------------------
// File       : testVector.sv
// Author     : osmant -> otutaysalgir@gmail.com
// Company    :
// Created    : 02.05.2021
// Platform   :
//-----------------------------------------------------------------------------
// Description: testVector read and write
//-----------------------------------------------------------------------------
// Copyright (c) 2021
//-----------------------------------------------------------------------------
// Revisions  :
// Date        Version  Author  Description
// 02.05.2021  1.0      osmant  Created
//-----------------------------------------------------------------------------
class testVector;
   int fd;

   function new (string fileName);
      $display("FileName %s",fileName);
      fd = $fopen(fileName,"r");
      if(fd == 0)
	begin
	   $display("ERROR: FILE CANNOT BE OPENED");
	   $finish();
	end
      else
	begin
	   $display("File opened as normal");
	end
   endfunction // new

   function logic [31:0] getData();
      logic [31:0] data = 32'hdeadbeaf;
      int	   status;
      status = $fscanf(fd,"%h",data);

      if(!$feof(fd))
	return data;
      else
	begin

	   $error("ERROR: NO DATA READ %h time %t \n",data,$time());
	   $finish();

	end
      return data;

   endfunction // getData

/* -----\/----- EXCLUDED -----\/-----
   function ret_type logData(args);

   endfunction
 -----/\----- EXCLUDED -----/\----- */


endclass
