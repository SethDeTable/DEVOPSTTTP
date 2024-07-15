variable "resource_group_location" {
  type        = string
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "thomas.tisseron@efrei.net"
}

variable "ssh_public_key" {
  description = "SSH public key"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxt/mNstbJ9NktmUNfmoNP97R82XaqMg/J2B4SSTxL1AjWgsPk0Q5vBj9WhTP+bngP1T7XfdqiylCSLupAwqxFFJRi4EpP+pUcT/yrspBgVVSprCtfzF4uq15RSjlDwbVBbibiaGdGlQPpdxgfErrpxXXzl6g1dmTHelNBpjsIHKR1k3mbk0wpHpHQJoJ8QetYp0S6Q4wOf7S/RXb2tRvfYqmml7Yye5qySCyOrFQg3QJBG1p6SRN/4U3YcQz9L0LDt6WHYKCOojgAnc7Jiiof7Tn2Sm7NO4nWX6nltwPqBV86eE3NUH2BmtVrR9MmrJPwur60vNpWps9ZmmLdT5WoZTSqNnqE38PT7zdwc/mRc76giYr3R7g4mDSwhjRbJtss8G/12oPz3r741fYTSTiJZL5E/WvuO4DAHu4e3gaGXpRS9fvpIf8/dfa6/onZSNffioxKwyycXFULOuoHTYA4Da1vyEf7f/EwUbowiQwpN97XRAPRwPbbpoUS2cJMqJeXXQToh5MPZk3Lf6uhj/w1s3WfzV16EhZ+vmjnKDgxJH0iW5/oeXc2OugtY4H+XPR4bgzjOCSS9kwl2aVfpjfQwnn0j/BpeYIxaYL42tVMYvH0mLagHDmEPVixZMyeJ/k/j3xNqR37+wnEECk1dF7WN6/MEjV4ktr94+ZRZvDhyw== thomas.tisseron@efrei.net"
}