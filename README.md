# Duplicity Backup Scripts

Backup scripts for use with Duplicity.

To make a feature request, or to report an issue, please [submit a new GitHub issue](https://github.com/NFarrington/duplicity-backup-scripts/issues/new).

## Requirements

* [Duplicity](http://duplicity.nongnu.org/)
* [B2 Command Line Tool](https://github.com/Backblaze/B2_Command_Line_Tool)

## Setup

To begin, copy the example configuration files:

```bash
cp includes/config-global.sh.example includes/config-global.sh
cp includes/config-mysql.sh.example includes/config-mysql.sh
cp includes/config-postgres.sh.example includes/config-postgres.sh
cp includes/config-server.sh.example includes/config-server.sh
```

Then, modify `config-global.sh` and any of the other configuration files for the scripts you intend to use. For example, if you intend to use MySQL backups, you should also modify `config-mysql.sh`.

You should use a different bucket for each backup type.

## Usage

All scripts - the backup, status, and restore scripts - use the configuration from `includes/config-global.sh`, and their respective configuration file (e.g. `backup-mysql.sh` uses `includes/config-mysql.sh`). These must be configured before using any of the scripts.

The backup and status scripts are to be run as-is. The backup script will generate a backup, according to the configuration. The status script will report the status of the backups.

The restoration script requires arguments to be run:

```bash
restore.sh <date> <file> <restore-to>
```

## License

Licensed under the [MIT license](https://opensource.org/licenses/MIT).
