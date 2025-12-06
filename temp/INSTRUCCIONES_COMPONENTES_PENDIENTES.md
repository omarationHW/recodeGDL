# INSTRUCCIONES: Componentes Pendientes (7/18)

**Fecha:** 2025-12-05
**Estado:** 11/18 componentes funcionando (61%)
**Restantes:** 7 componentes con errores

---

## ✅ LOGROS DE LA SESIÓN

### Componentes Corregidos (7):
1. RptPagosCaja - Corregido tipo de datos y JOINs
2. RptIngresos - Corregido tipo seccion VARCHAR
3. RptPagosDetalle - Corregido folio, seccion, usuarios schema
4. RptPagosGrl - Corregido tipo seccion VARCHAR
5. RptIngresosEnergia - Corregido nombre tabla y relaciones
6. RptMercados - Desplegado exitosamente
7. RptEmisionLaser - Corregido schemas, aliases y casts

### Patrones Identificados:
- ✅ Campo `seccion` debe ser VARCHAR (no INTEGER)
- ✅ Usar prefijos de tabla en subconsultas (evitar ambigüedad)
- ✅ Agregar casts explícitos: `campo::TIPO`
- ✅ Schema correcto: `publico.ta_11_*` (no `comun` ni `db_ingresos`)
- ✅ Excepción: `public.usuarios` (no publico)

---

## 🔧 COMPONENTES PENDIENTES - COMPLEJIDAD MEDIA

### 1. EnergiaModif ⚠️

**Archivo:** `EnergiaModif_sp_energia_modif_buscar.sql`
**Error:** `relation "db_ingresos.ta_11_energia" does not exist`

**Diagnóstico:**
- Referencias cross-database: `db_ingresos.ta_11_energia`
- Esta tabla debe estar en `publico.ta_11_energia`

**Solución:**
```bash
# Buscar todas las referencias:
grep -n "db_ingresos\." RefactorX/Base/mercados/database/database/EnergiaModif_sp_energia_modif_buscar.sql

# Reemplazar:
db_ingresos.ta_11_energia → publico.ta_11_energia
db_ingresos.* → publico.*
```

**Comando de corrección:**
```php
$content = file_get_contents('EnergiaModif_sp_energia_modif_buscar.sql');
$content = preg_replace('/\bdb_ingresos\./', 'publico.', $content);
file_put_contents('EnergiaModif_sp_energia_modif_buscar.sql', $content);
```

**Tiempo estimado:** 10 minutos

---

### 2. RptFacturaEmision ⚠️

**Archivo:** `RptFacturaEmision_sp_rpt_factura_emision_CORREGIDO.sql`
**Error:** `relation "publico.ta_12_recaudadoras" does not exist`

**Diagnóstico:**
- El SP intenta acceder a `ta_12_recaudadoras` que no existe
- Posible que deba usar `ta_11_mercados` o `ta_12_recaudadora` (singular)

**Investigación necesaria:**
```bash
# Buscar tabla correcta:
psql -h 192.168.6.146 -U refact -d mercados -c "\dt publico.*recauda*"
```

**Opciones de solución:**
1. Si tabla existe en otro schema → ajustar schema
2. Si tabla tiene otro nombre → buscar nombre correcto
3. Si tabla no existe → usar `ta_11_mercados` en su lugar

**Tiempo estimado:** 15-20 minutos

---

### 3. RptFacturaEnergia ⚠️

**Archivo:** `RptFacturaEnergia_rpt_factura_energia_CORREGIDO.sql`
**Error:** `column b.id_local does not exist`

**Diagnóstico:**
- La tabla aliased como `b` no tiene campo `id_local`
- Necesita revisar qué tabla es `b` y qué campos tiene

**Investigación necesaria:**
```sql
-- Leer el SP y ver qué tabla es 'b'
-- Luego verificar estructura:
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'publico' AND table_name = '<tabla_b>'
ORDER BY ordinal_position;
```

**Solución esperada:**
- Cambiar `b.id_local` por el campo correcto de esa tabla
- Posiblemente sea `b.id_energia` o similar

**Tiempo estimado:** 15-20 minutos

---

### 4. RptMovimientos ⚠️

**Archivo:** `RptMovimientos_sp_get_movimientos_locales_CORREGIDO.sql`
**Error:** `structure of query does not match function result type`

**Diagnóstico:**
- Tipos de datos en RETURNS TABLE no coinciden con SELECT
- Similar al error que se corrigió en RptEmisionLaser

**Solución:**
1. Leer definición de RETURNS TABLE
2. Leer el SELECT y comparar tipos
3. Agregar casts explícitos a todos los campos:
```sql
SELECT
    campo1::TIPO1,
    campo2::TIPO2,
    ...
```

**Ejemplo basado en RptEmisionLaser:**
```sql
-- ANTES:
SELECT a.oficina, a.num_mercado, a.local
-- DESPUÉS:
SELECT a.oficina::SMALLINT, a.num_mercado::SMALLINT, a.local::SMALLINT
```

**Tiempo estimado:** 20-30 minutos

---

## 🔥 COMPONENTES PENDIENTES - COMPLEJIDAD ALTA

### 5. RptEmisionRbosAbastos 🔴

**Archivo:** `RptEmisionRbosAbastos_sp_rpt_emision_rbos_abastos.sql` y `*_CORREGIDO.sql`
**Error:** `RETURN NEXT cannot have a parameter in function with OUT parameters`

**Diagnóstico:**
- Error de sintaxis en la definición del SP
- Probablemente usa OUT parameters + RETURN NEXT incorrectamente
- Puede ser que use RETURNS SETOF con OUT params

**Investigación necesaria:**
```bash
# Leer ambas versiones:
- RptEmisionRbosAbastos_sp_rpt_emision_rbos_abastos.sql
- RptEmisionRbosAbastos_sp_rpt_emision_rbos_abastos_CORREGIDO.sql
```

**Problema común:**
```sql
-- INCORRECTO:
CREATE FUNCTION sp_name(OUT param1 INT, OUT param2 VARCHAR) RETURNS SETOF RECORD AS $$
BEGIN
    RETURN NEXT (valor1, valor2); -- ERROR aquí
END;

-- CORRECTO (opción 1):
CREATE FUNCTION sp_name() RETURNS TABLE(param1 INT, param2 VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT ...;
END;

-- CORRECTO (opción 2):
CREATE FUNCTION sp_name(OUT param1 INT, OUT param2 VARCHAR) RETURNS SETOF RECORD AS $$
BEGIN
    FOR ... LOOP
        param1 := valor1;
        param2 := valor2;
        RETURN NEXT; -- Sin parámetros
    END LOOP;
END;
```

**Tiempo estimado:** 45-60 minutos

---

### 6. Estadisticas 🔴

**SP:** `sp_estadistica_pagos_adeudos`
**Error:** SP no existe en la base de datos

**Diagnóstico:**
- El SP nunca fue creado o migrado
- Componente Vue espera: `sp_estadistica_pagos_adeudos`

**Opciones:**
1. **Buscar SP en sistema legacy:**
   - Buscar en archivos `.frm` del sistema VB6 antiguo
   - Buscar SQL similar en archivos de backup

2. **Crear SP desde cero:**
   - Analizar qué hace el componente Vue
   - Ver qué parámetros espera
   - Ver qué datos muestra en la UI
   - Crear SP que retorne esa estructura

3. **Buscar SP con nombre similar:**
```sql
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name LIKE '%estadistic%'
OR routine_name LIKE '%pagos%adeudo%';
```

**Tiempo estimado:** 1-2 horas (si hay que crearlo) o 15 min (si se encuentra)

---

### 7. Prescripcion 🔴

**Archivo:** `Prescripcion_sp_listar_adeudos_energia.sql`
**Error:** `Structure of query does not match function result type`

**Diagnóstico:**
- Similar a RptMovimientos pero más complejo
- Tipos en RETURNS TABLE no coinciden con SELECT

**Solución detallada:**
1. **Leer RETURNS TABLE:**
```sql
RETURNS TABLE(
    campo1 TIPO1,
    campo2 TIPO2,
    ...
)
```

2. **Leer el SELECT y comparar cada columna:**
```sql
SELECT
    columna1,  -- ¿Qué tipo retorna?
    columna2,  -- ¿Coincide con TIPO2?
    ...
```

3. **Agregar casts explícitos:**
```sql
SELECT
    columna1::TIPO1,
    columna2::TIPO2,
    ...
```

4. **Redesplegar y probar**

**Ejemplo práctico:**
```sql
-- Si RETURNS TABLE dice: nombre VARCHAR
-- Pero SELECT retorna: l.nombre (que es CHAR(50))
-- Solución: l.nombre::VARCHAR
```

**Tiempo estimado:** 30-45 minutos

---

## 📋 PLAN DE ACCIÓN RECOMENDADO

### Fase 1: Componentes Rápidos (1-2 horas)
1. ✅ **EnergiaModif** (10 min)
   - Buscar y reemplazar `db_ingresos.` → `publico.`

2. ✅ **RptMovimientos** (30 min)
   - Agregar casts explícitos en SELECT

3. ✅ **Prescripcion** (45 min)
   - Ajustar tipos de datos con casts

**Resultado esperado:** 14/18 funcionando (78%)

---

### Fase 2: Componentes con Investigación (2-3 horas)
4. ✅ **RptFacturaEmision** (20 min)
   - Encontrar tabla correcta de recaudadoras

5. ✅ **RptFacturaEnergia** (20 min)
   - Identificar campos correctos en tabla `b`

**Resultado esperado:** 16/18 funcionando (89%)

---

### Fase 3: Componentes Complejos (2-4 horas)
6. ✅ **RptEmisionRbosAbastos** (1 hora)
   - Reescribir sintaxis del SP

7. ✅ **Estadisticas** (1-2 horas)
   - Crear SP desde cero o ubicar en legacy

**Resultado esperado:** 18/18 funcionando (100%) 🎉

---

## 🛠️ COMANDOS ÚTILES

### Buscar referencias cross-database:
```bash
grep -r "db_ingresos\." RefactorX/Base/mercados/database/database/
grep -r "padron_licencias\." RefactorX/Base/mercados/database/database/
```

### Verificar estructura de tabla:
```sql
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'publico' AND table_name = 'nombre_tabla'
ORDER BY ordinal_position;
```

### Verificar SPs existentes:
```sql
SELECT routine_name, routine_schema,
       pg_catalog.pg_get_function_arguments(p.oid) as parameters
FROM information_schema.routines r
JOIN pg_proc p ON p.proname = r.routine_name
WHERE routine_schema = 'public'
AND routine_name LIKE '%buscar%'
ORDER BY routine_name;
```

### Desplegar SP:
```php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=mercados", "refact", "FF)-BQk2");
$pdo->exec(file_get_contents("archivo.sql"));
```

### Probar SP:
```php
$stmt = $pdo->query("SELECT * FROM public.sp_name(param1, param2) LIMIT 5");
$count = $stmt->rowCount();
echo "Registros: $count\n";
```

---

## 📚 RECURSOS CREADOS

### Scripts PHP Útiles:
- `fix_comun_schema_refs.php` - Corrige referencias schema
- `deploy_and_test_4_fixed.php` - Deploy y test masivo
- `check_pagos_fields.php` - Verifica estructura tablas
- `check_existing_sps.php` - Lista SPs en BD

### Documentación:
- `RESUMEN_FINAL_SESION_COMPLETA.md` - Análisis completo
- `RESUMEN_PROGRESO_ACTUAL.md` - Estado intermedio
- `INSTRUCCIONES_COMPONENTES_PENDIENTES.md` - Este archivo

---

**Total tiempo estimado para completar todos:** 5-9 horas
**Progreso actual:** 11/18 (61%)
**Mejora en esta sesión:** +7 componentes (+39%)

