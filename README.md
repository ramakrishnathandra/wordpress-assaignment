CHEF HOSTED SERVER CONFIGURATION

   1) Create an account in https://manage.chef.io/login

   2) Go to the Adminstartion tab and Create the organization

   3) Click on Generate knife config link to configure in the client
   
          current_dir = File.dirname(__FILE__)
          log_level                :info
          log_location             STDOUT
          node_name                "ramakrishnathandra"
          client_key               "~/chef-repo/.chef/ramakrishnathandra.pem"
          chef_server_url          "https://api.chef.io/organizations/cleotest"
          cookbook_path            ["~/chef-repo/cookbooks"]

   4)Download the chef starterkit to get the private key     

Setting Up a Workstation

    1) Download the latest Chef Development Kit
         wget https://packages.chef.io/files/stable/chefdk/2.4.17/ubuntu/14.04/chefdk_2.4.17-1_amd64.deb

    2) Install ChefDK
         sudo dpkg -i chefdk_2.4.17-1_amd64.deb

    3)  Verify the components of the development kit
         chef verify

    4) Generate the chef-repo and move into the newly-created directory
         chef generate repo chef-repo
         cd chef-repo

    5) Make the .chef directory
         mkdir .chef

    6) create the knife configuration(knife.rb) in .chef folder
         # See http://docs.chef.io/config_rb_knife.html for more information on knife configuration options
         
          current_dir = File.dirname(__FILE__)
          log_level                :info
          log_location             STDOUT
          node_name                "ramakrishnathandra"
          client_key               "~/chef-repo/.chef/ramakrishnathandra.pem"
          chef_server_url          "https://api.chef.io/organizations/cleotest"
          cookbook_path            ["~/chef-repo/cookbooks"]

          knife[:aws_access_key_id] = "XXXXXXXXXXXXXXXX"  # AWS Access KEY
          knife[:aws_secret_access_key] = "XXXXXXXXXXXXXXXXXX" # AWS SECRET KEY
          knife[:ssh_key_name] = "test"
          knife[:availability_zone] = "us-west-2a"
          knife[:region] = "us-west-2"

      7) Move to the chef-repo and copy the needed SSL certificates from the server
           cd ..
           knife ssl fetch

       8) Confirm that knife.rb is set up correctly by running the client list
           knife client list

Downloading and create the wordpress stack

       1) Go to Chef-repo folder in the Workstation
       
       2) Git clone git@github.com:ramakrishnathandra/wordpress-assaignment.git, you can find below folders in the respository
                 cookbooks/
                 data_bags/
                 deploy.sh
                 roles/
                 base-network.template
       
       3) Create the keypair in the region where we are going to launch the stack and copy the key pair in your work station
       
       4) base-network.template will Create a VPC, Subnets, Security Groups, EIP, Internet Gateway, Route Tables
       
       5) ./deploy.sh will upload the databag, cookbook and create the ec2 box to launch word press server, please find the deploy.sh help, none of them are mandatory.
               
               ubuntu@ip-172-31-7-177:~/chef-repo$ ./deploy.sh -h

                    usage: deploy.sh -x [os] -i [keyname] -N [ec2 instance name] -I [ubuntu 14.04 amiid] -f [ec2 instance type] -e [elasticip] -g [security group] -s [subnetid]
                    -x aws os
                    -i aws keyname [ need to specify whole path, to connect the ec2 machine we launched]
                    -N aws name of the ec2 instance
                    -I aws ubuntu 14.04 amiid
                    -f aws instance type
                    -e aws elasticip
                    -g aws security group
                    -s aws subnet id to launch ec2 in vpc
                    -u external site url
                    -h help

       
       
       
    
    
    
