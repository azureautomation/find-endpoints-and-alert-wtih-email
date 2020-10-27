Find Endpoints and Alert wtih e-mail
====================================

            

**Update 2 for PowerShell 0.7.1**


 This script will search all your Azure subscriptions, identiry VMs and look for configured Endpoints. If Endpoints are found on VM it will write to a local file as well as send an e-mail with the server name and endpoint configuration.


 


This script is desiged to be run as a scheduled job and alert whenever end-points are found - we do this to pervent users in the portal from opening server access into a VM running in Azure.


 

 

        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
