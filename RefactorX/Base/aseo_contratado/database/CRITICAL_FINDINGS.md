# CRITICAL FINDINGS - ABC CATALOG PROCEDURES
## Module: aseo_contratado
**Date:** 2025-12-07
**Status:** ⚠️ SCHEMA MISMATCH DETECTED

---

## EXECUTIVE SUMMARY

The ABC catalog stored procedures have been successfully **deployed** to the database (42 procedures), but they **CANNOT EXECUTE** due to a schema mismatch between the procedures and the actual database tables.

### Root Cause

The stored procedures were created based on **legacy Delphi table structures**, but the actual PostgreSQL database uses a **modernized schema** with different column names and structures.

---

## SCHEMA MISMATCH DETAILS

### 1. ABC_Cves_Operacion (ta_16_operacion)

**Procedure Expects:**
- ctrol_operacion
- cve_operacion
- descripcion

**Actual Table Has:**
- ✓ ctrol_operacion
- ✓ cve_operacion
- ✓ descripcion
- + tipo_movimiento (new)
- + activo (new)
- + created_at (new)

**Status:** ⚠️ Mostly compatible but has ambiguity errors

---

### 2. ABC_Empresas (ta_16_empresas)

**Procedure Expects:**
- num_empresa
- ctrol_emp (as foreign key to tipos_emp)
- descripcion
- representante

**Actual Table Has:**
- ✓ num_empresa
- ✓ ctrol_emp
- ✓ descripcion
- ✓ representante
- + rfc (new)
- + domicilio (new)
- + telefono (new)
- + email (new)
- tipo_emp_id ← **DIFFERENT** (not ctrol_emp as FK)
- + activo (new)
- + created_at, updated_at (new)

**Status:** ⚠️ Foreign key mismatch (tipo_emp_id vs ctrol_emp)

---

### 3. ABC_Gastos (ta_16_gastos)

**Procedure Expects:**
- ctrol_gasto (PK)
- sdzmg
- porc1_req
- porc2_embargo
- porc3_secuestro

**Actual Table Has:**
- gasto_id ← **DIFFERENT** (not ctrol_gasto)
- cve_gasto ← **DIFFERENT**
- descripcion ← **DIFFERENT**
- monto_base ← **DIFFERENT**
- + activo (new)
- + created_at (new)

**Status:** ✗ COMPLETELY INCOMPATIBLE - Different structure

---

### 4. ABC_Recargos (ta_16_recargos)

**Procedure Expects:**
- aso_mes_recargo (TIMESTAMP, PK)
- porc_recargo
- porc_multa

**Actual Table Has:**
- recargo_id ← **DIFFERENT** (not aso_mes_recargo as PK)
- descripcion ← **NEW**
- porcentaje ← **DIFFERENT NAME** (porc_recargo)
- monto_fijo ← **NEW**
- tipo_recargo ← **NEW**
- + activo (new)
- + created_at (new)

**Status:** ✗ COMPLETELY INCOMPATIBLE - Different PK and structure

---

### 5. ABC_Recaudadoras (ta_16_recaudadoras)

**Procedure Expects:**
- num_rec (PK)
- descripcion

**Actual Table Has:**
- ✓ num_rec
- ✓ descripcion
- + activo (new)
- + created_at, updated_at (new)

**Status:** ✓ COMPATIBLE (procedures work!)

---

### 6. ABC_Tipos_Aseo (ta_16_tipos_aseo)

**Procedure Expects:**
- TABLE: ta_16_tipo_aseo ← **WRONG TABLE NAME**
- ctrol_aseo (PK)
- tipo_aseo
- descripcion
- cta_aplicacion

**Actual Table:**
- TABLE: ta_16_tipos_aseo ← **CORRECT NAME**
- tipo_aseo_id ← **DIFFERENT**
- cve_tipo ← **DIFFERENT**
- descripcion
- + activo (new)
- + created_at (new)

**Status:** ✗ WRONG TABLE NAME + INCOMPATIBLE STRUCTURE

---

### 7. ABC_Tipos_Emp (ta_16_tipos_emp)

**Procedure Expects:**
- ctrol_emp (PK)
- tipo_empresa
- descripcion

**Actual Table Has:**
- tipo_emp_id ← **DIFFERENT** (not ctrol_emp)
- tipo_emp ← **DIFFERENT NAME** (tipo_empresa)
- ✓ descripcion
- + activo (new)
- + created_at (new)

**Status:** ✗ INCOMPATIBLE - Different PK name

---

### 8. ABC_Und_Recolec (ta_16_unidades)

**Procedure Expects:**
- control_contrato
- ctrol_recolec (mapped from control_contrato)
- cve_recolec (mapped from num_unidad)
- costo_unidad (mapped from capacidad)

**Actual Table Has:**
- unidad_id ← **NEW PK**
- ✓ control_contrato (exists but not PK)
- ✓ num_unidad
- + tipo_unidad (new)
- ✓ capacidad
- ✓ descripcion
- ✓ activo
- + created_at (new)

**Status:** ⚠️ Partially compatible with mapping

---

### 9. ABC_Zonas (ta_16_zonas)

**Procedure Expects:**
- ctrol_zona (PK)
- zona
- sub_zona
- descripcion

**Actual Table Has:**
- zona_id ← **DIFFERENT** (not ctrol_zona)
- cve_zona ← **NEW**
- ✓ descripcion
- + colonia (new)
- + sector (new)
- + activo (new)
- + created_at (new)
- **MISSING:** zona, sub_zona

**Status:** ✗ INCOMPATIBLE - Different PK, missing key columns

---

## COMPATIBILITY MATRIX

| Component | Deployed | Executable | Status |
|-----------|----------|------------|--------|
| ABC_Cves_Operacion | ✓ | ✗ | Ambiguity errors |
| ABC_Empresas | ✓ | ✗ | FK mismatch |
| ABC_Gastos | ✓ | ✗ | Incompatible |
| ABC_Recargos | ✓ | ✗ | Incompatible |
| ABC_Recaudadoras | ✓ | ✓ | **Working!** |
| ABC_Tipos_Aseo | ✓ | ✗ | Wrong table + incompatible |
| ABC_Tipos_Emp | ✓ | ✗ | PK mismatch |
| ABC_Und_Recolec | ✓ | ✓ | **Working!** |
| ABC_Zonas | ✓ | ✗ | Missing columns |

**Working:** 2/9 (22%)
**Issues:** 7/9 (78%)

---

## ROOT CAUSE ANALYSIS

### Why This Happened

1. **Legacy Source Code:** The procedures were written based on Delphi source code that references the **original SQL Server / Paradox database schema**

2. **Database Modernization:** The PostgreSQL database was created with a **modernized schema** that includes:
   - Standardized ID fields (xxx_id instead of various ctrol_xxx)
   - Added audit fields (created_at, updated_at)
   - Added status fields (activo)
   - Different foreign key relationships
   - Additional business fields

3. **No Schema Documentation:** There was no schema mapping document between legacy and modern structures

---

## RECOMMENDED SOLUTION

### Option 1: Update Procedures to Match Modern Schema (RECOMMENDED)

**Effort:** Medium
**Impact:** Low (backend only)
**Benefits:**
- Procedures work with actual database
- Modern, maintainable code
- Better performance with proper indexes

**Tasks:**
1. Create schema mapping document
2. Rewrite each procedure to use actual column names
3. Update return types to match actual columns
4. Test thoroughly
5. Update frontend to use new field names if needed

### Option 2: Create Compatibility Views

**Effort:** Low
**Impact:** Medium
**Benefits:**
- Legacy procedures can work unchanged
- Easier migration path

**Drawbacks:**
- Extra layer of abstraction
- Potential performance impact
- Harder to maintain

**Tasks:**
1. Create views that map modern columns to legacy names
2. Update procedures to query views instead of tables
3. Test procedures

### Option 3: Migrate Database to Legacy Schema

**Effort:** High
**Impact:** High (all modules)
**Benefits:**
- Procedures work immediately

**Drawbacks:**
- Loses modernization benefits
- Impacts other modules
- **NOT RECOMMENDED**

---

## IMMEDIATE ACTIONS REQUIRED

### 1. Create Schema Mapping Document
Map all legacy → modern column names for each table

### 2. Decide on Approach
Choose Option 1 or Option 2 above

### 3. Update Procedures
Rewrite procedures to match chosen approach

### 4. Update Frontend Components
Ensure Vue.js components expect correct field names

### 5. Test Integration
Full end-to-end testing of ABC components

---

## WORKING PROCEDURES (Reference)

These two components work correctly and can serve as templates:

### ABC_Recaudadoras
- Simple structure
- Modern fields (num_rec, descripcion, activo, created_at)
- Procedures correctly reference actual columns

### ABC_Und_Recolec
- Uses field mapping correctly
- Shows how to adapt legacy names to modern schema

---

## NEXT STEPS

1. **STOP** - Do not deploy these procedures to production
2. **DOCUMENT** - Create complete schema mapping
3. **REWRITE** - Update procedures for modern schema
4. **TEST** - Comprehensive testing before deployment
5. **COORDINATE** - Align with frontend team on field names

---

## FILES FOR REFERENCE

### Deployment Files (Created)
- ✓ `deploy_abc_procedures.php` - Deployment script
- ✓ `verify_abc_procedures.php` - Verification script
- ✓ `test_abc_procedures.php` - Test script
- ✓ `check_table_structure.php` - Schema inspection tool

### Documentation Files
- ✓ `ABC_DEPLOYMENT_SUMMARY.md` - Original deployment plan
- ✓ `DEPLOYMENT_COMPLETE.md` - Deployment report
- ✓ `CRITICAL_FINDINGS.md` - This document

### SQL Files (Need Update)
All files in: `database/`
- ABC_Cves_Operacion_all_procedures.sql
- ABC_Empresas_all_procedures.sql
- ABC_Gastos_all_procedures.sql
- ABC_Recargos_all_procedures.sql
- ✓ ABC_Recaudadoras_all_procedures.sql (works!)
- ABC_Tipos_Aseo_all_procedures.sql
- ABC_Tipos_Emp_all_procedures.sql
- ✓ ABC_Und_Recolec_all_procedures.sql (works!)
- ABC_Zonas_all_procedures.sql

---

## ESTIMATED EFFORT TO FIX

| Task | Effort | Priority |
|------|--------|----------|
| Schema mapping document | 2 hours | High |
| Rewrite ABC_Gastos | 2 hours | High |
| Rewrite ABC_Recargos | 2 hours | High |
| Rewrite ABC_Tipos_Aseo | 2 hours | High |
| Rewrite ABC_Tipos_Emp | 1 hour | Medium |
| Rewrite ABC_Zonas | 2 hours | High |
| Fix ABC_Cves_Operacion | 1 hour | Medium |
| Fix ABC_Empresas | 1 hour | Medium |
| Update frontend components | 4 hours | High |
| Testing & validation | 4 hours | High |
| **TOTAL** | **~21 hours** | |

---

## CONCLUSION

While the deployment was technically successful (42 procedures created), the **procedures cannot execute** due to schema mismatches.

**Recommendation:** Proceed with **Option 1** (Update Procedures) as it provides the best long-term solution.

**Status:** ⚠️ REQUIRES IMMEDIATE ATTENTION BEFORE PRODUCTION USE

---

**Reported By:** Claude Code Assistant
**Date:** 2025-12-07
**Module:** aseo_contratado
**Database:** padron_licencias @ 192.168.6.146
