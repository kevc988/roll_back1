Function GET-DISKPARTINFO() 
{ 
   
     
    new-item -Name listdisk.txt -Itemtype file -force | out-null 
    add-content -path listdisk.txt "list disk" 
    $listdisk=(diskpart /s listdisk.txt)  
     
    $totaldisk=$listdisk.count-9
    $myArray = New-Object System.Collections.ArrayList
     
  
    for ($d=0;$d -lt $totaldisk+1;$d++) 
    { 
     
        $size=$listdisk[8+$d].substring(25,9).replace(" ","") 
        $diskid=$listdisk[8+$d].substring(7,5).trim()
     
        new-item -Name detail.txt -ItemType file -force | out-null 
        add-content -Path detail.txt "select disk $diskid" 
        add-content -Path detail.txt "detail disk" 
         
        # Capture the output from Diskpart for the Detail 
         
        $Detail=(diskpart /s detail.txt) 
         
        # Parse the data for the partition 
         
        $Model=$detail[8] 
        $type=$detail[9].substring(9) 
        $DriveLetter=$detail[-1].substring(15,1) 
         
        # Grab the partition sizing data 
         
        $length=$size.length 
        $multiplier=$size.substring($length-2,2) 
        $intsize=$size.substring(0,$length-2) 
         
        
        # Calculate the size of the Disk or Partition 
        #$disktotal=([convert]::ToInt16($intsize,10))*$mult


        #Check if the devie is USB or not
        if($type -ceq "USB"){# -And $size -lt 10000MB){
           $myArray += $diskid
        }

     
    }
    return $myArray
}


Function DISKPART_UNMOUNT_SCRIPT() 
{ 
    ADD-CONTENT -Path bootdown.txt -Value "SELECT DISK $DiskNum"
    ADD-CONTENT -Path bootdown.txt -Value "REMOVE ALL DISMOUNT"
}

Function DISKPART_MOUNT_SCRIPT() 
{ 
    ADD-CONTENT -Path bootemup.txt -Value "SELECT DISK $DiskNum"
    ADD-CONTENT -Path bootemup.txt -Value "CLEAN" 
    ADD-CONTENT -Path bootemup.txt -Value "CREATE PARTITION PRIMARY" 
    ADD-CONTENT -Path bootemup.txt -Value "FORMAT FS=FAT32 QUICK" 
    ADD-CONTENT -Path bootemup.txt -Value "ASSIGN LETTER=$DiskLet" 
    ADD-CONTENT -Path bootemup.txt -value "ACTIVE" 
}

Function INVOKE-USBBOOT() 
{  
    $info=GET-DISKPARTINFO
    $drives = @("Q","R","S","T","U")
    $drives = $drives[1..($drives.Length-(5-$info.length))]
    
	New-Item -Path bootdown.txt -ItemType file -force | OUT-NULL
    for($d=0;$d -lt $drives.length;$d++ ){
        $DiskNum=$info[$d]
        $DiskLet=$drives[$d]
        New-Item -Path bootemup.txt -ItemType file -force | OUT-NULL
        DISKPART_MOUNT_SCRIPT
    	DISKPART /S bootemup.txt
    	COPY_FILES
    	DISKPART_UNMOUNT_SCRIPT
    	DISKPART /S bootdown.txt
    }

 
}

FUNCTION COPY_FILES()
{
    
    #$content = [IO.File]::ReadAllText("scripts/path.txt")
    $dest = $DiskLet
    robocopy "resources/$($content)" "$($dest):"   
    
  

}
FUNCTION PREP(){




pwd


}
PREP
INVOKE-USBBOOT
echo "PROCESS HAS COMPLETED,THANK YOU"
