# Install PYENV

Scripts to Install PYENV on Debian and Redhat-based Machines

## How to Run the Script

1. Git clone the repository
```bash
   git clone https://github.com/sunilvashista/pyenv.git
```
   or
```bash
   git clone git@github.com:sunilvashista/pyenv.git
```

2. Run playbook
### To install to current user home directory
```bash
ansible-playbook setup_pyenv.yaml -e ansible_connection=local
```
### To Install to a Custom Path
```bash
PYENV_ROOT=/PATH/TO/PYENV/ROOT ansible-playbook setup_pyenv.yaml
```
