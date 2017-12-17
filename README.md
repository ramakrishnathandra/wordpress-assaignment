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



    
