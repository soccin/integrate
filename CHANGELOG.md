# Changelog

All notable changes to the INTEGRATE fusion detection pipeline
will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-10-27

### Added

- **Multi-cluster support infrastructure**
  - Added `bin/getClusterName.sh` for automatic JUNO/IRIS cluster
    detection via network subnet analysis or environment variables
  - Created cluster-specific bundle configuration files:
    - `starmap/bundle.JUNO.human_b37`
    - `starmap/bundle.IRIS.human_b37`
  - Dynamic path selection in core pipeline scripts based on
    detected cluster environment

- **SLURM scheduler support**
  - Added SBATCH directives to `integrateFusionCalls.sh` (3 day
    runtime, 18 CPUs, 144GB memory, test01 partition)
  - Added SLURM support to STAR alignment scripts with proper
    directory detection via SBATCH_SCRIPT_DIR
  - Maintains backward compatibility with existing LSF
    configuration

- **Enhanced script robustness**
  - Argument validation and usage help for `starAlignFusion.sh`
  - Error handling with `set -e` in main pipeline script
  - Cluster validation with informative error messages
  - Bundle file existence validation

- **Comprehensive documentation**
  - `CLAUDE.md` - Guide for Claude Code AI-assisted development
  - `docs/integrate_documentation.md` - Complete technical guide
    for interpreting INTEGRATE results
  - `docs/integrate_quick_guide.md` - Quick reference for result
    prioritization
  - `docs/MAKE_DOCS.sh` - Professional PDF generation script
  - `CMDS_Example.sh` - Complete workflow examples from STAR
    alignment through fusion calling
  - Expanded README with Quick Start section and detailed usage
    instructions
  - Clarified manifest format requirements (emphasizing no-header
    requirement)
  - Added documentation for tumor-only vs tumor/normal analysis
    workflows

### Fixed

- Corrected path to `getClusterName.sh` script in main pipeline
  (`../bin/` to `bin/`)
- Updated cluster network detection to use 10.x subnet search
  after infrastructure changes
- Fixed SLURM output directory path in STAR alignment script
  (now `SLM/starAlign_%j.out`)
- Updated Picard invocation to use cluster-specific JAR paths
  instead of picardV2 wrapper
- Resolved bundle file path resolution by adding `$SDIR` prefix
  for correct relative path handling
- Improved SLURM script directory detection and bundle
  validation in starmap scripts

### Changed

- Renamed `CMDS_Sample.sh` to `CMDS_Example.sh` for clearer
  documentation
- Replaced generic `bundle.human_b37` with cluster-specific
  configurations
- LSF BSUB directives now commented in favor of SBATCH headers

## [1.0.0] - 2025-08-16

Initial release of the INTEGRATE fusion detection pipeline.

### Features

- Core fusion detection pipeline using INTEGRATE algorithm
- Support for tumor-only and tumor/normal analysis workflows
- STAR alignment scripts optimized for fusion detection
- R scripts for manifest generation and result parsing
- LSF job scheduler integration
- Human genome b37 reference support

[1.1.0]: https://github.com/soccin/integrate/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/soccin/integrate/releases/tag/v1.0.0
