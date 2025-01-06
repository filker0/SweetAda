-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ libgcc-subdi3.adb                                                                                         --
-- __DSC__                                                                                                           --
-- __HSH__ e69de29bb2d1d6434b8b29ae775ad8c2e48c5391                                                                  --
-- __HDE__                                                                                                           --
-----------------------------------------------------------------------------------------------------------------------
-- Copyright (C) 2020-2025 Gabriele Galeotti                                                                         --
--                                                                                                                   --
-- SweetAda web page: http://sweetada.org                                                                            --
-- contact address: gabriele.galeotti@sweetada.org                                                                   --
-- This work is licensed under the terms of the MIT License.                                                         --
-- Please consult the LICENSE.txt file located in the top-level directory.                                           --
-----------------------------------------------------------------------------------------------------------------------

with Ada.Unchecked_Conversion;

separate (LibGCC)
function SubDI3
   (A1 : GCC_Types.UDI_Type;
    A2 : GCC_Types.UDI_Type)
   return GCC_Types.UDI_Type
   is
   function To_USI_2 is new Ada.Unchecked_Conversion (GCC_Types.UDI_Type, USI_2);
   function To_UDI is new Ada.Unchecked_Conversion (USI_2, GCC_Types.UDI_Type);
   T_A1    : constant USI_2 := To_USI_2 (A1);
   T_A2    : constant USI_2 := To_USI_2 (A2);
   A1_HIGH : GCC_Types.USI_Type renames T_A1 (HI64);
   A1_LOW  : GCC_Types.USI_Type renames T_A1 (LO64);
   A2_HIGH : GCC_Types.USI_Type renames T_A2 (HI64);
   A2_LOW  : GCC_Types.USI_Type renames T_A2 (LO64);
   R       : USI_2;
   R_HIGH  : GCC_Types.USI_Type renames R (HI64);
   R_LOW   : GCC_Types.USI_Type renames R (LO64);
begin
   R_LOW  := A1_LOW  - A2_LOW;
   R_HIGH := A1_HIGH - A2_HIGH;
   -- if the intermediate result is greater than the first addend, this
   -- is an indication of overflow, so a carry bit must be propagated
   if R_LOW > A1_LOW then
      R_HIGH := @ - 1;
   end if;
   return To_UDI (R);
end SubDI3;
