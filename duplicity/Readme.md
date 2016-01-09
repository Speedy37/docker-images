# Duplicity

This container provide the duplicity backup software and support pirax backend

## Hubic example

I made this container to backup my data to hubic.
To do so, I made an image that setup duplicity environment variable and provide hubic credentials:

`Dockerfile`:
```
FROM speedy\duplicity
COPY hubic_credentials /root/.hubic_credentials
```

`hubic_credentials`:
```
[hubic]
email=mymail@example.com
password=myhubicpassword
client_id=api_hubic_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
client_secret=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
redirect_uri=http://localhost/
```
