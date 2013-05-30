Generating these docs
======================

The goal of this document is to outline how to generate these documents and
where they land.

By the end of this you should have a full copy of this documentation.

Prerequisites
-------------

You'll need the python `sphinx` package.

Your distribution may have a package for this, but you may also be able to
install it with python package tools like so:

::

  $ pip install sphinx

Or with `easy_install`:

::

  $ easy_install sphinx


Checkout the docs branch
------------------------

::

    $ git checkout docs

Generate a local copy of the docs
----------------------------------

This will generate html from our documentation, and place it in
`./doc/_build/html`

::

    $ bundle exec rake docs

Generate a single module of the documentation
----------------------------------------------

Say you want to generate only the node documentation

::

    $ bundle exec rake docs:nodes

Or maybe you want to generate only the html

::

   $ bundle exec rake docs:html

Manually publish this documentation
--------------------------

Typically our documentation should be automatically generated. Just in case
you want to publish it manually, you can do this.

::

  $ bundle exec rake docs:publish
