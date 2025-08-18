##### c.Application #####
c.Application.log_level = 'DEBUG'
# Note : The following should inherit from this :
#     c.JupyterApp.log_level = 'DEBUG'
#     c.ExtensionApp.log_level = 'DEBUG'
#     c.LabServerApp.log_level = 'DEBUG'
#     c.ServerApp.log_level = 'DEBUG'

##### c.JupyterApp #####

##### c.ExtensionApp #####
c.ExtensionApp.open_browser = False
# Note : The following should inherit from this :
#     c.LabServerApp.open_browser = False
#     c.LabApp.open_browser = False
#     c.ServerApp.open_browser = False

##### c.LabServerApp #####

##### c.LabApp #####

##### c.ServerApp #####
c.ServerApp.allow_origin = '*'
# c.ServerApp.allow_remote_access = True # Probably not needed
c.ServerApp.allow_root = True
c.ServerApp.base_url = '/jupyter/'
c.ServerApp.iopub_data_rate_limit = 10_000_000_000
# I should probably change the above to: c.ServerApp.limit_rate = False
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8000 # Not sure if it's needed
c.ServerApp.port_retries = 0
c.ServerApp.root_dir = '/home/enrices'
c.ServerApp.iopub_msg_rate_limit = 10000.0
# The hash below has been generated using `/opt/anaconda3/bin/python -c "from jupyter_server.auth import passwd; print(passwd())"`
# This hash is very strong, and safe to push on a public Github
c.ServerApp.password = 'argon2:$argon2id$v=19$m=10240,t=10,p=8$4KRqMxQCM0mwu1xpJX2F9A$4YZx8KIogxe8RyYs2DIcDPwzxe5MQOfDhOk+0ItLT/A'

