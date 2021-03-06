package main

import data.network.check_resources_have_environment_in_name

environment := "staging"

resources[r] {
	r := input.planned_values.root_module.resources[_]
}

deny[msg] {
  vnets := [r | r := resources[_]; r.address == "azurerm_virtual_network.example"]
  vnets_with_wrong_cidr_blocks := [r | r := vnets[_]; r.values.address_space[0] != "10.254.0.0/16"]
  count(vnets_with_wrong_cidr_blocks) != 0
  msg = sprintf("vnets must have correct CIDR blocks, `%v`", [vnets_with_wrong_cidr_blocks])
}

deny[msg] {
  subnets := [r | r := resources[_]; startswith(r.address, "azurerm_subnet.example")]
  count(subnets) != 2
  msg = sprintf("should have 2 subnets, `%v`", [subnets])
}

deny[msg] {
  r := check_resources_have_environment_in_name(resources, environment)
  msg = sprintf("resource names must have environment, `%v`", [r])
}