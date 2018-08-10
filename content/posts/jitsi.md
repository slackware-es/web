+++
title = "Jitsi: video conference server"
date = 2018-08-09T06:00:00Z
description = "How to install and configure Jitsi video conference server in Slackware"
draft = false
toc = true
categories = ["documentation"]
tags = ["jitsi", "howto"]
type = "post"
+++

From it's [Github](https://github.com/jitsi/jitsi-meet) page:

Jitsi Meet is an open-source (Apache) WebRTC JavaScript application that uses Jitsi Videobridge to provide high quality, secure and scalable video conferences. You can see Jitsi Meet in action here at the session #482 of the VoIP Users Conference.

The Jitsi Meet client runs in your browser, without the need for installing anything on your computer. You can also try it out yourself at https://meet.jit.si .

Jitsi Meet allows for very efficient collaboration. It allows users to stream their desktop or only some windows. It also supports shared document editing with Etherpad.

<!--more-->

## Introduction

We want to offer a secure video conference service for our company.We selected ```jitsi-meet``` as our video conference platform because it meets all our requirements.

As soon as we check their documentation, it’s clear they only support Ubuntu and Debian Linux distributions. But they also provide hints to do a manual install of their software.

In this document we will set up and install a single instance of this platform using Slackware 64 bits Current.

## Service architecture

The general architecture of the service as per their documentation is:

{{< highlight auto >}}
                             +                           +
                             |                           |
                             |                           |
                             v                           |
                            443                          |
                         +-------+                       |
                         |       |                       |
                         | NginX |                       |
                         |       |                       |
                         +--+-+--+                       |
                            | |                          |
          +------------+    | |    +--------------+      |
          |            |    | |    |              |      |
          | jitsi-meet +<---+ +--->+ prosody/xmpp |      |
          |            |files 5280 |              |      |
          +------------+           +--------------+      v
                               5222,5347^    ^5347      4443
                          +--------+    |    |    +-------------+
                          |        |    |    |    |             |
                          | jicofo +----^    ^----+ videobridge |
                          |        |              |             |
                          +--------+              +-------------+
{{< /highlight >}}               
                
```jitsi-meet``` basic requirements are:

-  A web server with a valid SSL certificate,

-  The Prosody Jabber service, with their JWT plug-in

- The Jitsi VideoBridge service

- The Jitsi Conference Focus (jicofo) service

- The Java platform 8

- The Lua platform 5


Also we are going to need:

- Four different secrets for components communication

- A prosody user and group


## Software packages

We have identified what software we need to install in our server to make ```jitsi-meet``` work and created SlackBuild scripts for them. You can check our source code [repository](https://github.com/slackware-es/packages) or our binary packages at [slackware.es](https://slacware.es/files/media/pkg/).

We also used packages from [slackbuilds.org](https://slackbuilds.org), like the ```prosody``` server package, and also we used those scripts as a base for our own.

{{< highlight auto >}}
├── caddy-0.11-x86_64-1_es.tgz
├── jdk-8u181-x86_64-1.txz
├── jitsi
│   ├── jicofo-1.1-x86_64-1_es.tgz
│   ├── jitsi-meet-1.1-x86_64-1_es.tgz
│   ├── jitsi-meet-token-1.1-x86_64-1_es.tgz
│   └── jitsi-videobridge-1.1-linux-x64-1_es.tgz
└── prosody
    ├── LuaBitOp-1.0.2-x86_64-1_SBo.tgz
    ├── lbase64-5.1--1_SBo.tgz
    ├── lua-5.1.5-x86_64-1_SBo.tgz
    ├── lua-cjson-2.1.0-x86_64-1_SBo.tgz
    ├── lua-filesystem-1.6.3-x86_64-1_SBo.tgz
    ├── lua-zlib-20140201_c0014bc-x86_64-1_SBo.tgz
    ├── luacrypto-0.5.1-x86_64-1_SBo.tgz
    ├── luaevent-0.4.3-x86_64-1_SBo.tgz
    ├── luaexpat-1.3.0-x86_64-1_SBo.tgz
    ├── luarocks-2.4.1-x86_64-1_SBo.tgz
    ├── luasec-0.7-x86_64-1_SBo.tgz
    ├── luasocket-3.0_rc1-x86_64-1_SBo.tgz
    └── prosody-0.10.2-x86_64-1_SBo.tgz
{{< / highlight >}}

For the Java package, we used the Slackware extras ```SlackBuild``` located in [extra](https://slackware.es/files/slackware/slackware64-current/extra/source/java/) folder of the Slackware distribution.

We created startup scripts and a basic configuration files and included them on each package.

If you want to build your own, just download the source and run the SlackBuild scripts as usual.

The only software we do not created a package for was the Let's Encrypt client.

### Package installation

After building the packages (you can download them from our b[inary repository](https://slacware.es/files/media/pkg/)), we install them using ```installpkg``` as usual.

By default the startup scripts are marked for execution and are installed in ```/etc/rc.d```

The prosody packages install their software in ```/usr``` prefix, while the jisi packages install in ```/opt``` prefix.

## Web server and SSL certificate
We have chosen the open source [Caddy](www.caddyserver.com) as our web server. Our package builds the Github version without any plug-ins, and install ```/etc/rc.d/rc.caddy``` as a startup script and ```/etc/caddy/Caddyfile``` as a default configuration file.

Our ```Caddyfile``` mimics the NGINX configuration provided by the jitsi-meeet team at their [repository](https://github.com/jitsi/jitsi-meet/blob/master/doc/manual-install.md#install-nginx)

{{< highlight auto >}}
https://server.domain.com {
        root /opt/jitsi-meet
        tls /etc/acme.sh/server.domain.com/fullchain.cer /etc/acme.sh/server.domain.com/server.domain.com.key
        rewrite /room.* /
        proxy /http-bind server.domain.com:5280
        log /var/log/caddy/access.log
}
{{< /highlight >}}

The rewrite rule only allows this ```prosody``` to create rooms that start with the word ```room```. We can be more creative to mimic better the NGINX configuration but this serves our purpose well.

Caddy integrates with Let's encrypt certificates automatically, but we are going to use [acme.sh](https://github.com/Neilpang/acme.sh) client because we want to integrate the certificates in other components and open the possibility to change our web server if we need to. See the wiki for the [advanced installation](https://github.com/Neilpang/acme.sh/wiki/How-to-install) proceess.

{{< highlight auto >}}
# curl https://get.acme.sh | sh -s -- --install --home /etc/acme.sh
{{< /highlight >}}

We want ```acme.sh``` to install in ```/etc``` becasue the certificates will be read by multiple components of the system.

To get our certificates we set up ```acme.sh``` to answer Let's encrypt challenge using Cloudflare DNS service:

{{< highlight auto >}}
# export CF_Key="asdfgasdfgasdfgasdfg"
# export CF_Email="me@email.com"
# acme.sh --issue --dns dns_cf -d server.domain.com -d auth.server.domain.com
#
{{< /highlight >}}

Note we need to ask for ```auth.server.domain.com``` as well, to use the certificate with prosody. Also note that acme.sh will add a ```cron``` job to renew certificates monthly.

We can start our web server using ```/etc/rc.d/rc.caddy start``` command and check the log files in ```/var/log/caddy/```to search for errors.


## Prosody server

Prosody is used by the ```jitsi-meet``` platform to route messages, enable chat, etc. The configuration file is in ```/etc/prosody```.

We need to modify the main configuration file ```/etc/prosody/prosody.lua.cfg``` to include the following lines

{{< highlight lua >}}
plugin_paths = { "/opt/jitsi-meet-token/" }
Include "server.domain.com.cfg.lua"
{{< /highlight >}}

With those lines we enable the ```jitsi-meet``` plugins for ```prosody``` and include a new configuration file which will contain our hosts parameters:


{{< highlight lua >}}
VirtualHost "server.domain.com"
    authentication = "token"
    app_id = "server.domain.com";
    app_secret = "jwt-secret";
    allow_empty_token = false;

    ssl = {
        key = "/etc/acme.sh/server.domain.com/server.domain.com.key";
        certificate = "/etc/acme.sh/server.domain.com/fullchain.cer";
    }
    modules_enabled = {
        "bosh";
        "pubsub";
        "ping";
    }
    c2s_require_encryption = false

Component "conference.server.domain.com" "muc"
    modules_enabled = { "token_verification" }
    storage = "internal"

admins = { "focus@auth.server.domain.com" }

Component "jitsi-videobridge.server.domain.com"
    component_secret = "videobridge-secret"

VirtualHost "auth.server.domain.com"
    ssl = {
        key = "/etc/acme.sh/server.domain.com/server.domain.com.key";
        certificate = "/etc/acme.sh/server.domain.com/fullchain.cer";
    }
    authentication = "internal_plain"

Component "focus.server.domain.com"
    component_secret = "jicofo-secret"
{{< /highlight>}}

Before starting prosody, we create an user and group called prosody. The log files for prosody will be in ```/home/prosody```. Also we need to copy our certificates to ```/etc/prosody/certs/``` as shown in the configuration file, as prosody user is not able to read them from ```/root/acme.sh```.

Start prosody server with the command ```# prosodyctl start``` and check the log files.

{{< highlight bash >}}
# prosodyctl register focus auth.jitsi.example.com focus-user-secret
# prosodyctl restart
{{< /highlight >}}


## Jitsi video bridge server

The configuration files for the service are located in ```/etc/jitsi/videobridge```. We need to update the ```config``` file with the data of our installation:

{{< highlight auto >}}
# Jitsi Videobridge settings

# sets the XMPP domain (default: none)
JVB_HOSTNAME=server.domain.com

# sets the hostname of the XMPP server (default: domain if set, localhost otherwise)
JVB_HOST=

# sets the port of the XMPP server (default: 5275)
JVB_PORT=5347

# sets the shared secret used to authenticate to the XMPP server
JVB_SECRET=videobridge-secret

# extra options to pass to the JVB daemon
JVB_OPTS=--apis=rest,xmpp

# adds java system props that are passed to jvb (default are for home and logging config file)
JAVA_SYS_PROPS="$JVB_EXTRA_JVM_PARAMS -Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION=/etc/jitsi -Dnet.java.sip.communicator.SC_HOME_DIR_NAME=videobridge -Dnet.java.sip.communicator.SC_LOG_DIR_LOCATION=/var/log/jitsi -Djava.util.logging.config.file=/etc/jitsi/videobridge/logging.properties"

{{< /highlight >}}

Also we need to create the Java Key Store so clients can connect to the video bridge using SSL. We have included in the ```jitsi-videobridge``` package a tool called ```upgrade-cert.sh``` to create the store for us using the Let's Encrypt certificates:

{{< highlight bash >}}
#!/bin/bash

ACME="/etc/acme.sh"
SERVER="server.domain.com"
PASSWORD_STORE="changeit"

openssl pkcs12 \
        -export \
        -in $ACME/$SERVER/fullchain.cer \
        -inkey $ACME/$SERVER/$SERVER.key \
         -out $SERVER.p12 \
        -name $SERVER

keytool -importkeystore \
        -deststorepass $PASSWORD_STORE \
        -destkeystore $SERVER.jks \
        -srckeystore $SERVER.p12 \
        -srcstoretype PKCS12 \
        -alias $SERVER

{{< /highlight >}}

Customize your server name and password store and run the script to create ```server.domain.com.jks```. Then update the ```sip-communicator.properties```  file accordinly (change the port to 4443 instead of 443 on the file to avoid conflicts).

You also might want to add the script to run when ```acme.sh``` renews the certificates.

We start the service using the provided script ```/etc/rc.d/rc.videobridge start``` and check the logs in ```/var/log/jitsi/jvb.log``` for errors.

## Jitsi Conference Focus

The configuration files for the service are located in ```/etc/jitsi/jicofo```. We need to update the ```config``` file with the data of our installation:

{{< highlight auto >}}
# Jitsi Conference Focus settings
# sets the host name of the XMPP server
JICOFO_HOST=localhost

# sets the XMPP domain (default: none)
JICOFO_HOSTNAME=server.domain.com

# sets the secret used to authenticate as an XMPP component
JICOFO_SECRET=jicofo-secret

# sets the port to use for the XMPP component connection
JICOFO_PORT=5347

# sets the XMPP domain name to use for XMPP user logins
JICOFO_AUTH_DOMAIN=auth.server.domain.com

# sets the username to use for XMPP user logins
JICOFO_AUTH_USER=focus

# sets the password to use for XMPP user logins
JICOFO_AUTH_PASSWORD=focus-user-secret

# extra options to pass to the jicofo daemon
JICOFO_OPTS=""

# adds java system props that are passed to jicofo (default are for home and logging config file)
JAVA_SYS_PROPS="-Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION=/etc/jitsi -Dnet.java.sip.communicator.SC_HOME_DIR_NAME=jicofo -Dnet.java.sip.communicator.SC_LOG_DIR_LOCATION=/var/log/jitsi -Djava.util.logging.config.file=/etc/jitsi/jicofo/logging.properties"

{{< /highlight >}}

We start the service using the provided script ```/etc/rc.d/rc.jicofo start``` and check the logs in ```/var/log/jitsi/jvb.log``` for errors.

## Jitsi Meet Application

The jitsi meet application is in /opt/jitsi-meet. Because the Caddy web server does not have server side includes, we need to edit index.html and include the needed javascript files:

{{< highlight html >}}
<script src="/config.js"></script>
<script src="libs/do_external_connect.min.js?v=1"></script>
<script src="/interface_config.js"></script>
<script src="/logging_config.js" --></script>
{{< /highlight >}}

Also we might want to include the file ```title.html``` in the header section of the ```index.html```.


## Using the service

We have configured the service to use JWT authentication. Following the documentation at [jitsi-meet repository](https://github.com/jitsi/lib-jitsi-meet/blob/master/doc/tokens.md) and using the JWT Debugger at [jwt.io](https://jwt.io), we can generate a link like:

{{< highlight auto>}}
https://server.domain.com/roomXXX?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6Ik......
{{< /highlight >}}

To enter a room, paste the link into the browser.


