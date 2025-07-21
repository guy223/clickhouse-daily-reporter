# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Python-based ClickHouse Daily Reporter that automatically executes queries and generates Excel reports. The tool is designed for Kubernetes environments with kubectl port-forwarding support and includes comprehensive logging and cron scheduling.

## Key Commands

### Setup and Installation
```bash
# Install dependencies and setup
bash setup.sh

# Setup cron scheduling (runs daily at 9:30 AM)
bash setup_cron.sh

# Initialize git repository and GitHub setup
bash git_setup.sh
```

### Development and Testing
```bash
# Run the reporter manually
uv run python main.py

# Install Python dependencies
uv sync

# Check logs
cat logs/reporter_$(date +%Y%m%d).log
cat logs/cron_$(date +%Y%m%d).log
```

### Configuration
```bash
# Edit main configuration
vi config.yaml

# View example configuration
cat config.example.yaml
```

## Architecture

### Core Components

1. **ClickHouseReporter Class** (`main.py:22-425`)
   - Main orchestrator class handling configuration, connections, and execution
   - Supports both direct connections and kubectl port-forwarding
   - Manages connection lifecycle and cleanup

2. **Connection Management**
   - **Direct Connection** (`main.py:135-150`): Standard ClickHouse HTTP connection
   - **kubectl Port-forwarding** (`main.py:152-196`): Kubernetes pod access with automatic port forwarding
   - **Port Forward Lifecycle** (`main.py:207-284`): Process management with cleanup handlers

3. **Query Execution Engine** (`main.py:296-318`)
   - Executes multiple queries defined in configuration
   - Converts results to pandas DataFrames
   - Comprehensive error handling and logging
   - Type safety checks for null query_info and client connections

4. **Excel Report Generation** (`main.py:320-380`)
   - Multi-sheet Excel files with automatic formatting
   - Header styling and column width optimization
   - Date-based file naming
   - Safe handling of workbook operations with null checks

### Configuration System

The `config.yaml` file supports:
- **Connection types**: `direct` or `kubectl`
- **Multiple queries**: Each with name and SQL definition
- **Output customization**: Directory and filename prefixes
- **kubectl settings**: Pod name, namespace, port forwarding configuration

### Key Design Patterns

- **Resource Management**: Automatic cleanup of connections and port-forwarding processes
- **Signal Handling**: Graceful shutdown on SIGTERM/SIGINT
- **Error Recovery**: Fallback connection methods and comprehensive logging
- **Extensible Query System**: Configuration-driven query definitions
- **Type Safety**: Comprehensive null checks and defensive programming for robustness

## File Structure

```
clickhouse_reporter/
├── main.py              # Main application with ClickHouseReporter class
├── config.yaml          # Runtime configuration (git-ignored)
├── config.example.yaml  # Example configuration template
├── requirements.txt     # Python dependencies
├── setup.sh            # Installation and setup script
├── setup_cron.sh       # Cron scheduling setup
├── git_setup.sh        # Git initialization and GitHub setup
├── logs/               # Execution logs (git-ignored)
├── output/             # Excel reports (git-ignored)
└── .venv/             # uv virtual environment (git-ignored)
```

## Dependencies

Python dependencies are managed using `uv` and defined in `pyproject.toml`:

- `clickhouse-connect>=0.6.0` - ClickHouse client library
- `pandas>=1.5.0` - Data manipulation and analysis
- `PyYAML>=6.0` - YAML configuration parsing
- `openpyxl>=3.1.0` - Excel file generation

Use `uv sync` to install all dependencies.

## Development Notes

### When adding new queries:
1. Add query configuration to `config.yaml` under `queries` section
2. Each query needs `name` (Excel sheet name) and `query` (SQL statement)
3. Test manually before setting up cron

### When modifying connection logic:
- The connection system supports both direct and kubectl modes
- Port forwarding processes are managed with proper cleanup
- Always test both connection types if making changes

### When updating Excel formatting:
- Styling logic is in `create_excel_file()` method
- Column width calculation has max limit of 50 characters
- Header styling uses blue background with white text
- Safe workbook operations with null checks to prevent type errors

### Code Quality and Type Safety:
- All critical paths include null/undefined checks
- Query execution validates client connection state
- Excel operations handle optional worksheet references safely
- Pylance warnings are addressed with defensive programming

### Testing in different environments:
- WSL2 Ubuntu is the primary tested environment
- ClickHouse 24.1.2.5 is the tested version
- kubectl port-forwarding requires proper Kubernetes context setup

## Security Considerations

- `config.yaml` is git-ignored to prevent credential exposure
- Use `config.example.yaml` as a template with masked credentials
- Logs may contain query text but not credentials
- Port forwarding uses local ports only