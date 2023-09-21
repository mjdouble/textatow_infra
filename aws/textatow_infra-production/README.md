# textatow_infra


### Initialize s3 back end statefile
```
terraform init -upgrade

```

### Run Plan to see Changes

```
terraform plan

```

### Apply changes

```
terraform apply

```

### Destroy the stack (obviously be careful with this)

```
terraform destroy

```

# Terraform Docs for Module


## Requirements

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environ | the environment | `any` | n/a | yes |
| task\_def\_arn | ecs task def arn | `any` | n/a | yes |

## Outputs

No output.

### extra info:

When making changes to any resources that have to do with the VPC,
the Database will need to be recreated as it is tied to the VPC. 
So don't do that unless you've made data backups, etc.