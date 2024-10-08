# frozen_string_literal: true

# These tryouts test the customer custom domain relations


require_relative '../lib/onetime'

# Load the app
OT::Config.path = File.join(__dir__, '..', 'etc', 'config.test')
OT.boot! :app

# Setup some variables for these tryouts
@now = Time.now
@email_address = "tryouts+#{@now.to_i}@onetimesecret.com"
@cust = OT::Customer.new @email_address

@valid_domain = 'another.subdomain.onetimesecret.com'
@input_domains = [
  'example.com',
  'subdomain.example.com'
]

# TRYOUTS

## Customer has a custom domain list
@cust.custom_domains.class
#=> Array

## Customer's custom domain list is stored as a sorted set
@cust.custom_domains_list.class
#=> Familia::SortedSet

## Customer's custom domain list is empty to start
@cust.custom_domains.empty?
#=> true

## Ditto for the sorted set
@cust.custom_domains_list.empty?
#=> true

## A customer's custom_domain list updates when a new domain is added
OT::CustomDomain.create(@valid_domain, @cust)
@cust.custom_domains.empty?
#=> false

## A customer's custom_domain list updates when a new domain is added
custom_domain = OT::CustomDomain.load(@valid_domain, @cust)
[custom_domain.class, custom_domain[:display_domain]]
#=> [OT::CustomDomain, @valid_domain]

## A customer's custom_domain list updates when a new domain is added
@cust.custom_domains_list.first
#=> @valid_domain

## A customer's custom_domain list updates when a new domain is added
custom_domain = @cust.custom_domains.first
[custom_domain.class, custom_domain[:display_domain]]
#=> [OT::CustomDomain, @valid_domain]

## A customer's custom_domain list updates when an existing domain is removed
custom_domain = @cust.custom_domains.first
@cust.remove_custom_domain(custom_domain)
#=> true

## A customer's custom_domain list is empty again after removing a domain
@cust.custom_domains.empty?
#=> true
