Remote Jump Tool
================

`impacket-jump.py` is a PsExec-style service manager built on top of [`Impacket`](https://github.com/fortra/impacket). I started writing it after seeing Cobalt Strike and Sliver rely on built-in BOF lateral-movement loaders that always deploy their stock implant binaries. This tool keeps the familiar workflow but lets you upload any *custom* service loader (for example, one that reflects your own shellcode or payload staging logic) so you can blend into an environment while retaining full control of what ultimately runs.

Features
--------

* End-to-end remote service deployment using pure SMB/DCE-RPC (no agent required on the target).
* `-create` and `-start` flows to decouple payload staging from execution, enabling offline prep work.
* `-share-path` targeting so you can force uploads into specific shares/directories where you have permissions.
* Randomized remote binary names and automatic cleanup helpers to minimize forensic footprints.
* Service metadata management (display-name + description) via `ChangeServiceConfig2W`.

Requirements
------------

* Python 3.10+ (the repository uses a local virtual environment under `.venv`).
* `Impacket` (already installed via `pip install -r requirements.txt`).
* A compiled custom service loader to upload to the target.
* Credentials (username/password, NTLM hashes, or Kerberos tickets) with permissions to create/start services on the victim host.

Usage – Remote Jump Tool
---------------------

`impacket-jump.py` focuses on managing long-lived service implants. You can stage binaries, set descriptions, and drive service lifecycles in discrete steps:

```pwsh
python impacket-jump.py DOMAIN/user:'Passw0rd!'@10.0.0.15 \
	-file "C:\path\to\Jump.exe" \
	-service-name JumpSvc \
	-service-display-name "Jump Loader" \
	-service-description "Managed via Impacket" \
	-share-path "C$\Program Files\Notepad++" \
	-create

# Start later without re-uploading
python impacket-jump.py DOMAIN/user:'Passw0rd!'@10.0.0.15 -service-name JumpSvc -start
```

Available actions (mutually exclusive): `-create`, `-start`, `-stop`, `-delete`, `-cleanup`, `-info`, `-change-info`.

Demo
---------------------
[Watch the PoC video](https://github.com/user-attachments/assets/673d4828-8d62-4518-bee7-dbf718abd850)

Credits
-------

* Impacket-jump builds on the excellent [`Impacket`](https://github.com/fortra/impacket) project by Fortra, LLC (formerly SecureAuth Corp). All SMB/DCE-RPC plumbing and the base `serviceinstall` helper originate from `Impacket`.
* Portions of the client shell, service installer, and protocol structures are adapted from the official `Impacket` examples (`psexec.py`, `smbexec.py`, `atexec.py`).

Please ensure any redistribution complies with `Impacket`’s Apache 2.0 license and attribute the original authors accordingly.
