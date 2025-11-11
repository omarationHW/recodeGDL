# Manual de Verificación de Base de Datos - Cementerios

## Estado Actual de Verificación

**Fecha:** 2025-11-09
**Sistema:** Cementerios - RefactorX Guadalajara
**Base de Datos:** padron_licencias @ 192.168.6.146

---

## ✅ FASE 1: SCRIPTS DE INSTALACIÓN (COMPLETADO)

Se han generado los siguientes archivos para instalación:

- ✅ `INSTALL_CEMENTERIOS_SPS.ps1` - Script PowerShell Windows
- ✅ `INSTALL_CEMENTERIOS_SPS.sh` - Script Bash Linux/Mac
- ✅ `VERIFICACION_POST_INSTALACION.sql` - Verificación automática
- ✅ `VERIFICACION_BD_CEMENTERIOS.sql` - Verificación completa (NUEVO)
- ✅ `COMANDOS_INSTALACION_INDIVIDUAL.txt` - Comandos manuales
- ✅ `CHECKLIST_INSTALACION_CEMENTERIOS.md` - Lista de verificación

**Total de Archivos SQL:** 39 archivos
**Total de Stored Procedures:** 93 SPs

---

## 🔍 FASE 2: VERIFICACIÓN DE FUNCIONALIDAD

### Opción A: Verificación Automática (RECOMENDADA)

Ejecutar desde el servidor de base de datos:

```bash
# Windows PowerShell
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\cementerios\database
$env:PGPASSWORD='PasswordDB.2024*'
& "C:\Program Files\PostgreSQL\<version>\bin\psql.exe" -h 192.168.6.146 -U refact -d padron_licencias -f VERIFICACION_BD_CEMENTERIOS.sql > resultado_verificacion.txt
notepad resultado_verificacion.txt
```

```bash
# Linux/Mac
cd /path/to/cementerios/database
PGPASSWORD='PasswordDB.2024*' psql -h 192.168.6.146 -U refact -d padron_licencias -f VERIFICACION_BD_CEMENTERIOS.sql > resultado_verificacion.txt
cat resultado_verificacion.txt
```

### Opción B: Verificación Manual por Componente

#### 1. Verificar Conexión a Base de Datos

```sql
-- Conectar a la base de datos
psql -h 192.168.6.146 -U refact -d padron_licencias

-- Verificar conexión
SELECT current_database(), current_user, version();
```

**Resultado esperado:**
- Base de datos: `padron_licencias`
- Usuario: `refact`
- Versión: PostgreSQL 12+ o superior

---

#### 2. Verificar Tablas Principales

```sql
-- Listar todas las tablas relacionadas con cementerios
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND (tablename LIKE '%cementerio%'
    OR tablename LIKE '%difunto%'
    OR tablename LIKE '%lote%'
    OR tablename LIKE '%fosa%'
    OR tablename LIKE '%servicio%'
    OR tablename LIKE '%pago%')
ORDER BY tablename;
```

**Tablas esperadas (mínimo):**
- Tabla de difuntos
- Tabla de cementerios
- Tabla de lotes/fosas
- Tabla de servicios funerarios
- Tabla de pagos
- Tabla de renovaciones

---

#### 3. Verificar Stored Procedures

```sql
-- Listar todos los SPs de cementerios
SELECT
    p.proname as nombre_sp,
    pg_get_function_identity_arguments(p.oid) as parametros
FROM pg_proc p
INNER JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND (p.proname LIKE 'sp_cementerios%' OR p.proname LIKE 'sp_cem%')
ORDER BY p.proname;
```

**Cantidad esperada:** ~93 Stored Procedures

**SPs críticos que DEBEN existir:**
1. `sp_cementerios_difuntos_list`
2. `sp_cementerios_difunto_get`
3. `sp_cementerios_difunto_create`
4. `sp_cementerios_cementerios_list`
5. `sp_cementerios_lotes_list`
6. `sp_cementerios_servicios_list`
7. `sp_cementerios_pagos_list`
8. `sp_cementerios_buscar_difunto`
9. `sp_cementerios_estadisticas`

---

#### 4. Probar SP Crítico

```sql
-- Probar listado de difuntos (debe ejecutarse sin error)
SELECT * FROM sp_cementerios_difuntos_list(
    p_filtro => '',
    p_limite => 10,
    p_offset => 0
);

-- Probar listado de cementerios
SELECT * FROM sp_cementerios_cementerios_list();

-- Probar estadísticas generales
SELECT * FROM sp_cementerios_estadisticas();
```

**Resultado esperado:**
- No debe haber errores de ejecución
- Puede devolver 0 registros si no hay datos (normal)
- Debe devolver estructura de columnas correcta

---

#### 5. Verificar Secuencias

```sql
-- Listar secuencias relacionadas
SELECT sequencename
FROM pg_sequences
WHERE schemaname = 'public'
  AND (sequencename LIKE '%cementerio%'
    OR sequencename LIKE '%difunto%'
    OR sequencename LIKE '%lote%')
ORDER BY sequencename;
```

---

#### 6. Verificar Permisos

```sql
-- Verificar que el usuario 'refact' tiene permisos
SELECT
    schemaname,
    tablename,
    has_table_privilege('refact', schemaname||'.'||tablename, 'SELECT') as puede_select,
    has_table_privilege('refact', schemaname||'.'||tablename, 'INSERT') as puede_insert,
    has_table_privilege('refact', schemaname||'.'||tablename, 'UPDATE') as puede_update
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename LIKE '%cementerio%'
LIMIT 5;
```

**Resultado esperado:** Todos los permisos en `true`

---

## 📊 CHECKLIST DE VERIFICACIÓN

### Base de Datos

- [ ] Conexión exitosa a `padron_licencias` en 192.168.6.146
- [ ] Usuario `refact` tiene permisos completos
- [ ] Tablas principales creadas (mínimo 5-8 tablas)
- [ ] Secuencias generadas correctamente

### Stored Procedures

- [ ] Total de SPs instalados: ~93
- [ ] 9 SPs críticos instalados y funcionales
- [ ] SPs de listado ejecutan sin error
- [ ] SPs de búsqueda ejecutan sin error
- [ ] SPs de creación tienen estructura correcta

### Estructura

- [ ] Nomenclatura consistente: `sp_cementerios_*` o `sp_cem_*`
- [ ] Parámetros con prefijo `p_` (ej: `p_filtro`, `p_limite`)
- [ ] Tipos de retorno definidos (TABLE o SETOF)
- [ ] Manejo de errores implementado (EXCEPTION)

---

## ⚠️ PROBLEMAS COMUNES Y SOLUCIONES

### Problema 1: "No se encuentra psql"

**Solución:**
- Instalar PostgreSQL Client en la máquina local
- O ejecutar desde el servidor donde está PostgreSQL instalado
- O usar pgAdmin para ejecutar los scripts

### Problema 2: "Connection refused"

**Solución:**
```bash
# Verificar que el servidor PostgreSQL esté corriendo
ping 192.168.6.146

# Verificar que el puerto 5432 esté abierto
telnet 192.168.6.146 5432
# o en PowerShell:
Test-NetConnection -ComputerName 192.168.6.146 -Port 5432
```

### Problema 3: "Authentication failed"

**Solución:**
- Verificar usuario: `refact`
- Verificar contraseña: `PasswordDB.2024*`
- Verificar archivo `pg_hba.conf` permite conexiones desde tu IP

### Problema 4: "Stored Procedure already exists"

**Solución:**
```sql
-- Eliminar SP antes de reinstalar
DROP FUNCTION IF EXISTS sp_cementerios_difuntos_list(text, integer, integer) CASCADE;

-- Luego reinstalar ejecutando el archivo SQL
```

### Problema 5: "Table does not exist"

**Solución:**
- Verificar que las tablas se crearon primero
- Ejecutar scripts en orden:
  1. Primero: Scripts de tablas (CREATE TABLE)
  2. Segundo: Scripts de secuencias (CREATE SEQUENCE)
  3. Tercero: Scripts de SPs (CREATE OR REPLACE FUNCTION)

---

## 🎯 RESULTADO ESPERADO

Al completar esta verificación, deberías tener:

✅ **Base de Datos:** Todas las tablas creadas y accesibles
✅ **Stored Procedures:** 93 SPs instalados y funcionales
✅ **Permisos:** Usuario `refact` con acceso completo
✅ **Pruebas:** SPs críticos ejecutan sin errores
✅ **Documentación:** Archivo `resultado_verificacion.txt` generado

---

## 📝 PRÓXIMOS PASOS

Una vez completada la verificación de BD:

1. ✅ **FASE 2 COMPLETADA** - Base de datos funcional
2. ⏩ **FASE 3** - Corregir 29 componentes Vue con estilos scoped
3. ⏩ **FASE 4** - Estandarizar estructura de componentes
4. ⏩ **FASE 5** - Probar integración end-to-end
5. ⏩ **FASE 6** - Documentación final y cierre

---

## 📞 CONTACTO Y SOPORTE

Si encuentras problemas durante la verificación:

1. Revisar logs de PostgreSQL en el servidor
2. Verificar archivo `resultado_verificacion.txt`
3. Consultar `INFORME_DETALLADO_CEMENTERIOS_SPS.md`
4. Revisar `CHECKLIST_INSTALACION_CEMENTERIOS.md`

---

**Generado:** 2025-11-09
**Proyecto:** RefactorX - Guadalajara
**Módulo:** Cementerios
**Fase:** 2 - Verificación de BD
