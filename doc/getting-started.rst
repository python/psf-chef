Getting started with this repo
==============================

The goal of this document is to get you to a working state with the repo.

By the end of this you should be able to run these commands:

* `bundle exec knife node list`
* `bundle exec berks list`
* `bundle exec rake docs`

Configuration
-------------

The repository uses two configuration files.

* `config/rake.rb`
* `.chef/knife.rb`

The first, `config/rake.rb` configures the Rakefile in two sections.

* Constants used in the `ssl_cert` task for creating the certificates.
* Constants that set the directory locations used in various tasks.

If you use the `ssl_cert` task, change the values in the `config/rake.rb` file appropriately. These values were also used in the `new_cookbook` task, but that task is replaced by the `knife cookbook create` command which can be configured below.

The second config file, `.chef/knife.rb` is a repository specific configuration file for knife. If you're using the Opscode Platform, you can download one for your organization from the management console. If you're using the Open Source Chef Server, you can generate a new one with `knife configure`. For more information about configuring Knife, see the Knife documentation.

http://help.opscode.com/faqs/chefbasics/knife

Setting up a development environment
------------------------------------

Some things you'll need:

  * this repo, cloned locally
  * ruby 1.9
  * the chef validator key
  * a valid chef client key

Some things to consider:

  * rbenv: https://github.com/sstephenson/rbenv (via rbenv installer https://github.com/fesplugas/rbenv-installer)

Some common steps:

::

    $ gem install bundler

    # get our ruby dependencies
    # Create local binstubs and install the gems right here.
    $ bundle install --binstubs --path .gems

    # get our chef cookbook dependencies
    $ bundle exec berks install

Managing Cookbooks
------------------

We use berkshelf to manage our cookbooks and dependencies. Berkshelf is
straight forward.

To get started with it, look here: http://berkshelf.com/

From the command line, it looks like this:

List all of our cookbooks

::

    $ bundle exec berks list

Install all our 3rd party dependencies

::

    $ bundle exec berks install

Upload a cookbook managed by berkshelf

::

    $ bundle exec berks upload <cookbook>

Create a new cookbook

::

    $ bundle exec berks cookbook <cookbook_name>
