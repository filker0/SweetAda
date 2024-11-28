
with System.Machine_Code;
with Ada.Unchecked_Conversion;
with Interfaces;
with Bits;
with MMIO;
with CPU;
with M68k;
with Amiga;
with RTC;
with BSP;
with PBUF;
with Ethernet;
with A2065;
with IDE;
with BlockDevices;
with MBR;
with FATFS;
with FATFS.Applications;
with Console;
with Time;

package body Application
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Local declarations                           --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   use System.Machine_Code;
   use Interfaces;
   use Bits;
   use MMIO;
   use M68k;
   use Amiga;

   Fatfs_Object : FATFS.Descriptor_Type;

   function Tick_Count_Expired
      (Flash_Count : Unsigned_32;
       Timeout     : Unsigned_32)
      return Boolean;
   procedure Handle_Ethernet;

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- Tick_Count_Expired
   ----------------------------------------------------------------------------
   function Tick_Count_Expired
      (Flash_Count : Unsigned_32;
       Timeout     : Unsigned_32)
      return Boolean
      is
   begin
      return (BSP.Tick_Count - Flash_Count) > Timeout;
   end Tick_Count_Expired;

   ----------------------------------------------------------------------------
   -- Handle_Ethernet
   ----------------------------------------------------------------------------
   procedure Handle_Ethernet
      is
      P       : PBUF.Pbuf_Ptr;
      Success : Boolean;
   begin
      Ethernet.Dequeue (Ethernet.Packet_Queue'Access, P, Success);
      if Success then
         Ethernet.Packet_Handler (P);
         PBUF.Free (P);
      end if;
   end Handle_Ethernet;

   ----------------------------------------------------------------------------
   -- Run
   ----------------------------------------------------------------------------
   procedure Run
      is
   begin
      -------------------------------------------------------------------------
      if False then
         declare
            Ethernet_Descriptor : Ethernet.Descriptor_Type;
         begin
            -- Ethernet module initialization ------------------------------
            Ethernet_Descriptor.Haddress := A2065.A2065_MAC;
            Ethernet_Descriptor.Paddress := [192, 168, 3, 2];
            Ethernet_Descriptor.RX       := null;
            Ethernet_Descriptor.TX       := A2065.Transmit'Access;
            Ethernet.Init (Ethernet_Descriptor);
            -- A2065 initialization ----------------------------------------
            A2065.Init;
         end;
      end if;
      -------------------------------------------------------------------------
      if False then
         declare
            Success   : Boolean;
            Partition : MBR.Partition_Entry_Type;
         begin
            MBR.Read (BSP.IDE_Descriptor'Access, MBR.PARTITION1, Partition, Success);
            if Success then
               Fatfs_Object.Device := BSP.IDE_Descriptor'Access;
               FATFS.Open
                  (Fatfs_Object,
                   BlockDevices.Sector_Type (Partition.LBA_Start),
                   Success);
               if Success then
                  FATFS.Applications.Test (Fatfs_Object);
                  FATFS.Applications.Load_AUTOEXECBAT (Fatfs_Object);
               end if;
            end if;
         end;
      end if;
      -------------------------------------------------------------------------
      if True then
         declare
            -- TC1 : Unsigned_32 := BSP.Tick_Count;
            -- TC2 : Unsigned_32 := BSP.Tick_Count;
            TC3 : Unsigned_32 := BSP.Tick_Count;
            TM  : Time.TM_Time;
         begin
            loop
               -- if Tick_Count_Expired (TC1, 50) then
               --    Handle_Ethernet;
               --    TC1 := BSP.Tick_Count;
               -- end if;
               -- if Tick_Count_Expired (TC2, 300) then
               --    TC2 := BSP.Tick_Count;
               -- end if;
               if Tick_Count_Expired (TC3, 1000) then
                  RTC.Read_Clock (TM);
                  Console.Print (TM.Year + 1_900);
                  Console.Print (TM.Mon, Prefix => "-");
                  Console.Print (TM.MDay, Prefix => "-");
                  Console.Print (TM.Hour, Prefix => " ");
                  Console.Print (TM.Min, Prefix => ":");
                  Console.Print (TM.Sec, Prefix => ":", NL => True);
                  TC3 := BSP.Tick_Count;
               end if;
            end loop;
         end;
      end if;
      -------------------------------------------------------------------------
      loop null; end loop;
      -------------------------------------------------------------------------
   end Run;

end Application;
