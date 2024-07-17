
# Generate random name for resource group
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

data "azurerm_public_ip" "my_data_public_ip" {
  name                = azurerm_public_ip.my_terraform_public_ip.name
  resource_group_name = azurerm_public_ip.my_terraform_public_ip.resource_group_name
}

# Create Network Security Group and rules
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.my_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Associate Network Security Group with the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }
  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "myVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = var.username
  admin_password = var.password
  /*custom_data    = filebase64("C:/Users/Utilisateur/Documents/vscode/DEVOPS/user_data.sh")*/
  disable_password_authentication = false

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for VM to be ready...'"
    ]

    connection {
      type     = "ssh"
      user     = var.username
      password = var.password
      host     = data.azurerm_public_ip.my_data_public_ip.ip_address
      timeout  = "2m"
    }
  }

  provisioner "file" {
    source      = "C:/Users/Utilisateur/Documents/vscode/DEVOPS/user_data.sh"
    destination = "/home/thomas.tisseron@efrei.net/user_data.sh"

    connection {
      type     = "ssh"
      user     = var.username
      password = var.password
      host     = data.azurerm_public_ip.my_data_public_ip.ip_address
      timeout  = "2m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/thomas.tisseron@efrei.net/user_data.sh",
      "/home/thomas.tisseron@efrei.net/user_data.sh args"
    ]

    connection {
      type     = "ssh"
      user     = var.username
      password = var.password
      host     = data.azurerm_public_ip.my_data_public_ip.ip_address
      timeout  = "3m"
    }
  }




  provisioner "file" {
    source      = "C:/Users/Utilisateur/user_data.sh"
    destination = "/tmp/user_data.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/azureuser/user_data.sh",
      "/home/azureuser/user_data.sh args"
    ]

    connection {
      type     = "ssh"
      user     = var.username
      password = var.password
      host     = data.azurerm_public_ip.my_data_public_ip
      timeout  = "3m"
    }
  }


  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}

