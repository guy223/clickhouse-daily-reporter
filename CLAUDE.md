# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this ClickHouse Reporter codebase.

## Project Overview

ClickHouse Daily Reporter는 Kubernetes 환경에서 ClickHouse 클러스터에 대한 자동화된 쿼리 실행 및 Excel 리포트 생성을 담당하는 Python 애플리케이션입니다. kubectl port-forwarding을 통한 안전한 Pod 접근, 완전한 로깅 시스템, cron 기반 스케줄링을 지원합니다.

### 핵심 기능
- **다중 연결 타입**: 직접 연결과 kubectl port-forwarding 지원
- **Context Alias 시스템**: Kubernetes context를 별칭으로 관리 (`main.py:24-34`)
- **자동 리소스 관리**: 연결 및 프로세스 정리 자동화
- **타입 안전성**: 방어적 프로그래밍 및 null 체크
- **Excel 자동 포맷팅**: 헤더 스타일링 및 열 너비 최적화

## Key Commands

### Setup and Installation
```bash
# Install dependencies and setup environment
bash setup.sh

# Setup cron scheduling (daily 9:30 AM execution)
bash setup_cron.sh

# Git repository initialization and GitHub setup
bash git_setup.sh
```

### Development and Testing
```bash
# Manual execution
uv run python main.py

# Run with specific Kubernetes context
uv run python main.py --context prod

# Install/update dependencies  
uv sync

# Log monitoring
cat logs/reporter_$(date +%Y%m%d).log
cat logs/cron_$(date +%Y%m%d).log
```

### Configuration Management
```bash
# Edit runtime configuration
vi config.yaml

# View configuration template
cat config.example.yaml

# Environment-specific configs
cp config.yaml config.prod.yaml
CONFIG_FILE=config.prod.yaml uv run python main.py
```

## Architecture

### Core Components

1. **ClickHouseReporter Class** (`main.py:22-500+`)
   - Main orchestrator class with comprehensive connection and execution management
   - **Context Resolution System** (`main.py:24-34`, `main.py:48-60`): Kubernetes context alias mapping
   - **Lifecycle Management**: Automatic resource cleanup and signal handling
   - **Multi-environment Support**: Development, staging, production context switching

2. **Connection Management System**
   - **Direct Connection** (`main.py:~135-150`): Standard ClickHouse HTTP client
   - **kubectl Port-forwarding** (`main.py:~152-196`): Kubernetes Pod access via port forwarding
   - **Context-aware Connections**: Automatic context resolution and switching
   - **Connection Pooling**: Efficient resource utilization and cleanup

3. **Advanced Port Forward Management** (`main.py:~207-284`)
   - **Process Lifecycle**: Automatic subprocess management with proper cleanup
   - **Signal Handlers**: Graceful shutdown on SIGTERM/SIGINT signals
   - **Health Checks**: Port availability verification and retry logic
   - **Error Recovery**: Fallback mechanisms for connection failures

4. **Query Execution Engine** (`main.py:~296-318`)
   - **Multi-query Support**: Batch execution of configured queries
   - **Data Transformation**: Automatic pandas DataFrame conversion
   - **Error Isolation**: Per-query error handling without affecting others
   - **Type Safety**: Comprehensive null checks and defensive programming

5. **Excel Report Generation** (`main.py:~320-380`)
   - **Multi-sheet Workbooks**: Each query as separate Excel sheet
   - **Automatic Formatting**: Header styling, column width optimization
   - **Template System**: Consistent styling across all sheets
   - **Memory Management**: Efficient handling of large datasets

### Configuration Architecture

The `config.yaml` system supports:

```yaml
# Connection Configuration
clickhouse:
  connection_type: 'kubectl'|'direct'
  username: string
  password: string
  database: string
  host: string (direct only)
  port: int (direct only)
  
  kubectl:
    enabled: boolean
    pod_name: string
    namespace: string
    internal_port: int
    port_forward_local_port: int
    context: string (optional - uses alias resolution)

# Query Configuration  
queries:
  query_key:
    name: string (Excel sheet name)
    query: string (SQL statement)

# Output Configuration
output:
  directory: string
  filename_prefix: string
```

### Design Patterns

- **Context Resolution Pattern**: Alias-to-actual-name mapping for Kubernetes contexts
- **Resource Management Pattern**: RAII-style resource cleanup with context managers
- **Signal Handling Pattern**: Graceful shutdown registration and cleanup
- **Configuration-driven Architecture**: Zero-code query addition/modification
- **Defensive Programming**: Null checks, type validation, error isolation
- **Template Method Pattern**: Consistent Excel formatting across all reports

## File Structure

```
clickhouse_reporter/
├── main.py              # Main application with ClickHouseReporter class
│                        # - Context alias resolution system
│                        # - Connection management (direct/kubectl)
│                        # - Query execution engine
│                        # - Excel report generation
├── config.yaml          # Runtime configuration (git-ignored)
├── config.example.yaml  # Configuration template with examples
├── pyproject.toml       # uv package management and metadata
├── requirements.txt     # Pip compatibility (generated from pyproject.toml)
├── setup.sh            # Environment setup and dependency installation
├── setup_cron.sh       # Cron job configuration script
├── git_setup.sh        # Git repository initialization
├── README.md           # User documentation and usage guide
├── CLAUDE.md           # Development guide (this file)
├── logs/               # Application and cron execution logs (git-ignored)
│   ├── reporter_YYYYMMDD.log
│   └── cron_YYYYMMDD.log
├── output/             # Generated Excel reports (git-ignored)
│   └── daily_report_YYYYMMDD.xlsx
└── .venv/             # uv-managed virtual environment (git-ignored)
```

## Dependencies

### Core Dependencies (pyproject.toml)
```toml
[project]
name = "clickhouse-reporter"
version = "1.0.0"
requires-python = ">=3.8"
dependencies = [
    "clickhouse-connect>=0.6.0",  # ClickHouse HTTP client
    "pandas>=1.5.0",              # Data manipulation and analysis
    "PyYAML>=6.0",               # YAML configuration parsing
    "openpyxl>=3.1.0",           # Excel file generation and formatting
]
```

### Development Tools
- **uv**: Fast Python package manager and virtual environment
- **kubectl**: Kubernetes command-line tool (external dependency)
- **cron**: System scheduler (Linux/WSL)

### Installation
```bash
# Install all dependencies
uv sync

# Update dependencies
uv lock --upgrade
```

## Development Guidelines

### Adding New Queries
1. **Configuration**: Add query to `config.yaml` under `queries` section
   ```yaml
   queries:
     new_query_key:
       name: 'Sheet Name'  # Excel sheet name
       query: |            # SQL query (supports multi-line)
         SELECT column1, column2
         FROM table_name
         WHERE condition
         ORDER BY column1
   ```

2. **Testing**: Always test new queries manually before production
   ```bash
   uv run python main.py  # Test execution
   ```

3. **Validation**: Check generated Excel file for formatting and data accuracy

### Modifying Connection Logic

**Connection Types** (`main.py`):
- **Direct**: Standard HTTP connection to ClickHouse
- **kubectl**: Port-forwarding through Kubernetes Pod

**Key Considerations**:
- Connection lifecycle management with proper cleanup
- Context resolution system handles alias mapping
- Port forwarding processes require subprocess management
- Always test both connection types when making changes

**Testing Connection Changes**:
```bash
# Test direct connection
uv run python main.py

# Test kubectl with specific context
uv run python main.py --context prod

# Verify port forwarding cleanup
ps aux | grep kubectl
```

### Excel Formatting Updates

**Location**: `create_excel_file()` method in main.py

**Key Components**:
- **Header Styling**: Blue background (#4472C4), white text, bold font
- **Column Width**: Auto-calculated with 50-character maximum
- **Data Formatting**: Automatic type detection and appropriate formatting
- **Memory Management**: Efficient handling for large datasets

**Safety Patterns**:
```python
# Safe worksheet operations
if worksheet is not None:
    # Perform operations
    
# Null-safe column width calculation
max_width = min(max_length, 50) if max_length else 10
```

### Code Quality Standards

**Type Safety Requirements**:
- All critical paths include null/undefined checks
- Client connection validation before query execution
- Defensive programming for optional values
- Pylance warnings must be resolved

**Error Handling**:
- Per-query error isolation (one failure doesn't stop others)
- Comprehensive logging for debugging
- Graceful degradation on connection issues
- Resource cleanup on exceptions

**Example Defensive Pattern**:
```python
def safe_operation(self):
    if self.client is None:
        self.logger.error("Client not initialized")
        return None
    
    try:
        result = self.client.query(sql)
        return result if result is not None else []
    except Exception as e:
        self.logger.error(f"Query failed: {e}")
        return None
```

### Environment-Specific Development

**Context Management**:
- Use context aliases for different environments (dev, stg, prod)
- Context resolution happens at initialization
- Multiple context support for multi-environment deployments

**Environment Testing**:
```bash
# Development context
uv run python main.py --context dev

# Staging context  
uv run python main.py --context stg

# Production context
uv run python main.py --context prod
```

**WSL2 Considerations**:
- Primary tested environment: WSL2 Ubuntu
- ClickHouse version: 24.1.2.5+
- kubectl context setup required for Kubernetes connections

### Security Best Practices

**Credential Management**:
- `config.yaml` is git-ignored for security
- Use `config.example.yaml` as template with placeholder values
- No hardcoded credentials in source code
- Environment variable support for sensitive data

**Logging Security**:
- Query text logged for debugging (no credentials)
- Connection details masked in logs
- No sensitive data in error messages
- Log file rotation and cleanup

**Network Security**:
- kubectl port-forwarding uses localhost only
- No external port exposure
- Connection timeout and retry limits
- SSL/TLS support for direct connections

### Performance Optimization

**Query Performance**:
- Use `LIMIT` clauses for large result sets
- Consider query complexity and execution time
- Monitor memory usage during DataFrame conversion
- Batch processing for multiple queries

**Resource Management**:
- Automatic connection cleanup
- Process management for port-forwarding
- Memory-efficient Excel generation
- Log file rotation and cleanup