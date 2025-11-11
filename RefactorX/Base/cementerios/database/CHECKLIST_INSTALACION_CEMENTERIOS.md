# CHECKLIST DE INSTALACIÓN MANUAL - STORED PROCEDURES CEMENTERIOS

**Base de Datos:** padron_licencias
**Host:** 192.168.6.146:5432
**Usuario:** refact
**Fecha:** 2025-11-09
**Total Archivos:** 39
**Total SPs:** 93

---

## FASE 1: PRE-INSTALACIÓN

### 1.1 Verificar Conexión a PostgreSQL

```bash
psql -h 192.168.6.146 -p 5432 -U refact -d padron_licencias
# Password: FF)-BQk2
```

**Estado:** ☐ Conectado exitosamente
**Notas:** _________________________________

---

### 1.2 Verificar Estado Inicial de la Base de Datos

```sql
-- Contar SPs actuales
SELECT COUNT(*) as total_sps_actuales
FROM information_schema.routines
WHERE routine_schema = 'public';
```

**Total SPs antes de instalar:** ___________
**Estado:** ☐ Verificado
**Notas:** _________________________________

---

### 1.3 Listar SPs de Cementerios Existentes

```sql
-- Listar SPs de cementerios existentes
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (routine_name LIKE 'sp_%cementerio%'
    OR routine_name LIKE 'sp_13_%'
    OR routine_name LIKE 'SP_CEMENTERIOS_%')
ORDER BY routine_name;
```

**SPs de cementerios existentes:** ___________
**Estado:** ☐ Verificado
**Notas:** _________________________________

---

### 1.4 Verificar Tablas Necesarias

```sql
-- Verificar tablas de cementerios (módulo 13)
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND (table_name LIKE 'ta_13_%' OR table_name LIKE 'tc_13_%')
ORDER BY table_name;
```

**Tablas encontradas:**
- ☐ ta_13_datosrcm
- ☐ ta_13_adeudosrcm
- ☐ ta_13_bonifrcm
- ☐ ta_13_datosrcm_historico
- ☐ tc_13_cementerios
- ☐ Otras: _________________________________

**Estado:** ☐ Todas las tablas necesarias existen
**Notas:** _________________________________

---

## FASE 2: INSTALACIÓN DE ARCHIVOS SQL

### Orden de Instalación Recomendado

#### GRUPO 1: CORE Y FUNDAMENTOS (3 archivos - 22 SPs)

**2.1.1 - 01_SP_CEMENTERIOS_CORE_all_procedures.sql (9 SPs)**

```bash
psql -h 192.168.6.146 -U refact -d padron_licencias -f "RefactorX/Base/cementerios/database/ok/01_SP_CEMENTERIOS_CORE_all_procedures.sql"
```

**SPs creados:**
- ☐ SP_CEMENTERIOS_DIFUNTOS_LIST
- ☐ SP_CEMENTERIOS_DIFUNTO_GET
- ☐ SP_CEMENTERIOS_DIFUNTO_CREATE
- ☐ SP_CEMENTERIOS_CEMENTERIOS_LIST
- ☐ SP_CEMENTERIOS_LOTES_LIST
- ☐ SP_CEMENTERIOS_SERVICIOS_LIST
- ☐ SP_CEMENTERIOS_PAGOS_LIST
- ☐ SP_CEMENTERIOS_BUSCAR_DIFUNTO
- ☐ SP_CEMENTERIOS_ESTADISTICAS

**Estado:** ☐ Instalado exitosamente ☐ Errores
**Tiempo:** ___________
**Errores:** _________________________________

---

**2.1.2 - 02_SP_CEMENTERIOS_GESTION_all_procedures.sql (8 SPs)**

```bash
psql -h 192.168.6.146 -U refact -d padron_licencias -f "RefactorX/Base/cementerios/database/ok/02_SP_CEMENTERIOS_GESTION_all_procedures.sql"
```

**SPs creados:**
- ☐ SP_CEMENTERIOS_SERVICIO_CREATE
- ☐ SP_CEMENTERIOS_PAGO_CREATE
- ☐ SP_CEMENTERIOS_LOTE_LIBERAR
- ☐ SP_CEMENTERIOS_RENOVACION_CREATE
- ☐ SP_CEMENTERIOS_RENOVACION_CONFIRMAR
- ☐ SP_CEMENTERIOS_REPORTES_OCUPACION
- ☐ SP_CEMENTERIOS_VENCIMIENTOS_PROXIMOS
- ☐ SP_CEMENTERIOS_DASHBOARD_RESUMEN

**Estado:** ☐ Instalado exitosamente ☐ Errores
**Tiempo:** ___________
**Errores:** _________________________________

---

**2.1.3 - 03_SP_CEMENTERIOS_ABC_all_procedures.sql (5 SPs)**

```bash
psql -h 192.168.6.146 -U refact -d padron_licencias -f "RefactorX/Base/cementerios/database/ok/03_SP_CEMENTERIOS_ABC_all_procedures.sql"
```

**SPs creados:**
- ☐ SP_CEMENTERIOS_FOLIO_GET
- ☐ SP_CEMENTERIOS_FOLIO_HISTORIA
- ☐ SP_CEMENTERIOS_FOLIO_BAJA
- ☐ SP_CEMENTERIOS_ADICIONALES_GET
- ☐ SP_CEMENTERIOS_REPORTES_MENSUAL

**Estado:** ☐ Instalado exitosamente ☐ Errores
**Tiempo:** ___________
**Errores:** _________________________________

---

#### GRUPO 2: MÓDULOS EXACTO - PARTE 1 (Archivos 01-12, 36 archivos - 71 SPs)

**2.2.1 - 01_SP_CEMENTERIOS_ABCFOLIO_EXACTO (2 SPs)**
- ☐ sp_13_historia
- ☐ spd_abc_adercm
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.2 - 02_SP_CEMENTERIOS_ABCRECARGOS_EXACTO (5 SPs)**
- ☐ sp_recargos_create
- ☐ sp_recargos_update
- ☐ sp_recargos_delete
- ☐ sp_recargos_list
- ☐ sp_recargos_calcular
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.3 - 03_SP_CEMENTERIOS_ACCESO_EXACTO (1 SP)**
- ☐ sp_acceso_login
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.4 - 04_SP_CEMENTERIOS_BONIFICACIONES_EXACTO (3 SPs)**
- ☐ sp_bonificaciones_create
- ☐ sp_bonificaciones_update
- ☐ sp_bonificaciones_delete
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.5 - 05_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO (11 SPs)**
- ☐ sp_conindividual_get
- ☐ sp_conindividual_list
- ☐ (... 9 SPs más)
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.6 - 06_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO (3 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.7 - 07_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO (3 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.8 - 08_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO (3 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.9 - 09_SP_CEMENTERIOS_DESCUENTOS_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.10 - 10_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO (2 SPs)**
- ☐ sp_estad_adeudo_resumen
- ☐ sp_estad_adeudo_listado
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.11 - 11_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.12 - 12_SP_CEMENTERIOS_LIST_MOV_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.13 - 13_SP_CEMENTERIOS_ABCFOLIO_EXACTO (2 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.14 - 14_SP_CEMENTERIOS_ABCRECARGOS_EXACTO (5 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.15 - 15_SP_CEMENTERIOS_ACCESO_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.16 - 16_SP_CEMENTERIOS_BONIFICACIONES_EXACTO (2 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.17 - 17_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO (6 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.18 - 18_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO (2 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.19 - 19_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO (2 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.20 - 20_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO (2 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.21 - 21_SP_CEMENTERIOS_DESCUENTOS_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.22 - 22_SP_CEMENTERIOS_ESTAD_ADEUDO_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.23 - 23_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.24 - 24_SP_CEMENTERIOS_LIST_MOV_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.25 - 25_SP_CEMENTERIOS_MODULO_EXACTO (2 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.26 - 26_SP_CEMENTERIOS_MULTIPLENOMBRE_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.27 - 27_SP_CEMENTERIOS_MULTIPLERCM_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.28 - 28_SP_CEMENTERIOS_MULTIPLEFECHA_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.29 - 29_SP_CEMENTERIOS_REP_BON_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.30 - 30_SP_CEMENTERIOS_REP_A_COBRAR_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.31 - 31_SP_CEMENTERIOS_RPTTITULOS_EXACTO (2 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.32 - 32_SP_CEMENTERIOS_TITULOSSIN_EXACTO (2 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.33 - 33_SP_CEMENTERIOS_TITULOS_EXACTO (3 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.34 - 34_SP_CEMENTERIOS_TRASLADOFOLSIN_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.35 - 35_SP_CEMENTERIOS_TRASLADOS_EXACTO (2 SPs)**
**Estado:** ☐ OK ☐ Error | Errores: _________

**2.2.36 - 36_SP_CEMENTERIOS_SFRM_CHGPASS_EXACTO (1 SP)**
**Estado:** ☐ OK ☐ Error | Errores: _________

---

## FASE 3: VERIFICACIÓN POST-INSTALACIÓN

### 3.1 Contar SPs Instalados

```sql
-- Contar total de SPs después de instalación
SELECT COUNT(*) as total_sps_despues
FROM information_schema.routines
WHERE routine_schema = 'public';
```

**Total SPs después:** ___________
**SPs instalados (diferencia):** ___________
**Esperados:** 93
**Estado:** ☐ Match ☐ Diferencia

---

### 3.2 Listar Todos los SPs de Cementerios

```sql
-- Listar SPs de cementerios instalados
SELECT routine_name, routine_type, data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (routine_name LIKE 'sp_%'
    OR routine_name LIKE 'SP_CEMENTERIOS_%'
    OR routine_name LIKE '%cementerio%'
    OR routine_name LIKE '%bonificacion%'
    OR routine_name LIKE '%recargo%')
ORDER BY routine_name;
```

**Total SPs de cementerios:** ___________
**Estado:** ☐ Verificado

---

### 3.3 Verificar SPs por Categoría

```sql
-- SPs CORE
SELECT COUNT(*) FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE 'SP_CEMENTERIOS_%';
```
**SPs CORE:** ___________ (esperados: 22)

```sql
-- SPs del módulo 13
SELECT COUNT(*) FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE 'sp_13_%';
```
**SPs Módulo 13:** ___________ (esperados: varía)

```sql
-- SPs de bonificaciones
SELECT COUNT(*) FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE 'sp_bonificaciones_%';
```
**SPs Bonificaciones:** ___________ (esperados: 5)

```sql
-- SPs de recargos
SELECT COUNT(*) FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE 'sp_recargos_%';
```
**SPs Recargos:** ___________ (esperados: 10)

---

## FASE 4: PRUEBAS DE SPs CRÍTICOS

### 4.1 Test: SP_CEMENTERIOS_ESTADISTICAS

```sql
SELECT * FROM SP_CEMENTERIOS_ESTADISTICAS();
```

**Resultado:**
- ☐ Ejecuta sin error
- ☐ Retorna estructura correcta
- ☐ Datos coherentes

**Notas:** _________________________________

---

### 4.2 Test: sp_estad_adeudo_resumen

```sql
SELECT * FROM sp_estad_adeudo_resumen() LIMIT 5;
```

**Resultado:**
- ☐ Ejecuta sin error
- ☐ Retorna datos (o vacío si no hay datos)
- ☐ Estructura correcta

**Notas:** _________________________________

---

### 4.3 Test: SP_CEMENTERIOS_CEMENTERIOS_LIST

```sql
SELECT * FROM SP_CEMENTERIOS_CEMENTERIOS_LIST();
```

**Resultado:**
- ☐ Ejecuta sin error
- ☐ Retorna cementerios
- ☐ Datos completos

**Notas:** _________________________________

---

### 4.4 Test: sp_bonificaciones_create

```sql
-- Test con datos de prueba (ajustar según esquema real)
SELECT sp_bonificaciones_create(
    1,           -- p_oficio
    2025,        -- p_axo
    'A',         -- p_doble
    1,           -- p_control_rcm
    'CEM01',     -- p_cementerio
    1,           -- p_clase
    'A',         -- p_clase_alfa
    1,           -- p_seccion
    'A',         -- p_seccion_alfa
    1,           -- p_linea
    'A',         -- p_linea_alfa
    1,           -- p_fosa
    'A',         -- p_fosa_alfa
    CURRENT_DATE, -- p_fecha_ofic
    1000.00,     -- p_importe_bonificar
    500.00,      -- p_importe_bonificado
    500.00,      -- p_importe_resto
    1,           -- p_usuario
    NOW()        -- p_fecha_mov
);
```

**Resultado:**
- ☐ Ejecuta sin error
- ☐ Registro creado
- ☐ p_error = NULL

**Notas:** _________________________________

---

### 4.5 Test: SP_CEMENTERIOS_DASHBOARD_RESUMEN

```sql
SELECT * FROM SP_CEMENTERIOS_DASHBOARD_RESUMEN();
```

**Resultado:**
- ☐ Ejecuta sin error
- ☐ Retorna métricas del dashboard
- ☐ Números coherentes

**Notas:** _________________________________

---

## FASE 5: VERIFICACIÓN DE TABLAS

### 5.1 Verificar Tablas Utilizadas por SPs

```sql
-- Verificar todas las tablas del módulo cementerios
SELECT table_name,
       (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as num_columns
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND (table_name LIKE 'ta_13_%' OR table_name LIKE 'tc_13_%')
ORDER BY table_name;
```

**Tablas encontradas:**

| Tabla | Columnas | Existe |
|-------|----------|--------|
| ta_13_adeudosrcm | ___ | ☐ |
| ta_13_bonifrcm | ___ | ☐ |
| ta_13_datosrcm | ___ | ☐ |
| ta_13_datosrcm_historico | ___ | ☐ |
| tc_13_cementerios | ___ | ☐ |
| difuntos | ___ | ☐ |
| cementerios | ___ | ☐ |
| lotes | ___ | ☐ |
| servicios | ___ | ☐ |
| pagos | ___ | ☐ |
| renovaciones | ___ | ☐ |
| historial_exhumaciones | ___ | ☐ |
| historial_folios | ___ | ☐ |
| servicios_adicionales | ___ | ☐ |
| folios | ___ | ☐ |

**Tablas faltantes:** _________________________________

---

### 5.2 Verificar Datos Existentes

```sql
-- Verificar si hay datos de prueba en tablas principales
SELECT
    (SELECT COUNT(*) FROM public.cementerios) as cementerios,
    (SELECT COUNT(*) FROM public.difuntos) as difuntos,
    (SELECT COUNT(*) FROM public.ta_13_datosrcm) as datosrcm,
    (SELECT COUNT(*) FROM public.ta_13_bonifrcm) as bonificaciones;
```

**Resultados:**
- Cementerios: ___________
- Difuntos: ___________
- Datos RCM: ___________
- Bonificaciones: ___________

---

## RESUMEN FINAL

### Estadísticas Generales

- **Archivos procesados:** _____ / 39
- **Archivos exitosos:** _____
- **Archivos con error:** _____
- **SPs instalados:** _____ / 93
- **Pruebas exitosas:** _____ / 5
- **Tablas verificadas:** _____ / 15

---

### Estado General

- ☐ **INSTALACIÓN COMPLETA Y EXITOSA**
- ☐ **INSTALACIÓN PARCIAL** (algunos errores)
- ☐ **INSTALACIÓN FALLIDA** (errores críticos)

---

### Errores Encontrados

**Archivo:** _________________________________
**Error:** _________________________________
**Causa:** _________________________________
**Solución:** _________________________________

---

**Archivo:** _________________________________
**Error:** _________________________________
**Causa:** _________________________________
**Solución:** _________________________________

---

**Archivo:** _________________________________
**Error:** _________________________________
**Causa:** _________________________________
**Solución:** _________________________________

---

### Recomendaciones para Siguientes Pasos

1. ☐ **Todos los SPs instalados correctamente**
   - Proceder con pruebas de integración con el backend
   - Verificar conexión desde GenericController
   - Probar desde frontend (apiService.js)

2. ☐ **Algunos SPs con errores**
   - Revisar tablas faltantes
   - Corregir dependencias
   - Re-ejecutar archivos con error

3. ☐ **Errores críticos**
   - Revisar esquema de base de datos
   - Verificar permisos de usuario
   - Consultar logs detallados

---

### Observaciones Adicionales

_________________________________
_________________________________
_________________________________
_________________________________

---

**Fecha de Instalación:** _________________________________
**Responsable:** _________________________________
**Tiempo Total:** _________________________________
**Log File:** _________________________________

---

**FIN DEL CHECKLIST**
