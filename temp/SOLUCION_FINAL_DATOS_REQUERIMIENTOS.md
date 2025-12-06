# ✅ Solución Final: Error DatosRequerimientos

## 🔍 Problema Identificado

**Error:** `relation "ta_11_locales" does not exist`

**Causa Raíz:** Los SPs estaban buscando tablas en el schema `public`, pero las tablas están en el schema **`comun`**.

## 📋 Tablas Correctas Identificadas

| Tabla Incorrecta | Tabla Correcta |
|------------------|----------------|
| ❌ `public.ta_11_locales` | ✅ `comun.ta_11_locales` |
| ❌ `public.ta_11_mercados` | ✅ `comun.ta_11_mercados` |
| ❌ `public.ta_15_apremios` | ✅ `comun.ta_15_apremios` |
| ❌ `public.ta_12_passwords` | ✅ `comun.ta_12_passwords` |
| ❌ `public.ta_15_periodos` | ✅ `comun.ta_15_periodos` |

## ✅ Correcciones Aplicadas

### 4 Stored Procedures Corregidos:

1. **sp_get_locales** - Obtiene datos del local
   - Cambio: `public.ta_11_locales` → `comun.ta_11_locales`

2. **sp_get_mercado** - Obtiene datos del mercado
   - Cambio: `public.ta_11_mercados` → `comun.ta_11_mercados`

3. **sp_get_requerimientos** - Obtiene requerimientos
   - Cambio: `public.ta_15_apremios` → `comun.ta_15_apremios`
   - Cambio: `public.ta_12_passwords` → `comun.ta_12_passwords`

4. **sp_get_periodos** - Obtiene periodos
   - Cambio: `public.ta_15_periodos` → `comun.ta_15_periodos`

## 📁 Archivos Modificados

### Archivos Individuales (database/database/)
✅ `DatosRequerimientos_sp_get_locales.sql`
✅ `DatosRequerimientos_sp_get_mercado.sql`
✅ `DatosRequerimientos_sp_get_requerimientos.sql`
✅ `DatosRequerimientos_sp_get_periodos.sql`

### Archivo Consolidado (database/ok/)
✅ `45_SP_MERCADOS_DATOSREQUERIMIENTOS_EXACTO_all_procedures.sql`

## 🚀 Opciones de Despliegue

### Opción 1: Ejecutar Archivo Consolidado con psql ⭐

```bash
psql -h 192.168.20.31 -U postgres -d ingresos -f RefactorX/Base/mercados/database/ok/45_SP_MERCADOS_DATOSREQUERIMIENTOS_EXACTO_all_procedures.sql
```

### Opción 2: Script PHP

```bash
php temp/deploy_datosrequerimientos_fix.php
```

### Opción 3: pgAdmin

1. Abrir pgAdmin
2. Conectar a servidor 192.168.20.31
3. Base de datos: `ingresos`
4. Query Tool
5. Abrir archivo: `45_SP_MERCADOS_DATOSREQUERIMIENTOS_EXACTO_all_procedures.sql`
6. Ejecutar (F5)

### Opción 4: SQL Directo Individual

Si prefieres ejecutar uno por uno:

```sql
-- SP 1: sp_get_locales
CREATE OR REPLACE FUNCTION sp_get_locales(p_id_local integer)
RETURNS TABLE (
    id_local integer, oficina smallint, num_mercado smallint,
    categoria smallint, seccion varchar, letra_local varchar,
    bloque varchar, nombre varchar, descripcion_local varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion,
           a.letra_local, a.bloque, a.nombre, a.descripcion_local
    FROM comun.ta_11_locales a
    WHERE a.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;

-- SP 2: sp_get_mercado
CREATE OR REPLACE FUNCTION sp_get_mercado(p_oficina smallint, p_num_mercado smallint)
RETURNS TABLE (
    oficina smallint, num_mercado_nvo smallint, categoria smallint,
    descripcion varchar, cuenta_ingreso integer, cuenta_energia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia
    FROM comun.ta_11_mercados
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado;
END;
$$ LANGUAGE plpgsql;

-- SP 3: sp_get_requerimientos
CREATE OR REPLACE FUNCTION sp_get_requerimientos(p_modulo smallint, p_folio integer, p_control_otr integer)
RETURNS TABLE (
    id_control integer, modulo smallint, control_otr integer, folio integer,
    diligencia varchar, importe_global numeric, importe_multa numeric, importe_recargo numeric,
    importe_gastos numeric, fecha_emision date, clave_practicado varchar, vigencia varchar,
    fecha_actualiz date, usuario integer, id_usuario integer, usuario_1 varchar, nombre varchar,
    estado varchar, id_rec smallint, nivel smallint, zona smallint, zona_apremio smallint,
    fecha_practicado date, fecha_entrega1 date, fecha_entrega2 date, fecha_citatorio date,
    hora timestamp, ejecutor smallint, clave_secuestro smallint, clave_remate varchar,
    fecha_remate date, porcentaje_multa smallint, observaciones varchar, fecha_pago date,
    recaudadora smallint, caja varchar, operacion integer, importe_pago numeric,
    clave_mov varchar, hora_practicado timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global,
           a.importe_multa, a.importe_recargo, a.importe_gastos, a.fecha_emision,
           a.clave_practicado, a.vigencia, a.fecha_actualiz, a.usuario, b.id_usuario,
           b.usuario as usuario_1, b.nombre, b.estado, b.id_rec, b.nivel, a.zona,
           a.zona_apremio, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2,
           a.fecha_citatorio, a.hora, a.ejecutor, a.clave_secuestro, a.clave_remate,
           a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago,
           a.recaudadora, a.caja, a.operacion, a.importe_pago, a.clave_mov, a.hora_practicado
    FROM comun.ta_15_apremios a
    JOIN comun.ta_12_passwords b ON a.usuario = b.id_usuario
    WHERE a.modulo = p_modulo AND a.folio = p_folio AND a.control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;

-- SP 4: sp_get_periodos
CREATE OR REPLACE FUNCTION sp_get_periodos(p_control_otr integer)
RETURNS TABLE (
    id_control integer, control_otr integer, ayo smallint,
    periodo smallint, importe numeric, recargos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_control, control_otr, ayo, periodo, importe, recargos
    FROM comun.ta_15_periodos
    WHERE control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;
```

## ✅ Verificación después del Despliegue

```sql
-- 1. Verificar que los SPs existen
SELECT proname, pronargs
FROM pg_proc
WHERE proname IN ('sp_get_locales', 'sp_get_mercado', 'sp_get_requerimientos', 'sp_get_periodos')
ORDER BY proname;

-- 2. Ver definición de sp_get_locales
\df+ sp_get_locales

-- 3. Probar sp_get_locales con un ID válido
SELECT * FROM sp_get_locales(1);

-- 4. Verificar que usa el schema correcto
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'sp_get_locales';
-- Debe mostrar "FROM comun.ta_11_locales"
```

## 🔍 Diagnóstico de Tablas

Si necesitas verificar qué tablas existen:

```sql
-- Buscar tablas en schema 'comun'
SELECT tablename
FROM pg_tables
WHERE schemaname = 'comun'
AND tablename LIKE 'ta_11%'
OR tablename LIKE 'ta_12%'
OR tablename LIKE 'ta_15%'
ORDER BY tablename;

-- Ver estructura de ta_11_locales
\d comun.ta_11_locales

-- Contar registros
SELECT COUNT(*) FROM comun.ta_11_locales;
SELECT COUNT(*) FROM comun.ta_11_mercados;
SELECT COUNT(*) FROM comun.ta_15_apremios;
```

## 📊 Resumen de la Solución

| Item | Estado |
|------|--------|
| Problema identificado | ✅ |
| Causa raíz encontrada | ✅ Schema incorrecto (`public` → `comun`) |
| Archivos corregidos | ✅ 5 archivos SQL |
| SPs corregidos | ✅ 4 SPs |
| Scripts de despliegue | ✅ PHP + SQL |
| Documentación | ✅ Completa |
| Pendiente | ⏳ Despliegue en servidor |

## 🎯 Próximo Paso

**EJECUTAR UNO DE LOS COMANDOS DE DESPLIEGUE** desde el servidor o desde una máquina con acceso a PostgreSQL en 192.168.20.31:5432

Una vez desplegado, el módulo DatosRequerimientos funcionará correctamente! 🚀

---

**Fecha:** 2025-12-01
**Autor:** Claude Code
**Módulo:** DatosRequerimientos
