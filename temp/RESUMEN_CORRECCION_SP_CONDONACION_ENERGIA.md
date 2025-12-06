# Corrección Exitosa: sp_cons_condonacion_energia

## ✅ Estado: COMPLETADO

---

## Problema Original

Al buscar en el módulo `ConsCondonacionEnergia`, se generaba el siguiente error:

```
SQLSTATE[42703]: Undefined column: 7 ERROR: column u.id_usuario does not exist
LINE 27: ...FT JOIN catastro_gdl.usuarios u ON c.id_usuario = u.id_usuario...
```

---

## Causa Raíz Identificada

El stored procedure tenía **DOS problemas**:

### 1. Schema Incorrecto
```sql
-- ❌ INCORRECTO
LEFT JOIN catastro_gdl.usuarios u ON c.id_usuario = u.id_usuario
```

**Problemas:**
- Schema `catastro_gdl.usuarios` no tiene la columna `id_usuario`
- El schema correcto es `db_ingresos.usuarios`

### 2. Nombre de Columna Incorrecto
```sql
-- ❌ INCORRECTO
ON c.id_usuario = u.id_usuario
```

**Problemas:**
- La tabla `db_ingresos.usuarios` usa la columna **`id`** (no `id_usuario`)
- El JOIN debe ser: `c.id_usuario = u.id`

### 3. Tipos de Datos Incorrectos
El RETURNS TABLE tenía tipos genéricos que no coincidían con los tipos reales:
- `oficina integer` → debe ser `smallint`
- `seccion varchar` → debe ser `character(2)`
- `vigencia varchar` → debe ser `character(1)`
- `motivo varchar` → debe ser `character(1)`
- `observacion varchar` → debe ser `character(60)`
- `usuario varchar` → debe ser `character(10)`

---

## Solución Aplicada

### Corrección del JOIN

**ANTES (❌):**
```sql
LEFT JOIN catastro_gdl.usuarios u ON c.id_usuario = u.id_usuario
```

**DESPUÉS (✅):**
```sql
LEFT JOIN db_ingresos.usuarios u ON c.id_usuario = u.id
```

### Corrección de Tipos de Datos

**RETURNS TABLE corregido:**
```sql
RETURNS TABLE (
    id_condonacion integer,
    id_local integer,
    id_energia integer,
    oficina smallint,              -- ← Corregido
    num_mercado smallint,          -- ← Corregido
    categoria smallint,            -- ← Corregido
    seccion character(2),          -- ← Corregido
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre_local varchar,
    arrendatario varchar,
    vigencia character(1),         -- ← Corregido
    axo smallint,
    periodo smallint,
    fecha_condonacion timestamp without time zone,
    importe_original text,
    importe_condonado numeric,
    motivo character(1),           -- ← Corregido
    observacion character(60),     -- ← Corregido
    usuario character(10)          -- ← Corregido
)
```

### COALESCE Corregido
```sql
COALESCE(u.usuario, 'SISTEMA'::character(10)) as usuario
```

---

## Estructura de Tablas Correcta

### db_ingresos.ta_11_ade_ene_canc
- `id_cancelacion` (integer) - ID de la condonación
- `id_energia` (integer) - FK a ta_11_energia
- `id_usuario` (integer) - FK a usuarios
- `axo` (smallint)
- `periodo` (smallint)
- `fecha_alta` (timestamp)
- `importe` (numeric)
- `clave_canc` (character(1))
- `observacion` (character(60))

### db_ingresos.usuarios
- **`id`** (integer) - PK
- `usuario` (character(10))
- `nombre` (varchar)
- `estado` (character)
- `id_rec` (smallint)
- `nivel` (smallint)
- `correo` (character)

---

## Archivos Generados

1. **`temp/fix_sp_cons_condonacion_energia_final.sql`**
   - Script SQL con todas las correcciones
   - Incluye DROP de función existente
   - Tipos de datos exactos

2. **`temp/deploy_sp_cons_condonacion_remoto.php`**
   - Script PHP para desplegar remotamente
   - Verifica estructura del SP
   - Prueba funcionamiento

3. **`temp/deploy_sp_cons_condonacion_fix.bat`**
   - Script batch para despliegue rápido

---

## Proceso de Corrección

### Paso 1: Identificación del Problema
```bash
# Error original mostró schema incorrecto
catastro_gdl.usuarios.id_usuario ← NO EXISTE
```

### Paso 2: Búsqueda de Tabla Correcta
```sql
-- Se encontraron 47 tablas con "usuario" en 10 schemas diferentes
-- La tabla correcta: db_ingresos.usuarios
```

### Paso 3: Verificación de Estructura
```sql
-- db_ingresos.usuarios tiene columna 'id', no 'id_usuario'
-- Corrección del JOIN: c.id_usuario = u.id
```

### Paso 4: Ajuste de Tipos de Datos
```bash
# Se extrajeron los tipos exactos de cada columna
# Se actualizó RETURNS TABLE con tipos precisos
```

### Paso 5: Despliegue
```bash
# 1. DROP FUNCTION IF EXISTS (para cambiar tipos)
# 2. CREATE OR REPLACE FUNCTION (con correcciones)
# 3. Verificación exitosa
```

---

## Resultado

### ✅ SP Desplegado Correctamente
- Schema: `public`
- Nombre: `sp_cons_condonacion_energia`
- Estado: ACTIVO
- Sintaxis: VÁLIDA

### ✅ Verificaciones Realizadas
- [x] SP se puede ejecutar sin errores de sintaxis
- [x] Usa schema correcto: `db_ingresos.usuarios`
- [x] JOIN correcto: `c.id_usuario = u.id`
- [x] Tipos de datos coinciden exactamente
- [x] Frontend configurado correctamente

### ⚠️ Nota sobre Datos de Prueba
- No se encontraron condonaciones en la BD para pruebas
- El SP está listo para usarse cuando haya datos
- Frontend llamará al SP correctamente cuando el usuario busque

---

## Integración con Frontend

### Archivo
`RefactorX/FrontEnd/src/views/modules/mercados/ConsCondonacionEnergia.vue`

### Método de Búsqueda
```javascript
const buscarCondonaciones = async () => {
    // ...
    Operacion: 'sp_cons_condonacion_energia',  // ✓ SP correcto
    // ...
}
```

---

## Comando para Redesplegar (si necesario)

```bash
# Opción 1: PHP
c:/xampp/php/php.exe temp/deploy_sp_cons_condonacion_remoto.php

# Opción 2: psql
psql -h 192.168.6.146 -p 5432 -U refact -d padron_licencias -f temp/fix_sp_cons_condonacion_energia_final.sql

# Opción 3: Batch
temp\deploy_sp_cons_condonacion_fix.bat
```

---

## Lecciones Aprendidas

1. **Siempre verificar schemas**: No asumir que tablas con nombres similares están en el mismo schema
2. **Nombres de columnas**: La tabla `usuarios` usa `id`, no `id_usuario`
3. **Tipos exactos**: PostgreSQL es estricto con tipos - `character(2)` ≠ `varchar`
4. **DROP antes de cambiar tipos**: Al modificar RETURNS TABLE, se requiere DROP primero

---

## Schemas Relevantes del Proyecto

| Schema | Uso Principal | Ejemplo de Tablas |
|--------|--------------|-------------------|
| `comun` | Datos maestros compartidos | ta_11_locales, usuarios |
| `comunX` | Replica/extensión de comun | ta_11_energia, ta_11_adeudo_energ |
| `db_ingresos` | Transacciones de ingresos | ta_11_ade_ene_canc, usuarios |
| `catastro_gdl` | Sistema catastral | usuarios (estructura diferente) |
| `public` | SPs y funciones | sp_cons_condonacion_energia |

---

## Estado Final

### ✅ COMPLETADO
- Error resuelto
- SP corregido y desplegado
- Frontend listo para usar
- Documentación completa generada

### 📝 Pendiente (Opcional)
- Generar datos de prueba si se desea verificar con datos reales
- Crear archivo SQL consolidado en `RefactorX/Base/mercados/database/ok/`

---

**Fecha de corrección:** 2025-01-25
**Tiempo de resolución:** ~30 minutos
**Errores corregidos:** 3 (schema, columna JOIN, tipos de datos)
**Estado:** ✅ RESUELTO
