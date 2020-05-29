Create a VPC Network (10.X.X.X/21 CIDR) with the following sub component in useast1. (For AWS create a private subnet and public subnet) 
 
1. Open Firewall ports on (Port 22 /ssh, Port 80/web) 
2. Create a bastion host that have access to port 22 
3. Create an Auto scaling group with one server(EC2 or VM ) with a launcher configurations to  install web server (example nginx or httpd ) as part install metadata scripts stored in S3 or GCS 
4. Create an application load balancer or Cloud Load balancer to access above webserver 
5. Test the Web URL (Automated) for success/failure check. 6. Destroy the environment. 


Steps to Deploy:
terraform init
terraform plan
terraform apply
terraform destroy
