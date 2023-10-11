
# Dockerizing WordPress with Dockerfile, Docker Compose, and Database Optimization
## Prerequisites(Official images):
+ Docker
+ Docker Compose
+ WordPress
+ MySQL
+ phpMyAdmin

## Task 1:
**Step 1:**
+ Writing Dockerfile for WordPress(save as `Dockerfile`)
+ Strictly following the requirements(using official WordPress image, minimizing layers, and using appropriate labels)

      # Official WordPress img
      FROM wordpress:latest
      
      # Setting metadata for the image
      LABEL maintainer="rajat@55tech.com"
      LABEL description="Docker image for WordPress"
      
      # Expose port 80
      EXPOSE 8000:80
      
      # Starting the WordPress application
      CMD ["apache2-foreground"]

**Step 2:**
+ After copying above code fire the below commands:

      # image creation
      docker build -t img-name .
      # running the container from image on external port 8000
      docker run -p 8000:80 --name wp-container img-name

+ After execution of above commands hit [localhost:8000](http://localhost:8000)
+ This will open WordPress page.





## Task 2:
**Step 1:**
+ Writing Docker Compose file(save as `docker-compose.yml`)
+ Strictly following the requirements(include services for WordPress and the database(e.g., "MySQL"))

      # Using Docker version: 3 
      version: '3'
      
      # Docker running services
      services:
        # MySQL DB service
        mysql_db:
          # this defines the name of container
          container_name: mysql-container
          # MySQL image from Dockerhub(using latest image)
          image: mysql:latest
          # it can automatically start the policy whenever container gets destroyed or machine get restarted 
          restart: always      
          # this VOLUME must be made PERSISTENT which allows the data to survive between container restart or destroy.  
          volumes:
            - mysql:/var/lib/mysql 
      
        #WordPress CMS service
        wordpress:
          # it allows the WordPress container to only start when mysql_db is already started
          depends_on:
            - mysql_db
          # this defines the name of the container
          container_name: wordpress-container
          # WordPress image from Dockerhub(using latest image)
          image: wordpress:latest 
          # it can automatically start the policy whenever container gets destroyed or machine get restarted 
          restart: always   
          # external port:docker port, here the default port is 80 and we're exposing it to external port 8000
          ports:
            - "8000:80"
          # Environment variables(referred from Docker documentation) which allows to run WordPress container from Docker(DO NOT enter security credentials)
          environment:
            # default WB port: 3306
            WORDPRESS_DB_HOST: mysql_db:3306
            #this must be same as MYSQL(wordpress_db)
            WORDPRESS_DB_NAME:wordpress_db
            # this must be same as MYSQL(wordpress_user)
            WORDPRESS_DB_USER: wordpress_user
          # from this VOLUME we can access WordPress website on your machine, "./" denotes same directory where Docker-compose file is present
          volumes:
            - "./:/var/www/html"  
                  
        # Accessing DB PhpMyAdmin services which allows for working with the DB
        phpmyadmin:
          # it allows the PhpMyAdmin container to only start when mysql_db is already started
          depends_on:  
            - mysql_db
          # this defines the name of the container
          container_name: phpmyadmin-container
          # phpmyadmin image from Dockerhub
          image: phpmyadmin/phpmyadmin
          # it can automatically start the policy whenever container gets destroyed or machine get restarted 
          restart: always   
          # external port:docker port, here the defualt port is 80 and we're exposing it to external port 8080
          ports:
            - 8080:80
          #  Environment variables(referred from Docker documentation) which allows to run PhpMyAdmin container from Docker(DO NOT enter security credentials)
          environment:
            # must be same as mysql, can also take container name instead of service name
            PMA_HOST: mysql_db
          # this VOLUME "./" defines same directory where docker-compose is present
          volumes:
            - "./:/var/www/html/phpmyadmin" 
      
      # this VOLUME defines as persistent volumes 
      volumes:
        # this is also made PERSISTENT here
        mysql: {}

**Step 2:**
+ Writing Environment file (save as `.env`)

      # Environment variables(referred from Docker documentation) which allows to run MySQL container from Docker.
      MYSQL_ROOT_PASSWORD=root-pwd
      MYSQL_USER=wordpress_user
      MYSQL_PASSWORD=password
      MYSQL_DATABASE=wordpress_db
      WORDPRESS_DB_PASSWORD=password
        
**Step 3:**
+ After copying above code fire the below commands:

      #to start the container
      docker-compose up -d

+ After execution of above command hit [localhost:8080](http://localhost:8080)
+ This will open phpMyAdmin page

## Task 3:
**Step 1:**
+ Access the MySQL Container:

      docker exec -it mysql-container /bin/bash

+ Login to MySQL:
  
      mysql -u root -p

**Step 2:**
1. Using Indexing: It helps to speed up the queries which involves multiple cases like searching, sorting, filtering based on the specified column in the specified table.
+ Hit the following command:

      # here duplication is allowed
      CREATE INDEX index_name ON table_name(column1, column2, ...);

      # here duplication is not allowed
      CREATE UNIQUE INDEX index_name ON table_name (column1, column2, ...);

2. Using Caching: It helps to store the data which is frequently accessed in the memory which eventually leads to reduce the need for repeated qeries.
+ Hit the following command:

      # can store upto 5MB of cache memory
      SET GLOBAL query_cache_size = 5242880; -- 5MB cache size

3. Query Optimization: It basically improves the performance and efficiency of database queries.
+ Hit the following command:

      # selects only your order from table and limits to only 10 rows.
      EXPLAIN SELECT your_order FROM your_table WHERE your_condition LIMIT 10;

4. Normalization and Denormalization: It helps to minimize the data redundancy and improve data integrity.
+ Hit the following command:

      # Normalization query
      # it basically joins the products and orders tables based on theri keys
      SELECT p.product, o.ordered FROM products p
      INNER JOIN orders o ON p.product_id = o.product_id WHERE o.customer_id =12345;

      # Denormalization query
      # it basically retrieve the same list of products ordered by specific customer more efficiently
      SELECT product, ordered FROM order_details
      WHERE customer_id = 12345;

5. Database Configuration: Maintining DB configurations settings can eventually impact the performanc based on your server's resources and workload.
+ Hit the following command:

      # it allocates the area in memory where MySQL caches data and indexes.
      innodb_buffer_pool_size = 2G; -- Allocate 2GB for buffer pool
      # this defines max no. of concurrent connections allowed to the MySQL Server.
      max_connections = 100; -- Limit the number of concurrent connections

6. Monitoring and Scaling: Regularly monitor database performance and scale your infra as needed to handle increades load.
7. Additionally we can add cronjob in `docker-compose.yml` file and specify the amount of time which can delete the data which is not required.
+ Following `services` can be added in `docker-compose.yml` to delete the data in 5 minutes(example):

        cron_job:
          image: ubuntu:latest
          command: /bin/bash -c "while true; do /delete_data.sh; sleep 180; done"
          volumes:
            - ./delete_data.sh:/delete_data.sh 

## Task 4:
**Few Recommendation:**
+ Database Maintenance: Always make sure to perform database maintenance for eg, indexing, defragmentation which helps the databse runs smoothly.
+ Testing: Make sure to test in development environment before applying major optimizations.
+ Backups: Make sure to regularly backup your database.



