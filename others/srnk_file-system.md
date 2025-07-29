---
id: srnk
created_at:
  date: 2025-07-27
  time: 19:14
tags:
  - note
---
# file-system
- **Btrfs**: modern filesystem with support for *snapshots*, compression, and *subvolumes*.
- **LUKS**: full-disk *encryption* for data security in case the laptop is lost or stolen.
- **Subvolumes**: used to *separate* system (/), user data (/home), logs, etc., *for better snapshot* and management granularity.
- **/home snapshots**: enable *daily backups of user data* with *minimal disk space overhead*; useful for undoing accidental changes or deletions.
```
mnt/
└── btrfs-root
    ├── @            → /
    ├── @home        → /home           ← this is the one you snapshot
    ├── @nix         → /nix
    ├── @log         → /var/log        (optional)
    └── snapshots
        └── home     → storage for /home snapshots
```


## Benefits of Btrfs Compression
**Saves disk space:**
  - *Text-heavy data* (source code, logs, configs): often compresses by *40–70%*
  - *Mixed system data* (e.g. /nix/store): usually *20–50%* savings
  - *Binary files*: varies, sometimes little to *no gain*

**Can improve performance:**
  - *Less actual data* is read/written to disk
  - **zstd** is fast and offers a good size/speed balance

