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
import corePckg::*;

class testVector;
   int fd;
   int disp = 0;


   function new (string fileName);
      $display("FileName %s",fileName);
      fd = $fopen(fileName,"r+");
      if(fd == 0)
	begin
	   $display("\t\t TIME -> %0t, ERROR: FILE CANNOT BE OPENED",$time);
	   $finish();
	end
      else
	begin
	   $display("\t\t TIME -> %0t, File opened as normal",$time);
	end
   endfunction // new

   function logic [cXLEN-1:0] getData();
      logic [cXLEN-1:0] data = 'hdeadbeaf;
      int		status;
      status = $fscanf(fd,"%h",data);

      if(!$feof(fd))
	begin
	   if(disp == 1) begin
	      $display("\t\t TIME ->  %0t, DATA ->  %h \n ",$time,data);
	   end
	   return data;
	end
      else
	begin
	   $error("\t\t TIME -> %0t, ERROR: NO DATA READ %h  \n",$time, data);
	   $finish();
	end
      return data;

   endfunction // getData


   function setData(logic [cXLEN-1:0] data);
      if(disp == 1) begin
	 $display("\t\t %0t ns, data %h formed and written \n",$time, data);
      end
      $fwrite(fd,"%h \n",data);
   endfunction

   function closeFile();
      $fclose(fd);
   endfunction

endclass
