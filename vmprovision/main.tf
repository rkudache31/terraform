data "azurerm_network_interface" "nic" {
name=var.nic_name
resource_group_name= var.resource_group_name
}
resource "azurerm_linux_virtual_machine" "linux_vm" {
name    = var.name
resource_group_name= var.resource_group_name
location = var.location
size=var.size
admin_username=var.admin_username
admin_password=var.admin_password
network_interface_ids=[data.azurerm_network_interface.nic.id]
disable_password_authentication="false"
os_disk {
caching = var.caching
storage_account_type=var.storage_account_type
}
source_image_reference {
publisher = var.publisher
offer = var.offer
sku = var.sku
version=var.version_name
}

}

data "azurerm_virtual_machine" "lxvm"{
name    ="TerraformLinuxServer"
resource_group_name= "TFSTATEDEMO"
}

resource "azurerm_virtual_machine_extension" "avme" {
name = "hostname"
virtual_machine_id= data.azurerm_virtual_machine.lxvm.id
publisher ="Microsoft.Azure.Extensions"
type="CustomScript"
type_handler_version="2.0"

settings = <<SETTINGS
    {   
        "fileUris": ["https://stgadmtest123.blob.core.windows.net/script/install.sh"],
        "commandToExecute": "sh install.sh"
    }
SETTINGS


/*
settings = <<SETTINGS 
	{
 		"fileUris": ["https://stgadmtest123.blob.core.windows.net/script/install.sh"],
		"commandToExcute": " sh install.sh"
	}
SETTINGS
*/
/*
tags = {
    environment = "Production"
  }
*/

provisioner "remote-exec" {
connection{
type="ssh"
user=var.admin_username
password=var.admin_password
host="20.232.209.211"
}
inline = [
 "sudo cp /home/adminuser/index.html /var/www/html/",
]
}

}

data "azurerm_public_ip" "aip" {
name="mypip32"
resource_group_name=var.resource_group_name
}

output "public_ip_address" {
value=data.azurerm_public_ip.aip.ip_address
}
