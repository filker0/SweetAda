-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ fatfs.ads                                                                                                 --
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
with Bits;
with BlockDevices;
with IDE;

package FATFS
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
   use BlockDevices;

   ----------------------------------------------------------------------------
   -- low-level filesystem types
   ----------------------------------------------------------------------------

   type FAT_Type is (FATNONE, FAT16, FAT32);
   type NFATs_Type is new Unsigned_8;                                    -- # of FAT tables
   type Cluster_Type is new Sector_Type;                                 -- cluster #
   type Sector_Array is array (NFATs_Type range <>) of Sector_Type;

   ----------------------------------------------------------------------------
   -- FAT bootrecord
   ----------------------------------------------------------------------------

   type Bootrecord_Type is record
      Jump_Opcode                  : Byte_Array (0 .. 2);   -- 0x000 0 .. 2    : jump to bootstrap
      OEM_Name                     : String (1 .. 8);       -- 0x003 3 .. 10   : OEM name/version (e.g. "MSDOS5.0")
      -- BPB
      Bytes_Per_Sector             : Unsigned_16;           -- 0x00B 11 .. 12  : bytes per sector (normally 512)
      Sectors_Per_Cluster          : Unsigned_8;            -- 0x00D 13        : 1, 2, 3, 8, 16, 32, 64, 128
      Reserved_Sectors             : Unsigned_16;           -- 0x00E 14 .. 15  : FAT16 = 1, FAT32 = 32
      NFATs                        : Unsigned_8;            -- 0x010 16        : 2
      Root_Directory_Entries       : Unsigned_16;           -- 0x011 17 .. 18  : FAT16 = 512 (recommended), FAT32 = 0
      Total_Sectors_in_FS          : Unsigned_16;           -- 0x013 19 .. 20  : 2880 when not FAT32 and < 32 MiB
      Media_Descriptor             : Unsigned_8;            -- 0x015 21        : F0 = 1.44 MiB floppy, F8 = HD
      Sectors_Per_FAT              : Unsigned_16;           -- 0x016 22 .. 23  : 9, FAT32 = 0
      -- DOS 3.31 BPB
      Sectors_Per_Track            : Unsigned_16;           -- 0x018 24 .. 25  : 12
      Disk_Heads                   : Unsigned_16;           -- 0x01A 26 .. 27  : 2 for double sided floppy disk
      Hidden_Sectors_32            : Unsigned_32;           -- 0x01C 28 .. 31  : FAT32
      Total_Sectors_32             : Unsigned_32;           -- 0x020 32 .. 35  : FAT32
      -- FAT32 Extended BPB
      Sectors_Per_FAT_32           : Unsigned_32;           -- 0x024 36 .. 39  : FAT32
      Mirror_Flags                 : Unsigned_16;           -- 0x028 40 .. 41  : FAT32
      FS_Version_Major             : Unsigned_8;            -- 0x02A 42        : FAT32
      FS_Version_Minor             : Unsigned_8;            -- 0x02B 43        : FAT32
      Root_Directory_First_Cluster : Unsigned_32;           -- 0x02C 44 .. 47  : FAT32
      FS_Info_Sector               : Unsigned_16;           -- 0x030 48 .. 49  : FAT32
      Backup_Boot_Sector           : Unsigned_16;           -- 0x032 50 .. 51  : FAT32
      Reserved                     : Byte_Array (0 .. 11);  -- 0x034 52 .. 63  : FAT32
      Bootstrap_Code               : Byte_Array (0 .. 445); -- 0x040 64 .. 509 : bootstrap code
      Signature                    : Unsigned_16;           -- 0x1FE 510 .. 511: AA 55
   end record
      with Alignment => 8,
           Size      => 512 * Storage_Unit;
   for Bootrecord_Type use record
      Jump_Opcode                  at   0 range 0 .. 23;
      OEM_Name                     at   3 range 0 .. 63;
      -- BPB
      Bytes_Per_Sector             at  11 range 0 .. 15;
      Sectors_Per_Cluster          at  13 range 0 ..  7;
      Reserved_Sectors             at  14 range 0 .. 15;
      NFATs                        at  16 range 0 ..  7;
      Root_Directory_Entries       at  17 range 0 .. 15;
      Total_Sectors_in_FS          at  19 range 0 .. 15;
      Media_Descriptor             at  21 range 0 ..  7;
      Sectors_Per_FAT              at  22 range 0 .. 15;
      -- DOS 3.31 BPB
      Sectors_Per_Track            at  24 range 0 .. 15;
      Disk_Heads                   at  26 range 0 .. 15;
      Hidden_Sectors_32            at  28 range 0 .. 31;
      Total_Sectors_32             at  32 range 0 .. 31;
      -- FAT32 Extended BPB
      Sectors_Per_FAT_32           at  36 range 0 .. 31;
      Mirror_Flags                 at  40 range 0 .. 15;
      FS_Version_Major             at  42 range 0 ..  7;
      FS_Version_Minor             at  43 range 0 ..  7;
      Root_Directory_First_Cluster at  44 range 0 .. 31;
      FS_Info_Sector               at  48 range 0 .. 15;
      Backup_Boot_Sector           at  50 range 0 .. 15;
      Reserved                     at  52 range 0 .. 12 * 8 - 1;
      Bootstrap_Code               at  64 range 0 .. 446 * 8 - 1;
      Signature                    at 510 range 0 .. 15;
   end record;

   ----------------------------------------------------------------------------
   -- high-level filesystem types
   ----------------------------------------------------------------------------

   type Second_Type is mod 2**5; -- Seconds/2
   type Minute_Type is mod 2**6; -- Minutes
   type Hour_Type is mod 2**5;   -- Hours
   type Day_Type is mod 2**5;    -- Day
   type Month_Type is mod 2**4;  -- Month
   type Year_Type is mod 2**7;   -- Year (minus 1980)

   type HMS_Type is record
      Second : Second_Type;
      Minute : Minute_Type;
      Hour   : Hour_Type;
   end record
      with Bit_Order => Low_Order_First,
           Size      => 2 * Storage_Unit;
   for HMS_Type use record
      Second at 0 range 0 .. 4;
      Minute at 0 range 5 .. 10;
      Hour   at 0 range 11 .. 15;
   end record;

   type YMD_Type is record
      Day   : Day_Type;
      Month : Month_Type;
      Year  : Year_Type;
   end record
      with Bit_Order => Low_Order_First,
           Size      => 2 * Storage_Unit;
   for YMD_Type use record
      Day   at 0 range 0 .. 4;
      Month at 0 range 5 .. 8;
      Year  at 0 range 9 .. 15;
   end record;

   type Time_Type is record
      Year   : Year_Type;
      Month  : Month_Type;
      Day    : Day_Type;
      Hour   : Hour_Type;
      Minute : Minute_Type;
      Second : Second_Type;
   end record;

   type File_Attributes_Type is record
      Read_Only    : Boolean;
      Hidden_File  : Boolean;
      System_File  : Boolean;
      Volume_Name  : Boolean;
      Subdirectory : Boolean;
      Archive      : Boolean;
      Reserved1    : Boolean;
      Reserved2    : Boolean;
   end record
      with Bit_Order => Low_Order_First,
           Size      => 1 * Storage_Unit;
   for File_Attributes_Type use record
      Read_Only    at 0 range 0 .. 0;
      Hidden_File  at 0 range 1 .. 1;
      System_File  at 0 range 2 .. 2;
      Volume_Name  at 0 range 3 .. 3;
      Subdirectory at 0 range 4 .. 4;
      Archive      at 0 range 5 .. 5;
      Reserved1    at 0 range 6 .. 6;
      Reserved2    at 0 range 7 .. 7;
   end record;

   DIRECTORY_ENTRY_SIZE : constant := 32;
   type Directory_Entry_Type is record
      File_Name        : String (1 .. 8);
      Extension        : String (1 .. 3);
      File_Attributes  : File_Attributes_Type;
      Reserved         : Unsigned_8;           -- WinNT reserved
      Ctime_Hundredths : Unsigned_8;           -- time creation 1/100 s
      Ctime_HMS        : HMS_Type;             -- time creation HMS
      Ctime_YMD        : YMD_Type;             -- time creation YMD
      Atime_YMD        : YMD_Type;             -- time access YMD
      Cluster_H        : Unsigned_16;          -- FAT32 only
      Wtime_HMS        : HMS_Type;             -- time write HMS
      Wtime_YMD        : YMD_Type;             -- time write YMD
      Cluster_1st      : Unsigned_16;
      Size             : Unsigned_32;
   end record
      with Size => DIRECTORY_ENTRY_SIZE * Storage_Unit;
   for Directory_Entry_Type use record
      File_Name        at  0 range 0 .. 63;
      Extension        at  8 range 0 .. 23;
      File_Attributes  at 11 range 0 ..  7;
      Reserved         at 12 range 0 ..  7;
      Ctime_Hundredths at 13 range 0 ..  7;
      Ctime_HMS        at 14 range 0 .. 15;
      Ctime_YMD        at 16 range 0 .. 15;
      Atime_YMD        at 18 range 0 .. 15;
      Cluster_H        at 20 range 0 .. 15;
      Wtime_HMS        at 22 range 0 .. 15;
      Wtime_YMD        at 24 range 0 .. 15;
      Cluster_1st      at 26 range 0 .. 15;
      Size             at 28 range 0 .. 31;
   end record;

   type Directory_Entry_Array is array (Unsigned_16 range <>) of Directory_Entry_Type
      with Component_Size => DIRECTORY_ENTRY_SIZE * Storage_Unit;

   -- Cluster Control Block
   type CCB_Type is record
      Start_Sector    : Sector_Type;  -- rewind to this sector
      Previous_Sector : Sector_Type;  -- last sector read/written (else 0)
      First_Cluster   : Cluster_Type; -- or rewind to this cluster if >= 2
      Current_Sector  : Sector_Type;  -- current sector position
      Sector_Count    : Unsigned_16;  -- how many sectors until end of cluster
      Cluster         : Cluster_Type; -- current cluster or zero if no more
      IO_Bytes        : Unsigned_32;  -- bytes read or written
   end record;

   type DCB_Type is private;
   type FCB_Type is private;
   type TFCB_Type is private;
   type WCB_Type is limited private;
   type TWCB_Type is limited private;

   MAGIC_DIR : constant := 95; -- magic value for directory
   MAGIC_FCB : constant := 98; -- magic value for physical file read
   MAGIC_WCB : constant := 97; -- magic value for physical file write

   -- IDE block device
   type IDE_Descriptor_Ptr is access all IDE.Descriptor_Type;

   ----------------------------------------------------------------------------
   -- Descriptor
   ----------------------------------------------------------------------------
   type Descriptor_Type is record
      Device                 : IDE_Descriptor_Ptr;    -- IDE descriptor
      FAT_Is_Open            : Boolean := False;      -- filesystem is open and ready
      FAT_Style              : FAT_Type := FATNONE;   -- filesystem type
      Sector_Size            : Unsigned_16;           -- sector size
      Sector_Start           : Sector_Type;           -- partition start (hidden sectors)
      Sectors_Per_FAT        : Unsigned_32;           -- sectors per FAT
      Root_Directory_Cluster : Cluster_Type;          -- first cluster for root directory
      Root_Directory_Start   : Sector_Type;           -- where the root directory starts
      NFATs                  : NFATs_Type;            -- # of FATs
      FAT_Start              : Sector_Array (1 .. 4); -- maximum 4 FATs
      FAT_Index              : NFATs_Type;            -- which FAT to use
      Root_Directory_Entries : Unsigned_16;           -- bootrecord Root_Directory_Entries
      Cluster_Start          : Sector_Type;           -- where data clusters start
      Sectors_Per_Cluster    : Unsigned_16;           -- sectors per cluster
      Next_Writable_Cluster  : Cluster_Type;          -- next writable cluster
      Search_Cluster         : Cluster_Type;          -- first cluster to search for free space
      FS_Time                : Time_Type;             -- filesystem date/time (for writes/changes)
   end record;

   ----------------------------------------------------------------------------
   -- utilities API
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Is_Separator
   ----------------------------------------------------------------------------
   -- Return True if C is a pathname separator.
   ----------------------------------------------------------------------------
   function Is_Separator
      (C : in Character)
      return Boolean
      with Inline => True;

   ----------------------------------------------------------------------------
   -- Time_Get
   ----------------------------------------------------------------------------
   procedure Time_Get
      (D : in     Descriptor_Type;
       T :    out Time_Type)
      with Inline => True;

   ----------------------------------------------------------------------------
   -- Time_Set
   ----------------------------------------------------------------------------
   procedure Time_Set
      (D : in out Descriptor_Type;
       T : in     Time_Type)
      with Inline => True;

   ----------------------------------------------------------------------------
   -- Physical_Sector
   ----------------------------------------------------------------------------
   -- Compute a physical sector number, starting from a logical one.
   ----------------------------------------------------------------------------
   function Physical_Sector
      (D      : in Descriptor_Type;
       Sector : in Sector_Type)
      return Sector_Type
      with Inline => True;

   ----------------------------------------------------------------------------
   -- Is_End
   ----------------------------------------------------------------------------
   -- Return True if sector points past end of current FAT.
   ----------------------------------------------------------------------------
   function Is_End
      (D : in Descriptor_Type;
       S : in Sector_Type)
      return Boolean
      with Inline => True;

   ----------------------------------------------------------------------------
   -- To_Table_Sector
   ----------------------------------------------------------------------------
   -- Return the table entry sector # based upon cluster #.
   ----------------------------------------------------------------------------
   function To_Table_Sector
      (D : in Descriptor_Type;
       C : in Cluster_Type)
      return Sector_Type
      with Inline => True;

   ----------------------------------------------------------------------------
   -- Entry_Index
   ----------------------------------------------------------------------------
   -- Return the FAT entry index within a sector.
   ----------------------------------------------------------------------------
   function Entry_Index
      (F : in FAT_Type;
       C : in Cluster_Type)
      return Natural
      with Inline => True;

   ----------------------------------------------------------------------------
   -- Entry_Get
   ----------------------------------------------------------------------------
   -- Return a FAT entry based upon cluster #.
   ----------------------------------------------------------------------------
   function Entry_Get
      (D : in Descriptor_Type;
       B : in Block_Type;
       C : in Cluster_Type)
      return Cluster_Type
      with Inline => True;

   ----------------------------------------------------------------------------
   -- Entry_Update
   ----------------------------------------------------------------------------
   -- Update a FAT entry based upon cluster #.
   ----------------------------------------------------------------------------
   procedure Entry_Update
      (D     : in     Descriptor_Type;
       B     : in out Block_Type;
       Index : in     Cluster_Type;
       C     : in     Cluster_Type);

   ----------------------------------------------------------------------------
   -- Update
   ----------------------------------------------------------------------------
   -- Update a sector in all FATs.
   ----------------------------------------------------------------------------
   procedure Update
      (D       : in     Descriptor_Type;
       S       : in     Sector_Type;
       B       : in     Block_Type;
       Success :    out Boolean);

   ----------------------------------------------------------------------------
   -- Open/Close filesystem API
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Open
   ----------------------------------------------------------------------------
   -- Open a FAT filesystem.
   ----------------------------------------------------------------------------
   procedure Open
      (D               : in out Descriptor_Type;
       Partition_Start : in     Sector_Type;
       Success         :    out Boolean);

   ----------------------------------------------------------------------------
   -- Close
   ----------------------------------------------------------------------------
   -- Close a FAT filesystem.
   ----------------------------------------------------------------------------
   procedure Close
      (D : in out Descriptor_Type);

private

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                              Private part                              --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   -- Directory Control Block
   type DCB_Type is record
      CCB               : CCB_Type;    -- Cluster Control Block
      Current_Index     : Unsigned_16; -- directory entry index
      Directory_Entries : Unsigned_16; -- how many directory entries in this block
      Magic             : Unsigned_8;  -- Magic_Dir
   end record;

   -- File Control Block (raw read)
   type FCB_Type is record
      CCB   : CCB_Type;    -- Cluster Control Block
      Size  : Unsigned_32; -- file size in bytes
      Magic : Unsigned_8;  -- Magic_File
   end record;

   -- Write Control Block
   type WCB_Type is limited record
      CCB              : CCB_Type;    -- Cluster Control Block
      Directory_Sector : Sector_Type; -- sector containing directory entry
      Directory_Index  : Unsigned_16; -- directory entry index (to update later)
      Last_Sector      : Unsigned_16; -- last write/rewrite count, for File_Close
      Magic            : Unsigned_8;  -- Magic_WCB
   end record;

   -- Text File Control Block (text read)
   type TFCB_Type is record
      FCB         : FCB_Type;    -- underlying physical file
      Byte_Offset : Unsigned_16; -- byte offset within the current sector
   end record;

   -- Text Write Control Block
   type TWCB_Type is limited record
      WCB         : WCB_Type;    -- underlying physical file
      Byte_Offset : Unsigned_16; -- byte offset within current sector
   end record;

end FATFS;
