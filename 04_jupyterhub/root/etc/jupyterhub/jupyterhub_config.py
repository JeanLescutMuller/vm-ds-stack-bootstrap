# Configuration file for jupyterhub.
# Note : for a full list of configurable settings, please look at /etc/jupyterhub/jupyterhub_config.py.backup
c.JupyterHub.ip = '0.0.0.0'
c.JupyterHub.base_url = '/jupyterhub/'
c.JupyterHub.port = 8000 # This is the default value anyway
c.JupyterHub.proxy_auth_token = 'fead153769cc8d79b24e265b818065151e3814bb33733e7ea6493f24f91ebdaa'
c.JupyterHub.log_level = 'DEBUG'

c.NotebookApp.iopub_data_rate_limit = 10000000000
#c.NotebookApp.allow_origin = '*'

c.Application.log_level = 'DEBUG'
c.Spawner.cmd = '/opt/anaconda3/bin/jupyterhub-singleuser' # To resolve a bug : Jupyterhub doesnt find the spawner
c.Spawner.notebook_dir = '~' # Every user will have its own folder, in its home folder
c.Spawner.args = ['--NotebookApp.iopub_data_rate_limit=1000000000'] # To allow Jupyterhub to launch plotly figures
c.Spawner.debug = True
c.LocalProcessSpawner.debug = True
