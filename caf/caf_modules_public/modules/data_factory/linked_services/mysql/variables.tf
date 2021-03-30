variable name {
  description = "(Required) Specifies the name of the Data Factory Linked Service MySQL. Changing this forces a new resource to be created. Must be globally unique."
}

variable resource_group_name {
  description = "(Required) The name of the resource group in which to create the Data Factory Linked Service MySQL. Changing this forces a new resource"
}

variable data_factory_name {
  description = "(Required) The Data Factory name in which to associate the Linked Service with. Changing this forces a new resource."
}

variable description {
  description = "(Optional) The description for the Data Factory Linked Service MySQL."
}

variable integration_runtime_name {
  description = "(Optional) The integration runtime reference to associate with the Data Factory Linked Service MySQL."
}

variable annotations {
  description = "(Optional) List of tags that can be used for describing the Data Factory Linked Service MySQL."
}

variable parameters {
  description = "(Optional) A map of parameters to associate with the Data Factory Linked Service MySQL."
}

variable additional_properties {
  description = "(Optional) A map of additional properties to associate with the Data Factory Linked Service MySQL."
}

variable connection_string {
  description = "(Required) The connection string in which to authenticate with MySQL."
}