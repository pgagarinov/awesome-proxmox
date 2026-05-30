# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`vm-cloud-init-shell` is a set of Bash scripts that provision Cloud-Init–based VMs across a **Proxmox VE (PVE) cluster**. It is one subproject of the larger `awesome-proxmox` repo (siblings: `vyos-proxmox-kvm`, `postfix`, both Ansible-based). The scripts wrap the Proxmox CLI tools — there is no compiler, package manager, or test framework.

## Critical runtime constraints

- Scripts **only run on a PVE cluster node** (as root), not on a dev machine. They call `qm`, `pvesh`, `qemu-img`, and `virt-customize` (from `libguestfs-tools`), and read `/etc/pve/.vmlist`. Do not attempt to execute them locally.
- Every script reads its parameters from `Pz_*` **environment variables**. The scripts do NOT source `.env` themselves. The caller must export them first:
  ```
  cp ./.env.example ./.env   # then edit .env
  set -a; source ./.env; set +a
  ```
  When editing or reasoning about a script, treat `.env.example` as the source of truth for every variable's meaning and expected format.

## Architecture

The workflow is a **linear pipeline of single-purpose scripts**, each a stage operating on shared `Pz_*` state. Order matters:

```
download-cloud-init-images.sh   → fetch images, save with .orig extension
customize-cloud-init-images.sh  → virt-customize .orig images into .custom
create-template.sh              → build PVE template (ID = Pz_VM_TEMPLATE_ID)
create-vms.sh                   → clone template into N VMs, migrate across nodes
start-stop-vms.sh start|stop    → power control
destroy-vms.sh                  → remove the clones
destroy-template.sh             → remove the template
```

Batch wrappers compose these: `batch-create-start.sh` (create+start) and `batch-stop-destroy.sh` (stop+destroy). Both `test-happy-path-*.sh` scripts run the **real** full create/destroy cycle against the cluster — they are integration smoke tests, not unit tests, and they will create and delete actual VMs.

### Key conventions to preserve when editing

- **Image extension state machine**: `.orig` = downloaded original, `.custom` = customized output, `.mod` = throwaway working copy made by `create-template.sh`. `Pz_IMG_FILE_NAME` must point at either `.orig` or `.custom`. Downloads and customizations are atomic (write to `.tmp`, then `mv`) so partial files never get the canonical extension.
- **Distro dispatch by filename prefix**: `customize-cloud-init-images.sh` matches the image basename — `jammy*` → `_customize-ubuntu-jammy.sh`, `noble*` → `_customize-ubuntu-noble.sh`, otherwise a generic `virt-customize --install $Pz_CLOUD_INIT_INSTALL_PKG_LIST`. The `_customize-*.sh` scripts take the image path as `$1` and are **never called directly**. Add a new distro by adding a prefix branch here plus a matching `_customize-<distro>.sh`.
- **Array env vars** (`Pz_LINK_LIST`, `Pz_TARGET_NODE_LIST`) are stored as parenthesized strings and turned into Bash arrays via `eval "name=$Pz_..."`. Keep the surrounding quotes and parens when editing `.env`.
- **Generated identifiers**: per-VM ID, name, and static IP are formed by appending the loop index to `Pz_VM_ID_PREFIX` / `Pz_VM_NAME_PREFIX` / `Pz_VM_IP_PREFIX`. E.g. prefix `901` → IDs `9011, 9012, …`; IP prefix `10.1.2.1` → `10.1.2.11, …`. Watch for off-by-prefix surprises noted in `.env.example`.
- **Cluster awareness**: `create-vms.sh` migrates each clone to `Pz_TARGET_NODE_LIST[i]` unless it is already on the current `hostname`. `Pz_N_VMS` must be ≤ the length of `Pz_TARGET_NODE_LIST`.
- **Guard before mutate**: `start-stop-vms.sh`, `destroy-vms.sh`, and `destroy-template.sh` grep `/etc/pve/.vmlist` before acting, so they are safe to re-run when VMs are absent.
- **Storage/format coupling**: `Pz_DISK_FORMAT` (`raw` vs `qcow2`) must match `Pz_DATA_STORAGE_ID`'s capabilities; `create-template.sh` builds a different import disk path per format. See the storage-vs-format cheatsheet in `.env.example`.
- All scripts use `set -e` and `tput`-based colored status messages following a `printf "$msg...\n"` / `printf "$msg: done\n"` pattern. Match this style in new scripts. Templates always get `--ostype=l26`.

## Running

There is nothing to build. To exercise changes, run the relevant stage script (or a `batch-*`/`test-happy-path-*` wrapper) on a PVE node after exporting `.env`. Always validate a non-destructive stage (e.g. `download`/`customize`) before destructive ones, since destroy scripts purge disks (`-destroy-unreferenced-disks -purge`).
