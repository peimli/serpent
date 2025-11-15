### Welcome

At the end the [https://zoltansurge.ddns.net](https://zoltansurge.ddns.net) site will be available with the help of `NOIP` and `certbot` based SSL.

Make sure you register on the [noip](https://www.noip.com) website.

Please create the following bucket to ensure terraform state is versioned in an `S3` bucket.

``` bash
aws s3api create-bucket  --bucket zoltans3bucket  --region eu-north-1   --create-bucket-configuration LocationConstraint=eu-north-1
```

This bucket can also be used to store the backup for the RDS database tables.

To interact with the bucket we can use the following commands.

``` bash
admin@ip-10-0-1-244:~$ aws s3 cp demo.txt s3://zoltans3bucket/demo.txt
upload: ./demo.txt to s3://zoltans3bucket/demo.txt
admin@ip-10-0-1-244:~$ aws s3 ls s3://zoltans3bucket/
                           PRE zoltans3bucket/
2025-08-23 17:45:51          0 demo.txt
admin@ip-10-0-1-244:~$ aws s3 rm s3://zoltans3bucket/demo.txt
delete: s3://zoltans3bucket/demo.txt
```

This repository and solution utilizes the fact that any environment variable with a `TF_VAR_` prefix is picked up by terraform.

``` yml
TF_VAR_db_password: ${{ secrets.DB_PASSWORD }}
```

So the variables for the deployment are defined in github action secrets.

This is the list of variables you will have to define:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_AMI_ID
- AWS_AMI_INSTANCE_TYPE
- AWS_AMI_NAME
- AWS_AZ
- AWS_REGION
- AWS_KEY_NAME
- AWS_PEM
- AWS_RDS_DB_NAME
- AWS_RDS_DB_PASSWORD
- AWS_RDS_DB_USERNAME
- AWS_S3_BUCKET
- CERTBOT_DOMAIN
- CERTBOT_EMAIL
- DOCKERHUB_TOKEN
- DOCKERHUB_USERNAME
- NOIP_HOSTNAMES
- NOIP_PASSWORD
- NOIP_USERNAME

Once the RDS is up you can verify that the EC2 is able to connect and the database with the table and the user was successfully created.

``` bash
admin@ip-10-0-1-178:~$ mysql -u serpent_user -p -h tf-mysql-db.c9eimywgstca.eu-north-1.rds.amazonaws.com -P 3306
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 28
Server version: 8.0.42 Source distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [(none)]> show databases
    -> ;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| serpent            |
| sys                |
+--------------------+
5 rows in set (0.004 sec)

MySQL [(none)]> use serpent
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
MySQL [serpent]> show tables;
+-------------------+
| Tables_in_serpent |
+-------------------+
| scores            |
+-------------------+
1 row in set (0.003 sec)

MySQL [serpent]> describe scores;
+------------+--------------+------+-----+-------------------+-------------------+
| Field      | Type         | Null | Key | Default           | Extra             |
+------------+--------------+------+-----+-------------------+-------------------+
| id         | int          | NO   | PRI | NULL              | auto_increment    |
| name       | varchar(255) | NO   |     | NULL              |                   |
| score      | int          | NO   |     | NULL              |                   |
| difficulty | int          | NO   |     | NULL              |                   |
| created_at | timestamp    | YES  |     | CURRENT_TIMESTAMP | DEFAULT_GENERATED |
+------------+--------------+------+-----+-------------------+-------------------+
5 rows in set (0.002 sec)

MySQL [serpent]> exit
```
