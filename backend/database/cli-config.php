<?php
use Doctrine\ORM\EntityManager;
use Doctrine\ORM\Tools\Setup;
use Doctrine\ORM\Tools\Console\ConsoleRunner;

require_once __DIR__ . '/../vendor/autoload.php';


$entityPath = $_SERVER['php_project_path'];
$connection = [
    'dbname'   => $_SERVER['db_name'],
    'driver'   => $_SERVER['doctrine_dbdriver'],
    'host'     => $_SERVER['db_host'],
    'user'     => $_SERVER['db_user'],
    'password' => $_SERVER['db_user_password']
];

$config = Doctrine\ORM\Tools\Setup::createAnnotationMetadataConfiguration(
    [$entityPath], true
);
$entityManager = EntityManager::create($connection, $config);
return ConsoleRunner::createHelperSet($entityManager);