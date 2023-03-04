## Setup

Install dependencies:

```
ansible-galaxy install -r requirements.yml
```

## Host boostrapping

Add the new host(s) to `hosts.yml`

Create ansible user & group with:

```
ansible-playbook bootstrap.yml -i hosts.yml -k -K --extra-vars "host=<host> user=james"
```
