+++
title = "PostgREST: BAAS for PostgreSQL databases"
date = 2018-08-29T06:00:00Z
description = "How to install and configure PostgREST server in Slackware"
draft = false
toc = true
categories = ["documentation"]
tags = ["postgrest", "howto"]
type = "post"
+++


### Introduction

{{< blockquote cite="https://postgrest.org/en/v5.0/intro.html" >}}
PostgREST is a standalone web server that turns your PostgreSQL database directly into a RESTful API. The structural constraints and permissions in the database determine the API endpoints and operations.

Using PostgREST is an alternative to manual CRUD programming. Custom API servers suffer problems. Writing business logic often duplicates, ignores or hobbles database structure. Object-relational mapping is a leaky abstraction leading to slow imperative code. The PostgREST philosophy establishes a single declarative source of truth: the data itself.
{{< /blockquote>}}


Our aim is to build and experiment with applications using an HTTP based back-end.  These applications can use a lot of languages and environments: shell scripts, Javascript, etc.

### Building a  package for Slackware

PostgREST is written in the Haskell programming language, so to build the software we need a Haskell compiler installed into our build system.
We can install the Glasgow Haskell Compiler from the [SlackBuild repository](https://slackbuilds.org/repository/14.2/haskell/ghc/).
The official build instructions are basically to execute the command:

{{< highlight auto >}}
# stack build --install-ghc --copy-bins --local-bin-path /usr/local/bin
{{< /highlight>}}

With this information, we can build our [own SlackBuild script](https://raw.githubusercontent.com/slackware-es/packages/master/postgrest/postgrest.SlackBuild). Look into our [repository](https://github.com/slackware-es/packages/tree/master/postgrest) to see all the files.

Build the PostgREST package executing the ```postgrest.SlackBuild``` script. It will generate the package into ```/tmp```.

Once you have the package, we need to install it into the server.

### Before setting up

This package requires a working PostgreSQL database, configured with user access, tables, etc. The service requires planning carefully the database schemas, permissions and functions to work.

Try to set up first an SQL program to build your database before setting up PostgREST. Also, follow the tutorials and the documentation in their [website](https://postgrest.org).

We had problems with [schema isolation](https://postgrest.org/en/v5.0/auth.html#schema-isolation). We learned that we need to set up the ```search_path``` per function.

It is also advisable to split the internal procedures, and the external ones, so only the API only exposes what it is really neeed and nothing more.

### Setting PostgREST up

Before starting, PostREST needs a configuration file describing the environment. The package expects the configuration file to be ```/opt/postgrest/etc/postgrest.conf```.
The [configuration file documentation](https://postgrest.org/en/v5.0/install.html#configuration) details how to set up PostgREST. It will neeed the PostgreSQL database URI, the database schema and the database anonymous role.

To get things right, it is advisable to follow the getting started (tutorial)[https://postgrest.org/en/v5.0/tutorials/tut0.html].

### Resources

 - [Home page](https://postgrest.org)
 - [Github repository](https://github.com/PostgREST/postgrest)
 - [StackOverflow](https://stackoverflow.com/questions/tagged/postgrest)
 - [Gitter](https://gitter.im/begriffs/postgrest)


