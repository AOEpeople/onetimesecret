# ONE-TIME SECRET - v0.10.1 (2018-06-27)

*Keep sensitive info out of your email & chat logs.*

## What is a One-Time Secret? ##

A one-time secret is a link that can be viewed only one time. A single-use URI.

## Dependencies

* Any recent Linux (we use Debian, Ubuntu, and CentOS)
* Ruby 1.9.1+
* Redis 2.6+

## Generating a global secret

We include a global secret in the encryption key so it needs to be long and secure. One approach for generating a secret:

    dd if=/dev/urandom bs=20 count=1 | openssl sha1

