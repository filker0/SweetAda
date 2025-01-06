-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ bits-byte_swap_64.adb                                                                                     --
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

separate (Bits)
function Byte_Swap_64
   (Value : in Interfaces.Unsigned_64)
   return Interfaces.Unsigned_64
   is
   function BS64
      (V : Interfaces.Unsigned_64)
      return Interfaces.Unsigned_64
      with Import        => True,
           Convention    => Intrinsic,
           External_Name => "__builtin_bswap64";
begin
   return BS64 (Value);
end Byte_Swap_64;
