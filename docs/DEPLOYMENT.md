# Deployment

Currently this app is deployed in hetzner.com. It uses Ansible and Dokku to manage the app deployments and infrastructure.

## Local environment

1. Install ansible: `brew install ansible`
2. Install hcloud: `pip install hcloud`

## Preparing Hetzner Cloud

1. Create a server.
1. Create an API Key in "Security"
2. Export it to `HCLOUD_TOKEN` environment variable.


## Deployment 
Ansible should do all the heavy lifting. So just run:
```
ansible-playbook -i hcloud.yml -e vps_server_name=parear deploy.yml
```
