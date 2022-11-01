<h3 align="center">How to Dockerize Nextcloud Online (Fast)</h3>


This docker compose file should achieve one of the fastest Nextcloud instance!
We use socks files for the communication between the containers. So containers can communicate without IP overhead and become some faster than comparable installations.

<br/>

><font size="1">https://medium.com/@jonbaldie/how-to-connect-to-redis-with-unix-sockets-in-docker-9e94e01b7acd</font> 
>><font size="2">The TCP connection makes the benchmark 22% longer than the test using Unix sockets.</font>

<br/>

><font size="1">https://guides.wp-bullet.com/how-to-configure-redis-to-use-unix-socket-speed-boost/</font> 
>><font size="2">When I ran some basic Redis unix socket benchmarks I found the results quite surprising – unix sockets were 25% faster than TCP sockets for Redis.</font>

<br/>

><font size="1">https://www.reddit.com/r/selfhosted/comments/vf6jeg/i_used_unix_sockets_to_improve_the_performance_of/</font> 
>><font size="2">...I saw a very surprisingly high 32% improvement for Redis and a modest 10% improvement with Postgres.</font> 

<br/>

# Installation

1. Clone the repo
   ```sh
   git clone https://github.com/luftl0ch/Nextcloud-docker-compose-with-socks.git
   ```
2. Edit the `.env` file
3. Execute docker-compose.
   ```sh
   cd Nextcloud-docker-compose-with-socks && docker-compose up -f nextcloud.yml -d
   ```
4. Nextcloud should be available on port 80.

<br/>

# Solved problems
<br/>

All these problems have been fixed and should not happen again.
 
 <br/>

## Postgres 15 does not work yet without manual adjustment. 
See the following thread: https://www.reddit.com/r/PostgreSQL/comments/y4km3f/help_with_a_new_install_of_nextcloud_on_docker/

Typical error messages:
```
Error while trying to initialise the database: An exception occurred while executing a query: SQLSTATE[42501]: Insufficient privilege: 7 ERROR: permission denied for schema public LINE 1: CREATE TABLE oc_migrations (app VARCHAR(255) NOT NULL
```

```
2022-10-25 20:07:45.923 CEST [667] ERROR:  permission denied for schema public at character 14
2022-10-25 20:07:45.923 CEST [667] STATEMENT:  CREATE TABLE oc_migrations (app VARCHAR(255) NOT NULL, version VARCHAR(255) NOT NULL, PRIMARY KEY(app, version))
```

### Solution:
```
psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"
GRANT CREATE ON SCHEMA public TO "$POSTGRES_USER";
```
(The mounted script db_init_psql15_workaround.sh does it automatically for you.)

<br/>

## Without an port specification in the REDIS_HOST_PORT environment of the nextcloud-fpm container you will see an error message like this.

```Internal server error
Deprecated
: Redis::pconnect(): Passing null to parameter #2 ($port) of type int is deprecated in
/var/www/html/lib/private/RedisFactory.php
on line
137
```
### Solution:
Add this environment variable to the nextcloud-fpm Container:
```
    environment:
      - REDIS_HOST_PORT=0
```

<br/>

## The ID of the user www-data differs for different Nextcloud images.
The ID of the user www-data differs from the nextcloud:apache image (33) to the nextcloud:fpm-alpine image (82). Maybe this will change in the future. In case of authorization problems, you have to check the /etc/passwd of the nextcloud:fpm-alpine container for the correct user ID.

Passwd from the official nextcloud:apache image:
```
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
```
Passwd from the nextcloud:fpm-alpine image:
```
www-data:x:82:82:Linux User,,,:/home/www-data:/sbin/nologin
```
<br/>

## Strangely, no comments are allowed in zz-docker.conf. 
The following error message appears in the log of the nextcloud:fpm-alpine container if there is a comment:
```
[] ERROR: [/usr/local/etc/php-fpm.d/zz-docker.conf:2] value is NULL for a ZEND_INI_PARSER_ENTRY
[] ERROR: Unable to include /usr/local/etc/php-fpm.d/zz-docker.conf from /usr/local/etc/php-fpm.conf at line 2
[] ERROR: failed to load configuration file '/usr/local/etc/php-fpm.conf'
[] ERROR: FPM initialization failed
```
<br/>

# Hints:



To see your files immediately and not the annoying Nextcloud Dashboard first, you can disable it as follows over the Docker Host:
```
docker exec -u www-data -it nextcloud-fpm ./occ app:disable dashboard
```

<br/>

To see if the Redis cache is also used, the log level can be increased by adding "`--loglevel debug`" to the command line of the nextcloud-redis container.

<br/>

With the following command you can display the finished compose file with all resolved variables:
```
docker compose -f "nextcloud.yml" convert
```

<br/><br/>

# Hall of fame:

<br/>

Ugite-code (reddit):<br/>
For the idea to set the right permissions with the help of an extra busybox container. Its an dirty little nice hack, but otherwise you ran in annoying "permission denied" messages, if you wanna share socks connections over different containers.

<font size="1">https://www.reddit.com/r/selfhosted/comments/vf6jeg/i_used_unix_sockets_to_improve_the_performance_of/</font>

<br/>

Timo (dr3st.de):<br/>
Because i stole the zz-docker.conf from one of his blog articles. Thanks for that!

<font size="1">https://dr3st.de/nextcloud-php-einstellungen-im-docker-setup/</font>

<br/>

stop_lying_good_god (reddit):<br/>
For the tip with the Postgres script, which is executed automatically under the path /docker-entrypoint-initdb.d/ in the Postgres container.
<font size="1">https://www.reddit.com/r/PostgreSQL/comments/y4km3f/help_with_a_new_install_of_nextcloud_on_docker/</font>