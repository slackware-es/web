+++
title = "Sysstat: an easy status page"
date = 2018-09-01T06:00:00Z
description = "How to generate a simple status page for a server"
draft = false
toc = true
categories = ["documentation"]
tags = ["sysstat", "howto"]
type = "post"
+++


### Introduction

{{< blockquote cite="http://sebastien.godard.pagesperso-orange.fr/" >}}
The ```sysstat``` package contains various utilities, common to many commercial Unixes, to monitor system performance and usage activity.
{{< /blockquote>}}

```sysstat``` is a standard package which comes with Slackware distribution and almost any other distribution out there. Its a very useful tool to analize and monitor linux performance.

We are going to build a simple status page which will display performance metrics about the linux systems it runs on, including usage of:

 -  CPU
 - Memory
 - Network
 - Disk

And also process based statistics such system load and process queue.

We want something simple, but ```sysstat``` tools are powerfull enough to build much more complex systems.

### Install ```sysstat``` package

```sysstat``` package comes preinstalled in a full installation of Slackware, but if you're using a custom package setup, please check you have ```sysstat``` and ```lm_sensors``` packages.

### Monitoring 

We want to calculate statistics in 10 minute periods with one measurement each minute. So we use the ```sa1``` tool to record all collectable data in periods of 600 seconds with collection every 60 seconds. Also we want to repeat this process constantly so we create a ```cron``` job to automate the execution.

This tool will save in the file ```/var/log/sa/saDD`` the data collected and will change DD accordinly to the they of the month. 

{{< highlight auto >}}
# monitoring
0,10,20,30,40,50 * * * * /usr/lib64/sa/sa1 -S XALL 600 60
{{< /highlight>}}


Then we want to generate some graphics to read the data and store them in a location accesible by our webserver. We want to update our status page as soon as the data has been collected. Using the ```sadf``` tools we generate an SVG image containg all the graphs we need:

 - CPU: ```-u``` 
 - Memory: ```-r```
 - Network: ```-n DEV```
 - Disk: ```-d```
 - System Load: ``` -p```
 - Process queue: ```-q```
 
 So we add another cronjob, to execute after the other one. Also we save the results of the svg generation in the file ```/var/www/sar/stats.svg```. This directory needs to be configured in our webserverto make it available externally. It is also possible to download the file using ```ssh``` to view it locally if we do not have a web service in the system.
 
{{< highlight auto >}}
1,11,21,31,41,51 * * * * /usr/bin/sadf -g -- -u -p -q -r -d -n DEV > /var/www/sar/stats.svg
{{< /highlight>}}

### The status page

In order to view the generated SVG easily in a browser of mobile, we generate an HTML template as follows:

{{< highlight auto >}}
<!doctype html>
<html class="no-js" lang="">                                                                                                                          

<head>                                                                                                                                                
  <meta charset="utf-8">                                                                                                                              
  <meta http-equiv="x-ua-compatible" content="ie=edge">                                                                                               
  <title>Linux Sysstat Page</title>                                                                                                                   
  <meta name="description" content="">                                                                                                                
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">                                                              
  <style>                                                                                                                                             
    .svg-container {                                                                                                                                  
      display: inline-block;                                                                                                                          
      vertical-align: middle;                                                                                                                         
    }                                                                                                                                                 
    .svg-content {                                                                                                                                    
      display: inline-block;                                                                                                                          
      top: 0;                                                                                                                                         
      left: 0;                                                                                                                                        
    }                                                                                                                                                 
  </style>                                                                                                                                            
</head>                                                                                                                                               

<body>                                                                                                                                                
  <!--[if lte IE 9]>                                                                                                                                  
    <p class="browserupgrade">You are using an <strong>outdated</strong> browser. Please <a href="https://browsehappy.com/">upgrade your browser</a> t
o improve your experience and security.</p>                                                                                                           
  <![endif]-->                                                                                                                                        

<div class="svg-container">                                                                                                                           
  <object type="image/svg+xml" data="stats.svg" width="1024px" height="9000px" class="svg-content">                                                   
  </object>                                                                                                                                           
</div>                                                                                                                                                

</body>                                                                                                                                               

</html> 
{{< /highlight>}}

And save it as ```/var/www/sar/index.html```. 

The size specified in the SVG object was generated taking into account our output from the ```sadf``` tool. It might change if your options change, so update it accordingly.

### Resources
 - [Demo](https://sar.slackware.es)
 - [Home page](http://sebastien.godard.pagesperso-orange.fr/)
 - [systsat tutorial](http://sebastien.godard.pagesperso-orange.fr/tutorial.html)

