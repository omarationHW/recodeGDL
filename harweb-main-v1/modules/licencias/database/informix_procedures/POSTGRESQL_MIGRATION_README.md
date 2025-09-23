# PostgreSQL Migration for Licencias Vigentes Module

## Overview

This migration provides PostgreSQL compatibility for the Licencias Vigentes module, creating stored procedures that maintain compatibility with the existing INFORMIX syntax while working with PostgreSQL databases.

## Files Created/Modified

1. **POSTGRESQL_MIGRATION_SCRIPT.sql** - Complete PostgreSQL migration script
2. **02_SP_LICENCIAS_VIGENTES_PROCEDURES.sql** - Enhanced with PostgreSQL procedures
3. **POSTGRESQL_MIGRATION_README.md** - This documentation file

## Main Stored Procedure: sp_licencias_vigentes

### Purpose
Returns a paginated list of active/valid licenses from the municipal licensing system with filtering capabilities.

### Schema
Created in the `informix` schema for compatibility.

### Parameters
Accepts a single JSON text parameter with the following structure:

```json
{
  "busqueda": "text search filter (optional)",
  "giro": "business type ID (optional integer)",
  "anio": "year filter (optional integer)",
  "zona": "zone filter (optional integer)",
  "limite": "page limit (integer, default 25)",
  "offset": "page offset (integer, default 0)",
  "vigencia": "validity status ('todas'|'vigentes'|'condicionadas'|'suspendidas'|'vencidas')"
}
```

### Return Format
Returns a table with the following columns:

| Column | Type | Description |
|--------|------|-------------|
| id | integer | License ID |
| numero_licencia | varchar(50) | License number |
| propietario | varchar(255) | Owner full name |
| actividad | varchar(255) | Business activity |
| giro | varchar(255) | Business type description |
| direccion | varchar(500) | Full address |
| colonia | varchar(255) | Neighborhood |
| zona | integer | Zone number |
| fecha_vigencia_inicio | date | Validity start date |
| fecha_vigencia_fin | date | Validity end date |
| estado | varchar(20) | Status (VIGENTE, CONDICIONADA, SUSPENDIDA, OTRO) |
| total_registros | bigint | Total count for pagination |

### Frontend Usage Example

```javascript
const response = await this.$axios.post('/api/generic', {
  eRequest: {
    Operacion: 'sp_licencias_vigentes',
    Base: 'padron_licencias',
    Parametros: [
      {
        nombre: 'filtro',
        valor: JSON.stringify({
          busqueda: 'LIC-2024',
          giro: null,
          anio: 2024,
          zona: 1,
          limite: 25,
          offset: 0,
          vigencia: 'todas'
        })
      }
    ],
    Tenant: 'public'
  }
})
```

## Supporting Procedures

### informix.sp_giros_list()
Returns all active business types (giros).

**Returns:**
- id (integer): Business type ID
- nombre (varchar): Business type name
- clasificacion (varchar): Classification code
- activo (char): Active status

### informix.sp_zonas_list()
Returns all available zones from existing licenses.

**Returns:**
- id (integer): Zone number
- nombre (varchar): Zone display name
- descripcion (varchar): Zone description

### informix.sp_generar_licencia_pdf(p_licencia_id integer)
Placeholder for PDF generation functionality.

**Returns:**
- archivo_pdf (varchar): Generated PDF filename
- status (varchar): Operation status

### informix.sp_renovar_licencia(p_licencia_id integer)
Renews a license by extending its expiration date by one year.

**Returns:**
- status (varchar): Operation status
- mensaje (varchar): Result message

## Installation Instructions

### Prerequisites
- PostgreSQL 9.5 or higher
- plpgsql extension enabled
- Sufficient privileges to create schemas and functions

### Step 1: Run Migration Script
```sql
-- Connect to your target database
\c your_database_name

-- Run the migration script
\i POSTGRESQL_MIGRATION_SCRIPT.sql
```

### Step 2: Verify Installation
```sql
-- Check if schema was created
SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'informix';

-- Check if procedures were created
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'informix'
  AND routine_type = 'FUNCTION';

-- Test main procedure
SELECT * FROM informix.sp_licencias_vigentes('{"busqueda":null,"giro":null,"anio":null,"zona":null,"limite":5,"offset":0,"vigencia":"todas"}');
```

### Step 3: Update Database Configuration
Ensure your application's database configuration points to the PostgreSQL database and that the connection user has appropriate permissions.

## Table Requirements

The procedures expect the following table structure:

### licencias
```sql
CREATE TABLE licencias (
    id_licencia SERIAL PRIMARY KEY,
    licencia VARCHAR(50) UNIQUE,
    propietario VARCHAR(255),
    primer_ap VARCHAR(100),
    segundo_ap VARCHAR(100),
    actividad VARCHAR(255),
    id_giro INTEGER,
    ubicacion VARCHAR(255),
    numext_ubic INTEGER,
    letraext_ubic VARCHAR(10),
    colonia_ubic VARCHAR(255),
    zona INTEGER,
    fecha_otorgamiento DATE,
    fecha_vencimiento DATE,
    vigente CHAR(1) DEFAULT 'V',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### c_giros
```sql
CREATE TABLE c_giros (
    id_giro SERIAL PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL,
    clasificacion VARCHAR(10) DEFAULT 'GEN',
    activo CHAR(1) DEFAULT 'S',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Performance Considerations

### Indexes
The migration script creates the following indexes for optimal performance:

```sql
CREATE INDEX idx_licencias_vigente ON licencias(vigente);
CREATE INDEX idx_licencias_giro ON licencias(id_giro);
CREATE INDEX idx_licencias_zona ON licencias(zona);
CREATE INDEX idx_licencias_fecha_venc ON licencias(fecha_vencimiento);
CREATE INDEX idx_licencias_propietario ON licencias(propietario);
CREATE INDEX idx_licencias_numero ON licencias(licencia);
```

### Query Optimization
- The main procedure uses dynamic SQL with parameterized queries to prevent SQL injection
- Filtering is applied at the database level to minimize data transfer
- Total count is calculated separately for efficient pagination

## Error Handling

The procedures include comprehensive error handling:

1. **JSON Parsing Errors**: Invalid JSON parameters will raise descriptive exceptions
2. **Database Errors**: All database errors are caught and re-raised with context
3. **Parameter Validation**: NULL and empty parameters are handled gracefully
4. **Type Conversion**: Safe type conversion with fallback defaults

## Testing

The migration script includes validation tests that verify:

1. Basic procedure functionality
2. Parameter filtering
3. Supporting procedure operations
4. Data integrity

Run the tests by executing the migration script, which will output test results.

## Migration from INFORMIX

### Key Differences

1. **Schema Namespace**: Procedures are created in the `informix` schema
2. **JSON Parameters**: Uses native JSON parsing instead of string manipulation
3. **Return Format**: Uses `RETURNS TABLE` instead of `RETURNING` syntax
4. **Error Handling**: Uses PostgreSQL exception handling
5. **Date Functions**: Uses PostgreSQL date/time functions

### Compatibility Notes

- The original INFORMIX procedures are preserved in the same file for reference
- Return column names and types match the original specifications
- Business logic remains identical to maintain frontend compatibility

## Support

For issues or questions regarding this migration:

1. Check the PostgreSQL logs for detailed error messages
2. Verify table structure matches requirements
3. Ensure proper permissions are granted
4. Test with minimal parameter sets first

## Version History

- **v1.0** (2025-09-22): Initial PostgreSQL migration
  - Created main sp_licencias_vigentes procedure with JSON parameter support
  - Added supporting procedures for giros and zones
  - Implemented table structure validation
  - Added comprehensive error handling and testing