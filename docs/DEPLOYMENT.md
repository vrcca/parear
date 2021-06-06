# Deployment

Currently this app is deployed in hetzner.com. It uses Ansible and Dokku to manage the app deployments and infrastructure.

## Local environment

1. Install ansible: `brew install ansible`
2. Install the dependencies: `ansible-galaxy install -r playbooks/requirements.yaml`

## Preparing Hetzner Cloud

1. Create an application through in console.hetzner.cloud.
2. Generate an API Key in "Security" menu.
3. Export it to `HCLOUD_TOKEN` environment variable.
4. Export the `SECRET_KEY_BASE` environment variable.


## Preparing Cloudflare

1. Import your domain in Cloudflare.com
2. Create an API token: https://dash.cloudflare.com/profile/api-tokens
3. Export it to `CLOUDFLARE_TOKEN` environment variable.

## Deployment 
 Ansible should do all the heavy lifting.

 Before you deploy, review `host_vars/localhost.yaml`. After that, just run:
```
ansible-playbook -u root -i hcloud.yaml -e vps_server_name=parear -e deploy.yml
```
