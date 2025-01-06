-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ z8530.ads                                                                                                 --
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

with System;
with Interfaces;
with Definitions;
with Bits;

package Z8530
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                               Public part                              --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   use System;
   use Interfaces;
   use Bits;

   type Channel_Type is (CHANNELA, CHANNELB);

   type Flags_Type is record
      DECstation5000133 : Boolean;
   end record;

   type Port_Read_8_Ptr is access function (Port : Address) return Unsigned_8;
   type Port_Write_8_Ptr is access procedure (Port : in Address; Value : in Unsigned_8);
   type Control_Ports_Type is array (Channel_Type) of Address;
   type Data_Ports_Type is array (Channel_Type) of Address;

   type Descriptor_Type is record
      Base_Address   : Address;
      AB_Address_Bit : Address_Bit_Number;
      CD_Address_Bit : Address_Bit_Number;
      Baud_Clock     : Positive;
      Flags          : Flags_Type;
      Read_8         : Port_Read_8_Ptr;
      Write_8        : Port_Write_8_Ptr;
      Control_Port   : Control_Ports_Type := [Null_Address, Null_Address];
      Data_Port      : Data_Ports_Type    := [Null_Address, Null_Address];
   end record;

   DESCRIPTOR_INVALID : constant Descriptor_Type :=
      (
       Base_Address   => Null_Address,
       AB_Address_Bit => 0,
       CD_Address_Bit => 0,
       Baud_Clock     => 1,
       Flags          => (others => False),
       Read_8         => null,
       Write_8        => null,
       others         => <>
      );

   procedure Baud_Rate_Set
      (Descriptor : in Descriptor_Type;
       Channel    : in Channel_Type;
       Baud_Rate  : in Definitions.Baud_Rate_Type);
   procedure Init
      (Descriptor : in out Descriptor_Type;
       Channel    : in     Channel_Type);
   procedure TX
      (Descriptor : in Descriptor_Type;
       Channel    : in Channel_Type;
       Data       : in Unsigned_8);
   procedure RX
      (Descriptor : in     Descriptor_Type;
       Channel    : in     Channel_Type;
       Data       :    out Unsigned_8);

end Z8530;
