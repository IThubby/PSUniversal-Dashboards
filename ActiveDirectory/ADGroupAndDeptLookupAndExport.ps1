$pages = @()

#####################################
# AD Group Lookup
#####################################
$pages += New-udpage -name 'AD Group Lookup & Export' -HeaderColor 'black' -HeaderBackgroundColor 'LightBlue' -content {
    $groups = (get-adgroup -filter * | Select-Object -expandproperty samaccountname)

    New-UDAutocomplete  -Options @($groups | Sort-Object) -label "í´Ž Search Groups" -id "GroupSelect" -variant outlined
    New-UDCheckbox -Id 'MailCheck' -Label 'í³§ Include Email Addresses? (Slower on larger groups)'
    New-UDButton -Text 'í±¥ Show Users' -OnClick {
        Sync-UDElement -Id 'GroupDisplay'
        Sync-UDElement -Id 'MailCheck'
    }
    


    New-UDDynamic -id 'GroupDisplay' -Content {
       
        $ADGroup = ((Get-UDElement -id 'GroupSelect').value)
        $ADGroupCheck = $(try { get-adgroup $ADGroup} catch { $null })
        $Mailcheck = ((Get-UDElement -Id 'MailCheck').checked)
        
        if ($ADGroupcheck -ne $null) {
            
            $GroupPath = (get-adgroup -properties canonicalname $ADGroup).canonicalname
            New-UDHtml -markup "<br>"
            New-UDCard -Title "Group Info - Located: $GroupPath"  -Content {
                New-UDIcon -Icon 'Address_Book' -Size '5x' -Border
                $Columns = @(
                    New-UDTableColumn -property samaccountname -title "Username" -includeinsearch -IncludeInExport
                    New-UDTableColumn -property name -title "Name" -includeinsearch -IncludeInExport
                    New-UDTableColumn -property Email -title "Email" -IncludeInExport
                )
                $data = if ($mailcheck -eq $true) {
                    get-adgroupmember $ADGroup | sort samaccountname | select  samaccountname, name, @{n = "Email"; e = { (get-aduser $_ -properties mail | select -expandproperty mail) } } 
                } else {
                    get-adgroupmember $ADGroup | sort samaccountname | select  samaccountname, name                
                }
            
                New-UDTable -data $data -columns $columns -title "$ADGroup Group Members" -showsort -showsearch -dense -export -paging -pagesize 25
            } -style @{backgroundColor = 'DarkSeaGreen' }
        } else {
                New-UDPaper -Elevation 3 -Content {
                    New-UDHtml -markup "<br>"
                    New-UDIcon -Icon "arrow_circle_up" -size '2x'
                    New-UDTypography -text "Please choose a group above"
                } -style @{backgroundColor = 'lightblue' }
            }
        }
    
    }


#####################################
# Department Lookup
#####################################
    $pages += New-udpage -name 'AD Department Lookup & Export' -content {
        $depts = (get-aduser -filter * -properties department | sort department | select -expandproperty department)
        $depts = ($depts).toUpper()
        $uDepts = ($depts | get-unique)
    
        New-UDAutocomplete  -Options @($uDepts | Sort-Object) -label "í´Ž Search Departments" -id "DeptSelect" -variant outlined
        New-UDCheckbox -Id 'MailCheck' -Label 'Include Email Addresses? (Slower on larger groups)'
        New-UDButton -Text 'Show Users' -OnClick {
            Sync-UDElement -Id 'DeptDisplay'
            Sync-UDElement -Id 'MailCheck'
        }
        
    
    
        New-UDDynamic -id 'DeptDisplay' -Content {
           
            $ADDept = ((Get-UDElement -id 'DeptSelect').value)
            $ADDeptCheck = $(try { Get-ADUser -filter {department -eq $ADDept}} catch { $null })
            $Mailcheck = ((Get-UDElement -Id 'MailCheck').checked)
            if ($ADDeptCheck -ne $null) {
                                
                New-UDHtml -markup "<br>"
                New-UDCard -Title 'Department Info'  -Content {
                    New-UDIcon -Icon 'Address_Book' -Size '5x' -Border
                    $Columns = @(
                        New-UDTableColumn -property samaccountname -title "Username" -includeinsearch -IncludeInExport
                        New-UDTableColumn -property name -title "Name" -includeinsearch -IncludeInExport
                        New-UDTableColumn -property title -title "Title" -includeinsearch -IncludeInExport
                        New-UDTableColumn -property enabled -title "Active" -includeinsearch -IncludeInExport
                        New-UDTableColumn -property mail -title "Email" -IncludeInExport
                    )
                    $data = if ($mailcheck -eq $true) {
                        get-ADUser -filter * -properties department,title,mail | ? department -eq $ADDept | sort samaccountname | select  samaccountname, name, title, enabled, mail
                    }
                    else {
                        get-ADUser -filter * -properties department,title | ? department -eq $ADDept | sort samaccountname | select  samaccountname, name, title, enabled
                    }
                
                    New-UDTable -data $data -columns $columns -title "$ADDept Department Members" -showsort -showsearch -dense -export -paging -pagesize 25
                } -style @{backgroundColor = 'DarkSeaGreen' }
            } else {
                    New-UDPaper -Elevation 3 -Content {
                        New-UDHtml -markup "<br>"
                        New-UDTypography -text "Please choose a department above!    ãƒ½à¼¼â˜‰ãƒ®â˜‰à¼½ï¾‰"
                    } -style @{backgroundColor = 'lightblue' }
                }
            }
        
        }




    New-UDDashboard -Title 'AD Tools' -pages $pages
