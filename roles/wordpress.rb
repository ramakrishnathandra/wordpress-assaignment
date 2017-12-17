name "wordpress"
description "Wordpress Chef role"
run_list "recipe[wordpress]"
override_attributes({
  "starter_name" => "Ramakrishna Thandra",
})
