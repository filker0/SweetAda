-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ piix.adb                                                                                                  --
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

package body PIIX
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- Probe
   ----------------------------------------------------------------------------
   function Probe
      (D : PCI.Descriptor_Type)
      return Boolean
      is
      Success       : Boolean;
      Device_Number : PCI.Device_Number_Type with Unreferenced => True;
   begin
      PCI.Cfg_Find_Device_By_Id (
         Descriptor    => D,
         Bus_Number    => PCI.BUS0,
         Vendor_Id     => PCI.VENDOR_ID_INTEL,
         Device_Id     => PCI.DEVICE_ID_PIIX3,
         Device_Number => Device_Number,
         Success       => Success
         );
      return Success;
   end Probe;

   ----------------------------------------------------------------------------
   -- Init
   ----------------------------------------------------------------------------
   procedure Init
      (D : in PCI.Descriptor_Type)
      is
      PIRQC : constant PIRQC_Type := (
         IRQROUTE   => IRQROUTE_RESERVED1,
         IRQROUTEEN => NFalse,
         others     => <>
         );
   begin
      PCI.Cfg_Write (
         Descriptor => D, Bus_Number => PCI.BUS0, Device_Number => 1, Function_Number => 0,
         Register_Number => PIRQRCA,
         Value           => To_U8 (PIRQC)
         );
      PCI.Cfg_Write (
         Descriptor => D, Bus_Number => PCI.BUS0, Device_Number => 1, Function_Number => 0,
         Register_Number => PIRQRCB,
         Value           => To_U8 (PIRQC)
         );
      PCI.Cfg_Write (
         Descriptor => D, Bus_Number => PCI.BUS0, Device_Number => 1, Function_Number => 0,
         Register_Number => PIRQRCC,
         Value           => To_U8 (PIRQC)
         );
      PCI.Cfg_Write (
         Descriptor => D, Bus_Number => PCI.BUS0, Device_Number => 1, Function_Number => 0,
         Register_Number => PIRQRCD,
         Value           => To_U8 (PIRQC)
         );
   end Init;

end PIIX;
