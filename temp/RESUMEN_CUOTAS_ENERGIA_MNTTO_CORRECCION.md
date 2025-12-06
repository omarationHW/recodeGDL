# Corrección Completa Componente CuotasEnergiaMntto

**Fecha:** 2025-12-03
**Problema Inicial:** Al guardar, error: "El Stored Procedure 'sp_insert_cuota_energia' no existe en el esquema 'public'"

## Diagnóstico

### Problema 1: SPs No Desplegados
Los SPs de INSERT, UPDATE y GET no estaban desplegados en la base de datos:

| SP | Estado Inicial |
|---|---|
| sp_list_cuotas_energia | ⚠️ Desplegado (versión incorrecta) |
| sp_insert_cuota_energia | ❌ No desplegado |
| sp_update_cuota_energia | ❌ No desplegado |
| sp_get_cuota_energia | ❌ No desplegado |

### Problema 2: Tipos de Datos Incorrectos
Los SPs originales usaban tipo `integer` para campos que en la tabla son `smallint`:

**Estructura Real de public.ta_11_kilowhatts:**
```
id_kilowhatts: integer
axo:           smallint  ← ERROR: los SPs usaban integer
periodo:       smallint  ← ERROR: los SPs usaban integer
importe:       numeric
fecha_alta:    timestamp
id_usuario:    integer
```

### Problema 3: Ambigüedad en RETURNING
Los SPs originales usaban DECLARE con variables del mismo nombre que las columnas, causando ambigüedad en PostgreSQL.

### Problema 4: Campo Usuario Faltante
El SP de listado no incluía el nombre del usuario, solo el id_usuario.

## Solución Aplicada (Proceso Iterativo)

### Iteración 1: Verificación y Primer Despliegue
**Scripts:** `verify_sp_insert_cuota_energia.php`, `deploy_cuotas_energia_crud_sps.php`
- ✅ Identificados SPs faltantes
- ⚠️ Desplegados con tipos incorrectos (integer en lugar de smallint)
- ❌ Error de ambigüedad en RETURNING
- ❌ Error de tipos de datos no coincidentes

### Iteración 2: Corrección de Ambigüedad
**Script:** `fix_cuotas_energia_sps.php`
- ✅ Eliminado bloque DECLARE
- ✅ Uso directo de RETURN QUERY
- ✅ Calificación de columnas en RETURNING (`ta_11_kilowhatts.columna`)
- ⚠️ Aún con tipos incorrectos

### Iteración 3: Corrección de Tipos de Datos
**Script:** `verify_ta_11_kilowhatts_structure.php`
- ✅ Identificada estructura real de la tabla
- ✅ Detectado que axo y periodo son `smallint`, no `integer`

### Iteración 4: Corrección del Campo Usuario
**Scripts:** `find_ta_12_passwords_mercados.php`, `verify_usuarios_table.php`
- ✅ Identificada tabla correcta: `public.usuarios` (no cross-database)
- ✅ JOIN configurado correctamente con `public.usuarios`

### Iteración 5: Despliegue Final Correcto
**Script:** `deploy_cuotas_energia_sps_FINAL_CORRECTO.php`

Resultado:
```
=== DESPLEGANDO SPs DE CUOTAS ENERGIA (CORREGIDOS) ===

1. sp_insert_cuota_energia     ✅ Desplegado exitosamente
2. sp_update_cuota_energia     ✅ Desplegado exitosamente
3. sp_get_cuota_energia        ✅ Desplegado exitosamente
4. sp_list_cuotas_energia      ✅ Desplegado exitosamente (con campo usuario)

=== PRUEBA DE LISTADO ===
✅ Listado funciona correctamente
  ID: 2   | Año: 2025 | Periodo:  1 | Cuota: $ 99,999.00 | Usuario: maortega
  ID: 120 | Año: 2013 | Periodo:  6 | Cuota: $     20.95 | Usuario: frodrig
```

### Iteración 6: Pruebas CRUD Completas
**Script:** `test_cuotas_energia_crud.php`

Resultados:
```
Test 1: Listar cuotas existentes            ✅ EXITOSO
Test 2: Insertar nueva cuota de prueba      ✅ EXITOSO (ID generado: 3)
Test 3: Obtener cuota por ID                ✅ EXITOSO
Test 4: Actualizar cuota                    ✅ EXITOSO (999.99 → 1500.50)
Test 5: Limpiar datos de prueba             ✅ EXITOSO
```

### Verificación Final

Todos los SPs desplegados correctamente en schema `public`:
- ✅ `sp_get_cuota_energia(p_id_kilowhatts integer)`
- ✅ `sp_insert_cuota_energia(p_axo smallint, p_periodo smallint, p_importe numeric, p_id_usuario integer)`
- ✅ `sp_list_cuotas_energia(p_axo smallint DEFAULT NULL, p_periodo smallint DEFAULT NULL)` **← CON campo usuario**
- ✅ `sp_update_cuota_energia(p_id_kilowhatts integer, p_axo smallint, p_periodo smallint, p_importe numeric, p_id_usuario integer)`

## Archivos Actualizados

1. **Archivos individuales en database/database:**
   - CuotasEnergiaMntto_sp_insert_cuota_energia.sql (marcado como desplegado)
   - CuotasEnergiaMntto_sp_update_cuota_energia.sql (marcado como desplegado)
   - CuotasEnergiaMntto_sp_get_cuota_energia.sql (marcado como desplegado)

2. **Archivo consolidado:**
   - database/ok/35_SP_MERCADOS_CUOTASENERGIAMNTTO_EXACTO_all_procedures.sql (marcado como desplegado)

## Componente Vue

El componente `CuotasEnergiaMntto.vue` ya estaba correctamente configurado:
- Usa API genérica: `/api/generic`
- Base: `mercados`
- Operaciones:
  - Listado: `sp_list_cuotas_energia`
  - Inserción: `sp_insert_cuota_energia`
  - Actualización: `sp_update_cuota_energia`

## Pruebas Sugeridas

1. **Crear nueva cuota:**
   - Abrir componente en navegador
   - Click en "Nuevo"
   - Ingresar: Año=2025, Periodo=1, Cuota=150.00
   - Guardar

2. **Editar cuota existente:**
   - Seleccionar una cuota de la lista
   - Click en "Editar"
   - Modificar el importe
   - Actualizar

3. **Listar con filtros:**
   - Filtrar por año: 2025
   - Filtrar por periodo: 1
   - Verificar resultados

## Configuración de BD

- **Host:** 192.168.6.146
- **Puerto:** 5432
- **Base de datos:** mercados
- **Usuario:** refact
- **Tabla:** public.ta_11_kilowhatts

## Campos de la Tabla ta_11_kilowhatts

- id_kilowhatts (PK)
- axo (año)
- periodo (mes 1-12)
- importe (cuota)
- fecha_alta
- id_usuario

## Correcciones Técnicas Aplicadas

### 1. Cambio de Tipos de Datos
```sql
-- ANTES (INCORRECTO):
CREATE FUNCTION sp_insert_cuota_energia(
    p_axo integer,          ← INCORRECTO
    p_periodo integer,      ← INCORRECTO
    ...
)

-- DESPUÉS (CORRECTO):
CREATE FUNCTION sp_insert_cuota_energia(
    p_axo smallint,         ← CORRECTO (match con tabla)
    p_periodo smallint,     ← CORRECTO (match con tabla)
    ...
)
```

### 2. Eliminación de Ambigüedad en RETURNING
```sql
-- ANTES (INCORRECTO):
DECLARE
BEGIN
    INSERT INTO ...
    RETURNING id_kilowhatts, axo, periodo ...  ← ERROR: ambiguo
    INTO id_kilowhatts, axo, periodo;          ← Variables con mismo nombre
    RETURN NEXT;
END;

-- DESPUÉS (CORRECTO):
BEGIN
    RETURN QUERY                               ← Directo, sin variables
    INSERT INTO ...
    RETURNING ta_11_kilowhatts.id_kilowhatts,  ← Calificado con nombre tabla
              ta_11_kilowhatts.axo,
              ta_11_kilowhatts.periodo ...;
END;
```

### 3. JOIN con Tabla de Usuarios
```sql
-- ANTES (INCORRECTO):
-- Intentaba: padron_licencias.comun.ta_12_passwords
-- ERROR: Cross-database reference not allowed

-- DESPUÉS (CORRECTO):
FROM public.ta_11_kilowhatts k
LEFT JOIN public.usuarios u ON k.id_usuario = u.id  ← Misma BD
```

## Notas Adicionales

- Los SPs usan explícitamente el schema `public.` para evitar ambigüedades
- La tabla `ta_11_kilowhatts` existe en dos schemas: `public` y `publico`
- Se usa el schema `public` por consistencia con otros módulos
- El campo `usuario` en el listado se obtiene del JOIN con `public.usuarios`
- PostgreSQL hace cast automático de integer a smallint en llamadas desde Laravel/PHP
- Todos los archivos fuente actualizados con las versiones corregidas

## Impacto en el Componente Vue

El componente `CuotasEnergiaMntto.vue` NO requiere cambios:
- Vue envía integers vía `parseInt()`
- Laravel recibe integers y los pasa a PostgreSQL
- PostgreSQL hace cast automático de integer → smallint
- **RESULTADO:** El componente funciona sin modificaciones

## Scripts Generados Durante la Corrección

1. `verify_sp_insert_cuota_energia.php` - Verificación inicial
2. `deploy_cuotas_energia_crud_sps.php` - Primer despliegue (incorrecto)
3. `fix_cuotas_energia_sps.php` - Corrección ambigüedad
4. `find_ta_12_passwords_mercados.php` - Búsqueda tabla usuarios
5. `verify_usuarios_table.php` - Verificación estructura usuarios
6. `verify_ta_11_kilowhatts_structure.php` - Identificación tipos reales
7. `fix_sp_list_cuotas_energia_final.php` - Corrección con DROP
8. `deploy_cuotas_energia_sps_FINAL_CORRECTO.php` - **Despliegue final exitoso**
9. `test_cuotas_energia_crud.php` - Pruebas CRUD completas
