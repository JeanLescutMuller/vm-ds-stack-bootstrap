# Configuration file for jupyterhub.

#------------------------------------------------------------------------------
# Configurable configuration
#------------------------------------------------------------------------------
# Note : for a full list of configurable settings, please look at /etc/jupyterhub/jupyterhub_config.py.backup

# Since we redirect user here with nginx, Jupyterhub has to be self-aware of its own location
c.JupyterHub.base_url = '/jupyterhub/'

# This is the IP adress we want to allow for accessing jupyterhub.
# Since only nginx can access it, we only allow localhost
c.JupyterHub.ip = '127.0.0.1'

# The port trough which Nginx access jupyterhub inside the machine
c.JupyterHub.port = 8000 # This is the default value anyway

# This is the location of certificates and keys, to make SSL work
c.JupyterHub.ssl_cert = '/etc/letsencrypt/live/luke.jeanl.me/fullchain.pem'
c.JupyterHub.ssl_key = '/etc/letsencrypt/live/luke.jeanl.me/privkey.pem'

