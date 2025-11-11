# Guía de Corrección de Errores - Stored Procedures

Esta guía muestra cómo corregir los 20 errores encontrados durante el despliegue.

---

## 1. Error: Parámetros Duplicados

### Problema
PostgreSQL no permite dos parámetros con el mismo nombre en una función.

### Ejemplo de Error
```sql
CREATE OR REPLACE FUNCTION sp_busca_folios_divadmin(
    axo INTEGER,
    folio INTEGER,
    axo INTEGER  -- ❌ ERROR: "axo" ya existe
)
```

### ✅ Solución
Renombrar uno de los parámetros:

```sql
CREATE OR REPLACE FUNCTION sp_busca_folios_divadmin(
    axo_inicio INTEGER,
    folio INTEGER,
    axo_fin INTEGER  -- ✅ Diferente nombre
)
```

### Archivos a corregir:
1. `AplicaPgo_DivAdmin_sp_busca_folios_divadmin.sql` - parámetro `axo`
2. `SFRM_REPORTES_EXEC_sp_adeudos_detalle.sql` - parámetro `axo`
3. `SFRM_REPORTES_EXEC_sp_get_estado_cuenta.sql` - parámetro `no_exclusivo`
4. `mensaje_sp_mensaje_show.sql` - parámetro `tipo`
5. `spubreports_spubreports_edocta.sql` - parámetro `numesta`

---

## 2. Error: Tipos Personalizados Inexistentes

### Problema
Los SPs referencian tipos `ta14_datos_edo` y `ta14_datos_mpio` que no existen.

### Ejemplo de Error
```sql
CREATE OR REPLACE FUNCTION sp_get_remesa_detalle_edo()
RETURNS SETOF ta14_datos_edo  -- ❌ ERROR: tipo no existe
```

### ✅ Solución Opción 1: Crear el tipo personalizado

```sql
-- Primero crear el tipo
CREATE TYPE ta14_datos_edo AS (
    axo INTEGER,
    folio INTEGER,
    fecha DATE,
    importe NUMERIC(12,2)
    -- ... otros campos
);

-- Luego crear la función
CREATE OR REPLACE FUNCTION sp_get_remesa_detalle_edo()
RETURNS SETOF ta14_datos_edo
AS $$
BEGIN
    RETURN QUERY
    SELECT axo, folio, fecha, importe
    FROM ta14_datos_edo;
END;
$$ LANGUAGE plpgsql;
```

### ✅ Solución Opción 2: Usar TABLE en lugar de tipo personalizado

```sql
CREATE OR REPLACE FUNCTION sp_get_remesa_detalle_edo()
RETURNS TABLE (
    axo INTEGER,
    folio INTEGER,
    fecha DATE,
    importe NUMERIC(12,2)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT d.axo, d.folio, d.fecha, d.importe
    FROM ta14_datos_edo d;
END;
$$ LANGUAGE plpgsql;
```

### Archivos a corregir:
1. `ConsRemesas_sp_get_remesa_detalle_edo.sql`
2. `ConsRemesas_sp_get_remesa_detalle_mpio.sql`

---

## 3. Error: RETURN NEXT con OUT parameters

### Problema
No se puede usar `RETURN NEXT (valor1, valor2)` cuando la función tiene parámetros OUT.

### Ejemplo de Error
```sql
CREATE OR REPLACE FUNCTION sp_gen_individual_add(
    OUT v_id INTEGER,
    OUT v_nombre VARCHAR
)
RETURNS SETOF RECORD
AS $$
BEGIN
    FOR r IN SELECT id, nombre FROM tabla LOOP
        RETURN NEXT (r.id, r.nombre);  -- ❌ ERROR
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```

### ✅ Solución Opción 1: Asignar a los OUT parameters
```sql
CREATE OR REPLACE FUNCTION sp_gen_individual_add(
    OUT v_id INTEGER,
    OUT v_nombre VARCHAR
)
RETURNS SETOF RECORD
AS $$
BEGIN
    FOR r IN SELECT id, nombre FROM tabla LOOP
        v_id := r.id;
        v_nombre := r.nombre;
        RETURN NEXT;  -- ✅ Sin parámetros
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```

### ✅ Solución Opción 2: Usar RETURNS TABLE en lugar de OUT
```sql
CREATE OR REPLACE FUNCTION sp_gen_individual_add()
RETURNS TABLE (
    v_id INTEGER,
    v_nombre VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT id, nombre FROM tabla;  -- ✅ Mucho más simple
END;
$$ LANGUAGE plpgsql;
```

### Archivos a corregir:
1. `Gen_Individual_sp_gen_individual_add.sql` - Línea 80
2. `sfrm_valet_paso_process_valet_file.sql` - Línea 33

---

## 4. Error: Palabra Reservada como Nombre de Columna

### Problema
`exists` es palabra reservada en PostgreSQL.

### Ejemplo de Error
```sql
CREATE OR REPLACE FUNCTION check_rfc_exists(p_rfc VARCHAR)
RETURNS TABLE (exists BOOLEAN)  -- ❌ ERROR: "exists" es palabra reservada
AS $$
BEGIN
    RETURN QUERY
    SELECT CASE WHEN COUNT(*) > 0 THEN TRUE ELSE FALSE END
    FROM propietarios
    WHERE rfc = p_rfc;
END;
$$ LANGUAGE plpgsql;
```

### ✅ Solución Opción 1: Renombrar la columna
```sql
CREATE OR REPLACE FUNCTION check_rfc_exists(p_rfc VARCHAR)
RETURNS TABLE (rfc_exists BOOLEAN)  -- ✅ Nombre diferente
AS $$
BEGIN
    RETURN QUERY
    SELECT CASE WHEN COUNT(*) > 0 THEN TRUE ELSE FALSE END
    FROM propietarios
    WHERE rfc = p_rfc;
END;
$$ LANGUAGE plpgsql;
```

### ✅ Solución Opción 2: Usar comillas dobles
```sql
CREATE OR REPLACE FUNCTION check_rfc_exists(p_rfc VARCHAR)
RETURNS TABLE ("exists" BOOLEAN)  -- ✅ Con comillas
AS $$
BEGIN
    RETURN QUERY
    SELECT CASE WHEN COUNT(*) > 0 THEN TRUE ELSE FALSE END
    FROM propietarios
    WHERE rfc = p_rfc;
END;
$$ LANGUAGE plpgsql;
```

### Archivos a corregir:
1. `sfrm_abc_propietario_check_rfc_exists.sql`

---

## 5. Error: Parámetros con Valores por Defecto

### Problema
Si un parámetro tiene valor por defecto, todos los siguientes también deben tenerlo.

### Ejemplo de Error
```sql
CREATE OR REPLACE FUNCTION insert_persona(
    p_nombre VARCHAR,
    p_apellido VARCHAR DEFAULT 'N/A',
    p_rfc VARCHAR  -- ❌ ERROR: debe tener DEFAULT
)
```

### ✅ Solución Opción 1: Reorganizar parámetros
```sql
CREATE OR REPLACE FUNCTION insert_persona(
    p_nombre VARCHAR,
    p_rfc VARCHAR,
    p_apellido VARCHAR DEFAULT 'N/A'  -- ✅ Al final
)
```

### ✅ Solución Opción 2: Agregar DEFAULT a todos
```sql
CREATE OR REPLACE FUNCTION insert_persona(
    p_nombre VARCHAR,
    p_apellido VARCHAR DEFAULT 'N/A',
    p_rfc VARCHAR DEFAULT NULL  -- ✅ Con DEFAULT
)
```

### Archivos a corregir:
1. `sfrm_abc_propietario_insert_persona.sql`

---

## 6. Archivo sin Procedimiento

### Problema
El archivo no contiene una definición válida de CREATE FUNCTION o CREATE PROCEDURE.

### Archivo afectado:
`sdmWebService_predio_virtual.sql`

### ✅ Solución
Revisar el contenido del archivo y verificar que contenga una estructura válida:

```sql
CREATE OR REPLACE FUNCTION nombre_funcion(parametros)
RETURNS tipo_retorno
AS $$
BEGIN
    -- Código aquí
END;
$$ LANGUAGE plpgsql;
```

---

## 📋 Checklist de Corrección

### Paso 1: Correcciones Rápidas (30 min)
- [ ] Corregir parámetros duplicados en 6 archivos
- [ ] Renombrar columna `exists` en 1 archivo
- [ ] Reorganizar parámetros con DEFAULT en 1 archivo

### Paso 2: Correcciones Medias (1 hora)
- [ ] Corregir RETURN NEXT en 3 archivos
- [ ] Revisar sdmWebService_predio_virtual.sql

### Paso 3: Crear Tipos (2 horas)
- [ ] Analizar estructura de ta14_datos_edo
- [ ] Analizar estructura de ta14_datos_mpio
- [ ] Crear tipos o modificar SPs para usar RETURNS TABLE

---

## 🔄 Proceso de Revalidación

Después de corregir los archivos:

```bash
# Re-ejecutar el script de deployment
python deploy-and-test-sps.py

# Verificar que los 20 errores se redujeron a 0
# Verificar en el reporte JSON generado
```

---

## 📊 Priorización de Correcciones

| Prioridad | Archivos | Tiempo Estimado | Impacto |
|-----------|----------|-----------------|---------|
| 🔴 Alta | 6 (parámetros duplicados) | 30 min | Alto - Errores simples |
| 🟡 Media | 5 (RETURN NEXT, DEFAULT) | 1 hora | Medio - Requiere análisis |
| 🟢 Baja | 3 (tipos, archivo sin SP) | 2 horas | Bajo - Requiere investigación |

---

**Total tiempo estimado de corrección: 3.5 horas**

Todos los errores son corregibles y no requieren cambios estructurales en la base de datos.
