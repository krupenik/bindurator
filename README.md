# UNBIND

[![Code Climate](https://codeclimate.com/github/krupenik/unbind.png)](https://codeclimate.com/github/krupenik/unbind)
[![Build Status](https://travis-ci.org/krupenik/unbind.png?branch=master)](https://travis-ci.org/krupenik/unbind)

ISC BINDv9 config generator

## Installation

    gem install unbind

## Usage

    $ unbind [-c <config file>] command

      Commands:
        master                      generate named.conf for master
        slave                       generate named.conf for slave
        zone zone_name [view_name]  generate zone file for view

      Options:
        -c                          config file to use
