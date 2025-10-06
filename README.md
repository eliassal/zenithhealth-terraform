# zenithhealth-terraform
Terraform code to create all resources indicated in the series Azure virtual networking series at https://medium.com/@temitopefunmi/list/azure-virtual-networking-series-3ccc35f1556a

Instructions to run the code.

1. If you use a backend to save the terraform state update ==backend.tf== file.
2. Enter the 4 secrets regarding your subscription in ==providers.tf== , just after features{} as follows inside
3. Then run
   - terraform plan -out mainNetworking.tfplan
   - terraform apply mainNetworking.tfplan

4. Once you are finished discovering and viewing, for cost purposes, delete everything
   - terraform destroy