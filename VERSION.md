# Version

**Current Release:** v1.1.0
**Release Date:** 2025-10-27

## About This Release

Version 1.1.0 adds multi-cluster deployment support and SLURM
scheduler compatibility to the INTEGRATE fusion detection
pipeline. This release enables seamless operation across both
JUNO and IRIS HPC clusters with automatic environment detection
and configuration.

### Key Features

- Dual cluster support (JUNO/IRIS) with automatic detection
- SLURM scheduler support alongside existing LSF compatibility
- Enhanced documentation including comprehensive result
  interpretation guides
- Improved script robustness with validation and error handling

### Breaking Changes

None. This release is fully backward compatible with v1.0.0.

### Upgrade Path

Users can upgrade directly from v1.0.0 without modification to
existing workflows. The pipeline will automatically detect the
cluster environment and configure appropriate paths.

---

See [CHANGELOG.md](CHANGELOG.md) for detailed release notes and
complete change history.

## Version History

| Version | Release Date | Description |
|---------|--------------|-------------|
| v1.1.0  | 2025-10-27   | Multi-cluster and SLURM support |
| v1.0.0  | 2025-08-16   | Initial release |
