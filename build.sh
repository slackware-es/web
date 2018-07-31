#!/bin/bash

hugo --gc --ignoreCache
/etc/rc.d/rc.caddy restart

