# Prometheus Monitoring Mixin for CoreDNS
[![CircleCI](https://circleci.com/gh/povilasv/coredns-mixin/tree/master.svg?style=shield)](https://circleci.com/gh/povilasv/coredns-mixin)

A set of Prometheus alerts for CoreDNS.

## How to use

This mixin is designed to be vendored into the repo with your infrastructure config.
To do this, use [jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler):

You then have three options for deploying your dashboards
1. Generate the config files and deploy them yourself


## Generate config files

You can manually generate the alerts, dashboards and rules files, but first you
must install some tools:

```
$ go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
$ brew install jsonnet
```

Then, grab the mixin and its dependencies:

```
$ git clone https://github.com/povilasv/coredns-mixin
$ cd coredns-mixin
$ jb install
```

Finally, build the mixin:

```
$ make prometheus_alerts.yaml
```

The `prometheus_alerts.yaml` and `prometheus_rules.yaml` file then need to passed to your Prometheus server.


## Background

* For more information about monitoring mixins, see this [design doc](https://docs.google.com/document/d/1A9xvzwqnFVSOZ5fD3blKODXfsat5fg6ZhnKu9LK3lB4/edit#).
* CoreDNS Prometheus metrics plugin [docs](https://github.com/coredns/coredns/tree/master/plugin/metrics)
