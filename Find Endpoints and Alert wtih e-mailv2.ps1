
<#
.Synopsis
   Verson 2 - Azure PowerShell 0.7.1
   This script will produce a list of all open endpoints configured on VMs running in all your Azure subscription
.DESCRIPTION
   This will identify all of the Azure subscriptions that you have access to from the publishing file (get-azuresubscription). 
   We will scan for VMs in all the subscriptions and look for configured Azure endpoints.
   If Endpoing are found - an e-mail will be sent with the details of the VM and it endpoints
   Everytime this sciprt runs it will also create a timestamed text file with what VMs were scan and any configured endpoints.
.INPUTS
   Inputs to this cmdlet - This script is designed to run without user interfaction - you need to edit the variables in the script
.OUTPUTS
   Output from this cmdlet - this will generate text files for every VM scaned
.NOTES
   This script idea came from wanting to prevent portal users from opening endpoints in a subscription that has a company VPN and a configured VNET using private IP adderss
   We want to aduit any endpoints that portal owners may open
   This script is designed to run as a service on a pre-determined schedule
.EXAMPLE #1
   Get-AzureOpenPortAlert
.EXAMPLE #2
   Get-AzureOpenPortAlert
#>

function Get-AzureOpenPortAlert
{

    Begin
    {
        #MODIFY these settings to specifc ones for you
        #Pre set e-mail information
        $sendtoperson = "you@domain.net" #CHANGE to a valid e-mail address
        $sendfromperson = "you@domain.net" #CHANGE to a valid e-mail address
        $sendccperson = "you@domain.net" #CHANGE to a valid e-mail address

        $emailsubject = "You have Endpoints configured on Azure VMs!"


        #You must enter an SMTP service that you can use to send e-mails - usually a company SMTP is set up for use, check with your messaging admin for this information
        $mailrelayHUB = "smpt.domain.net" #CHANGE to a valid SMTP address
        
        #Capture the users current subscription
        $currentdefaulsub = Get-AzureSubscription -Default
        $currentsubname = $currentdefaulsub.SubscriptionName
        
        #Get Date & Time - Modify formate as you wish - get-help get-date for more
        $daterun = get-date -UFormat "%Y%b%a%H%M%S"
      
        #Set the output loction for the text files - the person or service running the scipt must have permisions to write to this location
        #Set your path between the double quotes - you may use UNC paths to a share on your network
        $placetoputfile = "C:\...." #CHANGE to your path of choice
                         
        #Counter objects for number of subcriptions
        $count = 0
        
        #Gets the subscription listed - NOTE any modifications to the name or adding subscritpison to your account
        # you will need to re-import the publshing file for this scirpt to know about them - use the Get-AzureSubscription cmdlet to see your subscriptions
        $allsubs = Get-AzureSubscription
    }
    Process
    {
            #Will run the following for every subscrtipion found       
            foreach ($allsub in $allsubs)
            {
                #sets a subscription to use for this pass
                Select-AzureSubscription -Default $allsubs.subscriptionname[$count]

                    #Gets all the Services in the subscription
                    $allservices =  Get-AzureService

                    #Will do for every VM found in Get-AzureService
                    foreach ($allservices in $allservices)
                        {
                            #Captures the active server name, active subscription and name of the unique file to write findings into
                            $ServerOnList = $allservices.ServiceName
                            $actSubScription = $allsubs.SubscriptionName[$count]
                            $filedataloc = $placetoputfile+$daterun+$allservices.ServiceName+".txt"

                            #This line will get VM and write some basic information to the output file - This is a list of VMs that were checked for Endpoints duing this scan time
                            Get-AzureVM -ServiceName $allservices.servicename | select name, dnsname, ipaddress, powerstate | ConvertTo-Csv |Out-File -FilePath $filedataloc

                            #This secion will run only if an EndPoint is found on a VM
                            #If Endpoint if found it will write contents to the text file and send the file via e-mail (to the peopel listed above)
                        
                            if (Get-AzureVM -ServiceName $allservices.ServiceName | Get-AzureEndpoint)
                                { 
                                    #Writes the open ports to a text file and saves it to the folder location given above
                                    Get-AzureVM -ServiceName $allservices.servicename | Get-AzureEndpoint | select localport, name, port, protocol, Vip |ConvertTo-Csv | Out-File -FilePath $filedataloc -Append

                                    #Will send an e-mail with the file that lists the open ports.
                                    Send-MailMessage -To $sendtoperson -Cc $sendccperson -From $sendfromperson -Subject $emailsubject -Body "Ther server $ServerOnList in Subscription $actSubScription has Endpoints configured. " -Attachments $filedataloc -BodyAsHtml -Priority High -SmtpServer $mailrelayHUB
                                }
                        }
                # Increments the subscription count
                $count= $count + 1
             } 
    }
    End
    {
        #Sets the users default subscription back to what it as before the script ran
        Select-AzureSubscription -Default $currentsubname
    }
}


