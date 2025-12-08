# ABC CATALOG COMPONENTS - DEPLOYMENT SUMMARY
## Module: aseo_contratado
**Date:** 2025-12-07
**Database:** padron_licencias @ 192.168.6.146
**Schema:** public
**User:** refact

---

## COMPONENTS PROCESSED

### 1. ABC_Cves_Operacion
**Table:** `ta_16_operacion`
**File:** `ABC_Cves_Operacion_all_procedures.sql`
**Description:** Claves de Operación (Operation Codes)
**Status:** ✓ Ready for deployment

**Stored Procedures:**
- `sp_cves_operacion_list()` - List all operation codes
- `sp_cves_operacion_get(p_ctrol_operacion)` - Get single operation code by ID
- `sp_cves_operacion_insert(p_cve_operacion, p_descripcion)` - Insert new operation code
- `sp_cves_operacion_update(p_ctrol_operacion, p_cve_operacion, p_descripcion)` - Update operation code
- `sp_cves_operacion_delete(p_ctrol_operacion)` - Delete operation code (validates no associated payments)

---

### 2. ABC_Empresas
**Table:** `ta_16_empresas`
**File:** `ABC_Empresas_all_procedures.sql`
**Description:** Empresas (Companies)
**Status:** ✓ Ready for deployment

**Stored Procedures:**
- `sp_empresas_list()` - List all companies with type
- `sp_empresas_get(p_num_empresa, p_ctrol_emp)` - Get single company
- `sp_empresas_create(p_ctrol_emp, p_descripcion, p_representante)` - Create new company
- `sp_empresas_update(p_num_empresa, p_ctrol_emp, p_descripcion, p_representante)` - Update company
- `sp_empresas_delete(p_num_empresa, p_ctrol_emp)` - Delete company (validates no associated contracts)
- `sp_empresas_search(p_descripcion, p_ctrol_emp)` - Search companies by name/type
- `sp_tipos_emp_list()` - List company types (helper function)

---

### 3. ABC_Gastos
**Table:** `ta_16_gastos`
**File:** `ABC_Gastos_all_procedures.sql`
**Description:** Gastos de Ejecución (Execution Costs)
**Status:** ⚠️ FIXED - Converted PROCEDURE to FUNCTION

**Issue:** Original file used `CREATE PROCEDURE` instead of `CREATE FUNCTION`
**Resolution:** Deployment script includes automatic fix

**Stored Procedures:**
- `sp_gastos_list()` - List all cost records (normally just 1)
- `sp_gastos_get()` - Get active cost record
- `sp_gastos_insert(p_sdzmg, p_porc1_req, p_porc2_embargo, p_porc3_secuestro)` - Insert cost record
- `sp_gastos_update(p_ctrol_gasto, p_sdzmg, p_porc1_req, p_porc2_embargo, p_porc3_secuestro)` - Update cost record
- `sp_gastos_delete_all()` - Delete all cost records (use with caution)

---

### 4. ABC_Recargos
**Table:** `ta_16_recargos`
**File:** `ABC_Recargos_all_procedures.sql`
**Description:** Recargos (Surcharges)
**Status:** ✓ Ready for deployment

**Stored Procedures:**
- `sp_recargos_list(p_year)` - List surcharges, optionally filtered by year
- `sp_recargos_create(p_aso_mes_recargo, p_porc_recargo, p_porc_multa)` - Create surcharge record
- `sp_recargos_update(p_aso_mes_recargo, p_porc_recargo, p_porc_multa)` - Update surcharge record
- `sp_recargos_delete(p_aso_mes_recargo)` - Delete surcharge record

**Note:** Uses TIMESTAMP for `aso_mes_recargo` field

---

### 5. ABC_Recaudadoras
**Table:** `ta_16_recaudadoras`
**File:** `ABC_Recaudadoras_all_procedures.sql`
**Description:** Recaudadoras (Collectors)
**Status:** ✓ Ready for deployment

**Stored Procedures:**
- `sp_list_recaudadoras()` - List all collectors
- `sp_get_next_num_recaudadora()` - Get next available collector number
- `sp_insert_recaudadora(p_num_rec, p_descripcion)` - Insert new collector
- `sp_update_recaudadora(p_num_rec, p_descripcion)` - Update collector
- `sp_delete_recaudadora(p_num_rec)` - Delete collector (validates no associated contracts)

---

### 6. ABC_Tipos_Aseo
**Table:** `ta_16_tipo_aseo`
**File:** `ABC_Tipos_Aseo_all_procedures.sql`
**Description:** Tipos de Aseo (Cleaning Types)
**Status:** ✓ Ready for deployment

**Stored Procedures:**
- `sp_tipos_aseo_list()` - List all cleaning types
- `sp_tipos_aseo_create(p_tipo_aseo, p_descripcion, p_cta_aplicacion, p_usuario)` - Create cleaning type
- `sp_tipos_aseo_update(p_ctrol_aseo, p_tipo_aseo, p_descripcion, p_cta_aplicacion, p_usuario)` - Update cleaning type
- `sp_tipos_aseo_delete(p_ctrol_aseo, p_usuario)` - Delete cleaning type (validates no associated contracts)

---

### 7. ABC_Tipos_Emp
**Table:** `ta_16_tipos_emp`
**File:** `ABC_Tipos_Emp_all_procedures.sql`
**Description:** Tipos de Empresa (Company Types)
**Status:** ✓ Ready for deployment

**Stored Procedures:**
- `sp_tipos_emp_list()` - List all company types
- `sp_tipos_emp_create(p_ctrol_emp, p_tipo_empresa, p_descripcion)` - Create company type
- `sp_tipos_emp_update(p_ctrol_emp, p_tipo_empresa, p_descripcion)` - Update company type
- `sp_tipos_emp_delete(p_ctrol_emp)` - Delete company type (validates no associated companies)

---

### 8. ABC_Und_Recolec
**Table:** `ta_16_unidades`
**File:** `ABC_Und_Recolec_all_procedures.sql`
**Description:** Unidades de Recolección (Collection Units)
**Status:** ✓ Ready for deployment

**Stored Procedures:**
- `sp_unidades_recoleccion_list(p_ejercicio)` - List collection units
- `sp_unidades_recoleccion_create(p_ejercicio, p_cve, p_descripcion, p_costo_unidad, p_costo_exed, p_usuario_id)` - Create unit
- `sp_unidades_recoleccion_update(p_ctrol, p_ejercicio, p_cve, p_descripcion, p_costo_unidad, p_costo_exed, p_usuario_id)` - Update unit
- `sp_unidades_recoleccion_delete(p_ctrol)` - Delete unit (soft delete - sets activo=false)

**Note:** This component maps real table columns to expected frontend field names

---

### 9. ABC_Zonas
**Table:** `ta_16_zonas`
**File:** `ABC_Zonas_all_procedures.sql`
**Description:** Zonas (Zones)
**Status:** ✓ Ready for deployment

**Stored Procedures:**
- `sp_zonas_list()` - List all zones
- `sp_zonas_create(p_zona, p_sub_zona, p_descripcion)` - Create zone
- `sp_zonas_update(p_ctrol_zona, p_zona, p_sub_zona, p_descripcion)` - Update zone
- `sp_zonas_delete(p_ctrol_zona)` - Delete zone (validates no associated companies)

---

## DEPLOYMENT INSTRUCTIONS

### Method 1: Using PHP Script (Recommended)
```bash
cd C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/aseo_contratado/database
php deploy_abc_procedures.php
```

The script will:
1. Connect to the database
2. Deploy all 9 ABC components in sequence
3. Automatically fix ABC_Gastos (PROCEDURE → FUNCTION)
4. Provide detailed success/error reporting
5. Show deployment summary

### Method 2: Manual Deployment
Execute each SQL file individually in this order:
1. `ABC_Cves_Operacion_all_procedures.sql`
2. `ABC_Tipos_Emp_all_procedures.sql`
3. `ABC_Tipos_Aseo_all_procedures.sql`
4. `ABC_Empresas_all_procedures.sql`
5. `ABC_Recaudadoras_all_procedures.sql`
6. `ABC_Zonas_all_procedures.sql`
7. `ABC_Und_Recolec_all_procedures.sql`
8. `ABC_Recargos_all_procedures.sql`
9. `ABC_Gastos_all_procedures.sql` (must fix PROCEDURE → FUNCTION first)

---

## TOTAL STORED PROCEDURES CREATED

| Component | SP Count |
|-----------|----------|
| ABC_Cves_Operacion | 5 |
| ABC_Empresas | 7 |
| ABC_Gastos | 5 |
| ABC_Recargos | 4 |
| ABC_Recaudadoras | 5 |
| ABC_Tipos_Aseo | 4 |
| ABC_Tipos_Emp | 4 |
| ABC_Und_Recolec | 4 |
| ABC_Zonas | 4 |
| **TOTAL** | **42** |

---

## COMMON PATTERNS

All ABC components follow these standard patterns:

### Return Types
- **List operations:** Return TABLE with record fields
- **CRUD operations:** Return TABLE with `success BOOLEAN, message TEXT`
- **Get operations:** Return TABLE with record fields or single values

### Validations
- Duplicate key checks before INSERT
- Foreign key validation before DELETE
- Existence checks before UPDATE

### Security
- All functions granted to PUBLIC schema
- All functions use `DROP FUNCTION IF EXISTS` for idempotency

---

## TESTING RECOMMENDATIONS

### Test Each Component
```sql
-- List records
SELECT * FROM sp_cves_operacion_list();
SELECT * FROM sp_empresas_list();
SELECT * FROM sp_gastos_list();
-- ... etc for all components

-- Test INSERT
SELECT * FROM sp_cves_operacion_insert('X', 'Test Operation');

-- Test UPDATE
SELECT * FROM sp_cves_operacion_update(1, 'Y', 'Updated Operation');

-- Test DELETE
SELECT * FROM sp_cves_operacion_delete(1);
```

### Verify Permissions
```sql
-- Check function ownership and grants
SELECT proname, proowner, proacl
FROM pg_proc
WHERE proname LIKE 'sp_%'
  AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY proname;
```

---

## ROLLBACK PLAN

If deployment fails or needs to be rolled back:

```sql
-- Drop all ABC functions
DROP FUNCTION IF EXISTS public.sp_cves_operacion_list();
DROP FUNCTION IF EXISTS public.sp_cves_operacion_get(INTEGER);
DROP FUNCTION IF EXISTS public.sp_cves_operacion_insert(VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS public.sp_cves_operacion_update(INTEGER, VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS public.sp_cves_operacion_delete(INTEGER);

-- Repeat for all other components...
-- Or use a wildcard drop (use with EXTREME caution):
-- DO $$ DECLARE r RECORD;
-- BEGIN
--   FOR r IN SELECT proname, pg_get_function_identity_arguments(oid) as args
--            FROM pg_proc
--            WHERE proname LIKE 'sp_%'
--              AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
--   LOOP
--     EXECUTE 'DROP FUNCTION IF EXISTS public.' || r.proname || '(' || r.args || ')';
--   END LOOP;
-- END $$;
```

---

## NOTES

1. **CRITICAL:** All procedures are FUNCTIONS, not PROCEDURES. The backend only supports FUNCTION calls.

2. **ABC_Gastos Fix:** The original file incorrectly used `CREATE PROCEDURE`. The deployment script automatically corrects this.

3. **Table Aliases:** All UPDATE/DELETE operations use table aliases (e.g., `ta_16_empresas e`) to avoid ambiguity errors.

4. **Soft Deletes:** ABC_Und_Recolec uses soft delete (activo=false) instead of hard delete.

5. **Validation Logic:** Most delete operations validate foreign key relationships before allowing deletion.

6. **Compatibility Parameters:** Some functions include unused parameters (e.g., `p_usuario`) for compatibility with existing Delphi code.

---

## SUPPORT

For issues or questions:
- Check error logs in PostgreSQL
- Review pg_last_error() output from PHP script
- Verify database connectivity: `psql -h 192.168.6.146 -U refact -d padron_licencias`
- Check function existence: `\df sp_*` in psql

---

**Generated:** 2025-12-07
**Author:** Claude Code Assistant
**Project:** RefactorX - Guadalajara
