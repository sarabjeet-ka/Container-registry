variable "container_registry_variables" {
    type=map(object({
container_registry_name=string
resource_group_name=string
geo_replicated_location=string
    }))
 
}