-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ rtc.adb                                                                                                   --
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

package body RTC
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Local declarations                           --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   procedure Read_Clock
      (T : out TM_Time)
      is
pragma Warnings (Off);
      function To_N is new Ada.Unchecked_Conversion (Bits_1, Natural);
      function To_N is new Ada.Unchecked_Conversion (Bits_2, Natural);
      function To_N is new Ada.Unchecked_Conversion (Bits_3, Natural);
      function To_N is new Ada.Unchecked_Conversion (Bits_4, Natural);
pragma Warnings (On);
   begin
      T.Sec   := To_N (MSM6242B.S10.DATA) * 10 + To_N (MSM6242B.S1.DATA);
      T.Min   := To_N (MSM6242B.MI10.DATA) * 10 + To_N (MSM6242B.MI1.DATA);
      T.Hour  := To_N (MSM6242B.H10.H) * 10 + To_N (MSM6242B.H1.DATA);
      T.MDay  := To_N (MSM6242B.D10.D) * 10 + To_N (MSM6242B.D1.DATA);
      T.Mon   := To_N (MSM6242B.MO10.M) * 10 + To_N (MSM6242B.MO1.DATA);
      T.Year  := To_N (MSM6242B.Y10.DATA) * 10 + To_N (MSM6242B.Y1.DATA);
      T.Year  := @ + (if @ < 70 then 100 else 0);
      T.WDay  := To_N (MSM6242B.W.DATA);
      T.YDay  := 0;
      T.IsDST := 0;
   end Read_Clock;

end RTC;
