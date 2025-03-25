# Shibboleth SP - Ansible Role

This Ansible role spins up a Docker container, meant to be run in Docker Swarm mode, that runs a Shibboleth daemon and Apache service with Supervisor.

## Installation

Create a requirements.yml, within your `ansible/roles` dir, and add the repo:

```
roles:
  - src: https://example/devops/ansible/shibboleth_sp.git
    scm: git
```

Install the new role by running (update the path accordingly):

```
ansible-galaxy install -p ansible/roles -r ansible/roles/requirements.yml
```

It is best to not commit the role to your repo therefore ignore the role by adding it to your .gitignore (update the path accordingly): `ansible/roles/shibboleth_sp`

Copy the `shibboleth` dict [default/main.yml](default/main.yml) and add it to your inventory (either directly in your vars.yml file or keep it separate by creating a new file and placing the definitions there). Update the values with data relevant to your application - ensuring sensitive information is stored within Ansible vault. You can [customize any of the configs and templates](#customizing-configs-and-templates) to suit your needs.

## Playbook Setup

Since this service is intended to sit in front of an existing application it will often be necessary to have both applications running on the same network.
As such it will be necessary to first create the docker network using the available task ([tasks/create_docker_network.yml](tasks/create_docker_network.yml))
before starting your application and the shibboleth service. For example:

```
- hosts: swarm_managers
  become: yes
  tasks:
    - include: "roles/shibboleth_sp/tasks/create_docker_network.yml"

...

- hosts: swarm_managers
  become: yes
  roles:
    - my_application
    - shibboleth_sp

```

## Configs and Templates

| File                              | Description                                                                                                                                           |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| apache/shib2.conf.j2              | Basic configuration for default VirtualHost with Shibboleth provider - ServerName and ServerAdmin to be provided via ansible variable stored in vault |
| shibboleth/attribute_map.xml.j2   | Sample Shibboleth attribute mappings                                                                                                                  |
| shibboleth/metadata.xml.j2        | Supplies Shibboleth metadata - value to be provided via ansible variable stored in vault                                                              |
| shibboleth/shibboleth2.xml.j2     | Sample Shibboleth configuration - SP/IDP entityId's to be provided via ansible variable stored in vault                                               |
| shibboleth/sp_encrypt_cert.pem.j2 | Supplies Encryption Cert - value to be provided via ansible variable stored in vault                                                                  |
| shibboleth/sp_encrypt_key.pem.j2  | Supplies Encryption Key - value to be provided via ansible variable stored in vault                                                                   |
| shibboleth/sp_signing_cert.pem.j2 | Supplies Signing Cert - value to be provided via ansible variable stored in vault                                                                     |
| shibboleth/sp_signing_key.pem.j2  | Supplies Signing Key - value to be provided via ansible variable stored in vault                                                                      |

## Customizing Configs and Templates

This role has been created to allow you to override any of the included templates with your own templates. To do so you need to

- create a `templates` dir at the same level as your playbook
- add a new file to override the base file in the newly created `templates` dir
- update the appropriate path under `shibboleth.templates` or `shibboleth.configs` var you are changing

For example to override the `shib2.conf.j2` template you would create a file at the same level as your playbook located at `templates/shibboleth/apache/shib2.conf.j2`. Then in your local `shibboleth.yml` file you would set the new path:

```
shibboleth:
  ...
  templates:
    configs:
      shib2:
        path "shibboleth/apache/shib2.conf.j2"
        ...
```

## Encrypt and Signing Keys

To generate the encrypt key run the command (replacing the entityId and hostname accordingly):

```
shib-keygen -f -h example.edu -e entityID -y 10 -n sp_encrypt
```

To generate the signing key run the command (replacing the entityId and hostname accordingly):

```
shib-keygen -f -h example.edu -e entityID -y 10 -n sp_signing
```

The values of the keys and certs generated should then be added to the corresponding key:value pair in the Ansible vault for your project.

Generate

## Obtain SP Metadata

Once the keys have been generated and the role is active/running you can get the service provider metadata by navigating to [https://example.edu/Shibboleth.sso/Metadata](https://example.edu/Shibboleth.sso/Metadata). This will then need to be added to the Identity Provider.

## Role Variables

| Key                                                                            | Default Value                     | Description                                                                          | Should be Encrypted                         |
| ------------------------------------------------------------------------------ | --------------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------- |
| shibboleth.image.name                                                          | shibboleth_dev                    | Shibboleth Docker Image Name                                                         | No                                          |
| shibboleth.image.tag                                                           | latest                            | Shibboleth Docker Image Tag                                                          | No                                          |
| shibboleth.is_development                                                      | true                              | Whether to set to dev mode (will build the image rather than pull from the registry) | No                                          |
| shibboleth.swarm_node_constraint                                               | shibboleth                        | Node to constrain the docker container to                                            | No                                          |
| shibboleth.templates.configs.shib2.path                                        | apache/shib2.conf.j2              | Config File Path                                                                     | No                                          |
| shibboleth['templates']['configs']['shib2']['values']['admin_email']           | info@example.com                  | Email address used for Apache ServerAdmin                                            | Yes                                         |
| shibboleth['templates']['configs']['shib2']['values']['fqdn']                  | www.example.com                   | Domain of site (ensure protocol is not included)                                     | No - but may be necessary if using in vault |
| shibboleth.templates.configs.shib2.version                                     | 1                                 | Docker Config Version                                                                | No                                          |
| shibboleth.templates.secrets.attribute_map.path                                | shibboleth/attribute_map.xml.j2   | Template File Path                                                                   | No                                          |
| shibboleth.templates.secrets.attribute_map.version                             | 1                                 | Docker Secret Version                                                                | No                                          |
| shibboleth.templates.secrets.metadata.path                                     | shibboleth/metadata.xml.j2        | Template File Path                                                                   | No                                          |
| shibboleth['templates']['secrets']['metadata']['value']                        | test                              | Shibboleth IdP metadata - provided by the provider                                   | Yes                                         |
| shibboleth.templates.secrets.metadata.version                                  | 1                                 | Docker Secret Version                                                                | No                                          |
| shibboleth.templates.secrets.shibboleth2.path                                  | shibboleth/shibboleth2.xml.j2     | Template File Path                                                                   | No                                          |
| shibboleth['templates']['secrets']['shibboleth2']['values']['sp_entityID']     | 1234                              | Shibboleth SP EntityID - format = https:// + fqdn + /shibboleth                      | Yes                                         |
| shibboleth['templates']['secrets']['shibboleth2']['values']['idp_entityID']    | 1234                              | Shibboleth IdP EntityID - provided by the provider                                   | Yes                                         |
| shibboleth.templates.secrets.shibboleth2.version                               | 1                                 | Docker Secret Version                                                                | No                                          |
| shibboleth.templates.secrets.sp_encrypt_cert.path                              | shibboleth/sp_encrypt_cert.pem.j2 | Template File Path                                                                   | No                                          |
| shibboleth['templates'][secrets]['sp_encrypt_cert']['values']['sp_cert_pem']   | 1234                              | Shibboleth Encryption Cert                                                           | Yes                                         |
| shibboleth.templates.secrets.sp_encrypt_cert.version                           | 1                                 | Docker Secret Version                                                                | No                                          |
| shibboleth.templates.secrets.sp_encrypt_key.path                               | shibboleth/sp_encrypt_key.pem.j2  | Template File Path                                                                   | No                                          |
| shibboleth['templates']['secrets']['sp_encrypt_key']['values']['sp_key_pem']   | 1234                              | Shibboleth Encryption Key                                                            | Yes                                         |
| shibboleth.templates.secrets.sp_encrypt_key.version                            | 1                                 | Docker Secret Version                                                                | No                                          |
| shibboleth.templates.secrets.sp_signing_cert.path                              | shibboleth/sp_signing_cert.pem.j2 | Template File Path                                                                   | No                                          |
| shibboleth['templates']['secrets']['sp_signing_cert']['values']['sp_cert_pem'] | 1234                              | Shibboleth Signing Cert                                                              | Yes                                         |
| shibboleth.templates.secrets.sp_signing_cert.version                           | 1                                 | Docker Secret Version                                                                | No                                          |
| shibboleth.templates.secrets.sp_signing_key.path                               | shibboleth/sp_signing_key.pem.j2  | Template File Path                                                                   | No                                          |
| shibboleth['templates']['secrets']['sp_signing_key'][values]['sp_key_pem']     | 1234                              | Shibboleth Signing Key                                                               | Yes                                         |
| shibboleth.templates.secrets.sp_signing_key.version                            | 1                                 | Docker Secret Version                                                                | No                                          |

## Dockerfile

The Docker image for this Shibboleth service provider uses Ubuntu as a base image. Apache is used as the front end; Supervisor is used to manage the Shibboleth daemon and Apache service. There are several configuration files that must be mounted into the container as Docker configs/secrets in order to function properly (see the [docker-compose.yml file](files/docker-compose.yml) and [Configs and Templates](#configs-and-templates)).
