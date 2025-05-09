-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ libgcc-ucmpdi2.adb                                                                                        --
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
function UCmpDI2
   (A : GCC.Types.UDI_Type;
    B : GCC.Types.UDI_Type)
   return GCC.Types.SI_Type
   is
   function To_USI_2 is new Ada.Unchecked_Conversion (GCC.Types.UDI_Type, USI_2);
   T_A    : constant USI_2 := To_USI_2 (A);
   T_B    : constant USI_2 := To_USI_2 (B);
   A_HIGH : GCC.Types.USI_Type renames T_A (HI64);
   A_LOW  : GCC.Types.USI_Type renames T_A (LO64);
   B_HIGH : GCC.Types.USI_Type renames T_B (HI64);
   B_LOW  : GCC.Types.USI_Type renames T_B (LO64);
   R      : GCC.Types.SI_Type;
begin
   R := 1;
   if    A_HIGH < B_HIGH then
      R := @ - 1;
   elsif A_HIGH > B_HIGH then
      R := @ + 1;
   else
      if    A_LOW < B_LOW then
         R := @ - 1;
      elsif A_LOW > B_LOW then
         R := @ + 1;
      end if;
   end if;
   return R;
end UCmpDI2;
