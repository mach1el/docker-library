<?php

$config_admin_modules = array (
	"list_admins"	=> array (
		"enabled"	=> true,
		"name"		=> "Access"
	),
	"boxes_config"    => array (
		"enabled"   => true,
		"name"		=> "Boxes"
	),
	"db_config"    => array (
		"enabled"   => true,
		"name"		=> "DB config"
	)
);

$config_modules 	= array (
	"dashboard"		=> array (
		"enabled"	=> true,
		"name"		=> "Dashboard",
		"icon"		=> "images/icon-dashboard.png",
		"modules"	=> array (
			"dashboard"			=> array (
				"enabled"		=> true,
				"name"			=> "Dashboard",
				"path"			=> "system/dashboard"
			),
		)
	),
	"users"			=> array (
		"enabled" 	=> true,
		"name" 		=> "Users",
		"icon"		=> "images/icon-user.svg",
		"modules"	=> array (
			"user_management"	=> array (
				"enabled"		=> true,
				"name"			=> "User Management"
			),
			"alias_management"	=> array (
				"enabled"		=> true,
				"name"			=> "Alias Management"
			),
			"group_management"	=> array (
				"enabled"		=> true,
				"name"			=> "Group Management"
			),
		)
	),
	"system"		=> array (
		"enabled"	=> true,
		"name"		=> "System",
		"icon"		=> "images/icon-system.svg",
		"modules"	=> array (
			"addresses"			=> array (
				"enabled"		=> true,
				"name"			=> "Addresses"
			),
			"cdrviewer"			=> array (
				"enabled"		=> true,
				"name"			=> "CDR Viewer"
			),
			"dialog"			=> array (
				"enabled"		=> true,
				"name"			=> "Dialog"
			),
			"dialplan"			=> array (
				"enabled"		=> true,
				"name"			=> "Dialplan"
			),
			"mi"				=> array (
				"enabled"		=> true,
				"name"			=> "MI Commands"
      ),
		),
	)
);
?>