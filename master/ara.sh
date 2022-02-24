# Configure Ansible to use the ARA callback plugin
export ANSIBLE_CALLBACK_PLUGINS="$(python3 -m ara.setup.callback_plugins)"

# Set up the ARA callback to know where the API server is located
export ARA_API_CLIENT="http"
export ARA_API_SERVER="http://ansible-ara:8000"
