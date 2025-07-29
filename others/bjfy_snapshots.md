---
id: bjfy
created_at:
  date: 2025-07-28
  time: 13:49
tags:
  - note
---
# snapshots

# NixOS Filesystem & Snapshot Strategy Summary

## 1. The Filesystem Layout: Flat is Better

The core of the strategy is a **flat Btrfs subvolume layout** on top of a LUKS encrypted partition.

*   **Flat Layout:** All subvolumes are created at the top level of the Btrfs filesystem. They are siblings.
    ```
    BTRFS_ROOT/
    ├── @root  (mounted on /)
    ├── @home  (mounted on /home)
    ├── @nix   (mounted on /nix)
    └── @var   (mounted on /var)
    ```
*   **Nested Layout (to be avoided):** Subvolumes are created inside other subvolumes. This is problematic because snapshotting the parent subvolume also snapshots the children, preventing independent rollbacks.

**Key Advantage of Flat Layout:** It allows you to take snapshots of the system (`@root`) and your personal data (`@home`) **independently**.


## 2. Snapshotting Strategy: System vs. User Data

The goal is to separate the management of the operating system from your personal files.

*   **System Snapshots (`@root`):**
    *   **Purpose:** To recover from a broken NixOS update or a misconfiguration.
    *   **How it works:** You can roll back your entire system to a previous state without affecting your `/home` directory.
    *   **Integration:** These snapshots should be tied to NixOS generations. Tools like `snapper` can automatically create a "pre" and "post" snapshot every time you run `nixos-rebuild`.

*   **User Data Snapshots (`@home`):**
    *   **Purpose:** To protect your personal files from accidental deletion or changes.
    *   **How it works:** You can restore individual files or your entire home directory without having to roll back the operating system.
    *   **Schedule:** These snapshots are typically taken on a regular schedule (e.g., daily, hourly).


## 3. Tools for the Job

*   **`disko`:** Use this to declaratively set up the entire disk layout (partitions, LUKS, Btrfs subvolumes) from within your NixOS configuration.
*   **`snapper` or `btrbk`:** These are the recommended tools for automating the creation and management of Btrfs snapshots. They integrate well with NixOS.
*   **`grub-btrfs` / Bootloader Integration:** Some tools can automatically add your snapshots to the bootloader menu, making it extremely easy to boot into a previous system state for recovery.

By combining a flat Btrfs layout with an automated snapshotting tool, you get a system that is both resilient and easy to manage, fully leveraging the strengths of both NixOS and Btrfs.
