name "pypi"
description "Python package index server"
run_list 'recipe[psf-pypi::pgbouncer]'
