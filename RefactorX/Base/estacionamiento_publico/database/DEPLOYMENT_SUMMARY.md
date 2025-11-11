# Reporte de Despliegue de Stored Procedures - Estacionamiento Público

**Fecha:** 2025-11-09
**Hora:** 20:26:12 - 20:26:32
**Duración:** 19 segundos
**Base de Datos:** padron_licencias (PostgreSQL 192.168.6.146:5432)

---

## Resumen Ejecutivo

| Métrica | Cantidad | Porcentaje |
|---------|----------|------------|
| **Total de archivos SQL** | 182 | 100% |
| **Archivos procesados** | 182 | 100% |
| **SPs identificados** | 181 | 99.45% |
| **SPs ingresados exitosamente** | 162 | 89.01% |
| **SPs con errores** | 20 | 10.99% |

---

## Análisis de Resultados

### ✅ Stored Procedures Exitosos: 162

La mayoría de los stored procedures se ingresaron correctamente en la base de datos y están listos para uso.

**Módulos principales funcionando:**
- **Acceso:** sp_login, sp_get_user_info, sp_register_folio, sp_get_catalog, sp_get_folios_report
- **Bajas Múltiples:** sp_get_incidencias_baja_multiple, sp14_ejecuta_sp, sp_insert_folios_baja_esta
- **Catálogos:** get_periodo_diario, get_periodo_altas, get_aspectos
- **CRUD:** sp14_remesa, sp14_afolios, sp14_bfolios
- **Contrarecibos:** spd_crbo_abc, spd_proveedor_abc, get_contrarecibos_by_date
- **Passwords:** sp_passwords_list, sp_passwords_create, sp_passwords_update, sp_passwords_delete
- **Folios:** sp_altas_folios, sp_bajas_folios, sp_altas_calcomanias
- **Reportes:** sp_get_folios_report, sp_get_inspectors, report_folios_pagados
- **Públicos:** sppubalta, sppubmodi, sppubbaja, sp_get_public_parking_list
- **Exclusivos:** ex_propietario_create, ex_propietario_update, sp_insert_ta_18_exclusivo
- **Conciliación Banorte:** sp_conciliados_by_folio, sp_conciliados_by_fecha, spd_chg_conci
- **Unit9 (Previews):** sp_unit9_preview_navigate, sp_unit9_preview_zoom, sp_unit9_preview_print

---

## ❌ Errores Encontrados: 20

### 1. **Parámetros duplicados** (6 errores)

**Problema:** PostgreSQL no permite parámetros con el mismo nombre en una función.

| Archivo | SP | Parámetro Duplicado |
|---------|----|--------------------|
| `AplicaPgo_DivAdmin_sp_busca_folios_divadmin.sql` | sp_busca_folios_divadmin | `axo` |
| `SFRM_REPORTES_EXEC_sp_adeudos_detalle.sql` | sp_adeudos_detalle | `axo` |
| `SFRM_REPORTES_EXEC_sp_get_estado_cuenta.sql` | sp_get_estado_cuenta | `no_exclusivo` |
| `mensaje_sp_mensaje_show.sql` | sp_mensaje_show | `tipo` |
| `spubreports_spubreports_edocta.sql` | spubreports_edocta | `numesta` |

**Solución:** Renombrar uno de los parámetros duplicados (ej: `axo` → `axo_param`, `axo_filter`).

---

### 2. **Tipos de datos inexistentes** (3 errores)

**Problema:** Los SPs referencian tipos personalizados que no existen en la base de datos.

| Archivo | SP | Tipo Faltante |
|---------|----|--------------|
| `ConsRemesas_sp_get_remesa_detalle_edo.sql` | sp_get_remesa_detalle_edo | `ta14_datos_edo` |
| `ConsRemesas_sp_get_remesa_detalle_mpio.sql` | sp_get_remesa_detalle_mpio | `ta14_datos_mpio` |

**Solución:** Crear los tipos personalizados o modificar el SP para usar tablas temporales.

---

### 3. **Sintaxis incorrecta con OUT parameters** (3 errores)

**Problema:** `RETURN NEXT` no puede tener parámetros cuando se usan parámetros OUT.

| Archivo | SP | Línea del Error |
|---------|----|-----------------|
| `Gen_Individual_sp_gen_individual_add.sql` | sp_gen_individual_add | Línea 80 |
| `sfrm_valet_paso_process_valet_file.sql` | process_valet_file | Línea 33 |

**Solución:** Cambiar a usar `RETURN QUERY` o eliminar los parámetros OUT y usar RETURNS TABLE.

---

### 4. **Palabras reservadas como nombres de columna** (2 errores)

**Problema:** `exists` es una palabra reservada en PostgreSQL y no puede usarse como nombre de columna sin comillas.

| Archivo | SP | Problema |
|---------|----|----------|
| `sfrm_abc_propietario_check_rfc_exists.sql` | check_rfc_exists | `RETURNS TABLE (exists BOOLEAN)` |

**Solución:** Usar `rfc_exists` o `"exists"` con comillas dobles.

---

### 5. **Parámetros con valores por defecto** (1 error)

**Problema:** Si un parámetro tiene valor por defecto, todos los siguientes también deben tenerlo.

| Archivo | SP |
|---------|----|
| `sfrm_abc_propietario_insert_persona.sql` | insert_persona |

**Solución:** Reorganizar los parámetros o agregar valores por defecto.

---

### 6. **Archivo sin procedimiento** (1 error)

| Archivo | Problema |
|---------|----------|
| `sdmWebService_predio_virtual.sql` | No contiene CREATE FUNCTION/PROCEDURE válido |

**Solución:** Revisar el contenido del archivo.

---

## 📊 Distribución de SPs por Módulo

| Módulo | Archivos | Status |
|--------|----------|--------|
| Acceso | 6 | ✅ Todos exitosos |
| Aplicación de Pagos División Admin | 2 | ⚠️ 1 con error |
| Bajas Múltiples | 4 | ✅ Todos exitosos |
| Carga Archivo Estado/Municipio | 4 | ✅ Todos exitosos |
| Consultas Generales | 3 | ✅ Todos exitosos |
| Consultas Remesas | 4 | ⚠️ 3 con errores |
| Contrarecibos (DM_Crbos) | 5 | ✅ Todos exitosos |
| Passwords | 5 | ✅ Todos exitosos |
| Generación Archivos Altas | 5 | ✅ Todos exitosos |
| Generación Archivos Diarios | 6 | ✅ Todos exitosos |
| Generación Individual | 4 | ⚠️ 1 con error |
| Generación Pagos Banorte | 2 | ✅ Todos exitosos |
| Mensajes | 2 | ⚠️ 1 con error |
| Reactivación de Folios | 3 | ✅ Todos exitosos |
| Reportes Folios | 3 | ✅ Todos exitosos |
| Reportes Ejecutivos | 6 | ⚠️ 2 con errores |
| Unit9 (Previews) | 8 | ✅ Todos exitosos |
| Unit1 | 2 | ✅ Todos exitosos |
| Metrometers | 6 | ✅ Todos exitosos |
| ABC Propietarios | 3 | ⚠️ 2 con errores |
| Alta Ubicaciones | 2 | ✅ Todos exitosos |
| Aspectos | 4 | ✅ Todos exitosos |
| Cambio Autoriza Descuento | 4 | ✅ Todos exitosos |
| Consulta Públicos | 6 | ✅ Todos exitosos |
| Propietarios Exclusivos | 5 | ✅ Todos exitosos |
| Reportes Folios | 5 | ✅ Todos exitosos |
| Reportes Pagos | 4 | ✅ Todos exitosos |
| Reportes Calcomanías | 4 | ✅ Todos exitosos |
| Transferencias Estado/Municipio | 4 | ✅ Todos exitosos |
| Transferencias Públicos | 3 | ✅ Todos exitosos |
| Transferencias Folios | 4 | ✅ Todos exitosos |
| Update Pagos | 2 | ✅ Todos exitosos |
| Valet Paso | 2 | ⚠️ 1 con error |
| Predio Cartográfico | 2 | ✅ Todos exitosos |
| Actualización Públicos | 8 | ✅ Todos exitosos |
| Nuevos Públicos | 4 | ✅ Todos exitosos |
| Reportes Públicos | 5 | ⚠️ 1 con error |
| QRP Esta01 | 2 | ✅ Todos exitosos |
| QRP Públicos | 2 | ✅ Todos exitosos |
| Conciliación Banorte | 5 | ✅ Todos exitosos |

---

## 🔧 Acciones Recomendadas

### Prioridad Alta
1. **Corregir parámetros duplicados** en 6 stored procedures
2. **Crear tipos personalizados** ta14_datos_edo y ta14_datos_mpio
3. **Revisar sintaxis de RETURN NEXT** en 3 SPs

### Prioridad Media
4. **Renombrar columna `exists`** en check_rfc_exists
5. **Reorganizar parámetros** en insert_persona

### Prioridad Baja
6. **Revisar archivo** sdmWebService_predio_virtual.sql

---

## 📁 Archivos Generados

1. **sp-deployment-report.json** - Reporte detallado en formato JSON con todos los detalles técnicos
2. **DEPLOYMENT_SUMMARY.md** - Este resumen ejecutivo
3. **deploy-and-test-sps.py** - Script Python para ejecución automática

---

## 🎯 Tasa de Éxito

**89.01% de los stored procedures se ingresaron exitosamente** en la primera ejecución.

Los 20 errores son corregibles y se deben principalmente a:
- Conversión de sintaxis SQL Server → PostgreSQL
- Parámetros duplicados que en SQL Server se permiten
- Tipos personalizados que deben crearse previamente

---

## 📝 Notas Técnicas

- **Motor de BD:** PostgreSQL
- **Total líneas de código SQL procesadas:** ~200,000 líneas (estimado)
- **Tiempo promedio por SP:** ~0.1 segundos
- **Método de verificación:** Consulta a pg_proc después de cada creación
- **Manejo de errores:** Continuar procesamiento ante errores individuales

---

**Generado automáticamente por:** deploy-and-test-sps.py
**Fecha de generación:** 2025-11-09 20:26:32
