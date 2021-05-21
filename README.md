# SoftwareAG provisioner

This repository contains utilities to install **SoftwareAG webMethods** products on a single node using Command Central templates.

It makes use of the official Command Central Docker images to simplify provisioning, without having to preinstall anything on the host machine (except Docker). This approach also avoids having to install a local or shared Command Central instance, while still benefiting from mirroring and templates. At this time, this tool has only been tested with the webMethods 10.5 release.

These tools are provided as-is and without warranty or support. They do not constitute part of the Software AG product suite, and are not endorsed by SoftwareAG. Users are free to use, fork and modify them, subject to the license agreement.

## Prerequisites

To run container images, make sure to install [Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/) and have sufficient RAM available.

On Docker Hub, you will need to subscribe to the official [Command Central image](https://hub.docker.com/_/softwareag-commandcentral) with your account.

You will also need Empower credentials with access to the products you want to build, as well as valid license files in XML format. Create a ZIP archive of your license files in `licenses/licenses.zip`.

On the host machine, create the `/opt/softwareag` installation directory and `sagadmin` user:

```
useradd -u 1724 -U -d /opt/softwareag -m -s /bin/bash sagadmin
```

## Usage

### Local mirror

First, update variables in the `mirror.env` file with your Empower credentials and a list of artifacts to mirror.

To create a local mirror before installation, execute the following commands:

```
docker-compose run --rm mirror-installer
docker-compose run --rm mirror-repos
```

Downloaded data will be stored in the `mirror` directory. You may wish to share it between machines using NFS/rsync/etc. to avoid repeating this step for other nodes.

### Product provisioning

First, create or add your existing Command Central templates in the `templates/<template-name>` directory.

Each template directory must contain a `template.yaml` file, and may contain `customize.sh` and `test.sh` scripts that will be executed in this order after installation. A `sag-is-server` sample is provided for Integration Server.

For more information about Command Central templates, please see the [official documentation](https://documentation.softwareag.com/webmethods/command_central/cce10-5/10-5_Command_Central_webhelp/index.html) and the [SoftwareAG/sagdevops-templates](https://github.com/SoftwareAG/sagdevops-templates) repository.

To start provisioning a product on the local machine, execute the following command:

```
docker-compose run --rm provision <template-name>
```

This will first install Java and SPM on the host machine in `/opt/softwareag`, then install the product according to the template.

Make sure all installed products are **stopped** before running this command. You may run this command multiple times to install different products or adjust settings.

### Post-installation steps

To create systemd services for installed products, you may use commands such as the following:

```
# Register/enable/start Platform Manager (SPM)
/opt/softwareag/common/bin/daemon.sh -f /opt/softwareag/profiles/SPM/bin/sagspm105 -u sagadmin -n spm105 -i 1
systemctl enable --now sag1spm105

# Register/enable/start Integration Server
/opt/softwareag/common/bin/daemon.sh -f /opt/softwareag/profiles/IS_default/bin/sagis105 -u sagadmin -n is105 -i 1
systemctl enable --now sag1is105
```

### Troubleshooting

If necessary, you may also start a full Command Central Server and register the local node with the following commands:

```
docker-compose up -d cc
docker-compose run --rm sagcc add landscape nodes alias=node url="https://node:8093" -e OK -w 180 -c 20 --wait-for-cc
```

Make sure SPM is running on the host machine before registering it.
Then, access the Command Central web interface at `https://<hostname>:8091`
