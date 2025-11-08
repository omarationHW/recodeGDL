-- =====================================================
-- FIX: Eliminar Duplicados y Agregar Clave Primaria
-- Tabla: comun.c_actividades
-- Fecha: 2025-11-06
-- =====================================================

-- PROBLEMA ENCONTRADO:
-- 1. La tabla NO tiene clave primaria
-- 2. La tabla TIENE registros duplicados (cada registro aparece 2 veces)
-- 3. El SP devuelve todos los duplicados

-- =====================================================
-- PASO 1: Backup de datos (por seguridad)
-- =====================================================

-- Crear tabla temporal con todos los datos
CREATE TEMP TABLE c_actividades_backup AS
SELECT * FROM comun.c_actividades;

SELECT 'Backup creado con ' || COUNT(*) || ' registros' as status
FROM c_actividades_backup;

-- =====================================================
-- PASO 2: Eliminar duplicados de la tabla
-- =====================================================

-- Primero, ver cuántos duplicados hay
SELECT
    'Total duplicados a eliminar: ' ||
    (COUNT(*) - COUNT(DISTINCT (generico, uso, actividad))) as duplicados_info
FROM comun.c_actividades;

-- Eliminar duplicados, dejando solo 1 registro por cada (generico, uso, actividad)
DELETE FROM comun.c_actividades a
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM comun.c_actividades b
    WHERE a.generico = b.generico
      AND a.uso = b.uso
      AND a.actividad = b.actividad
    GROUP BY b.generico, b.uso, b.actividad
);

-- Verificar cuántos registros quedan
SELECT 'Registros después de eliminar duplicados: ' || COUNT(*) as status
FROM comun.c_actividades;

-- =====================================================
-- PASO 3: Agregar clave primaria
-- =====================================================

-- Agregar PK compuesta
ALTER TABLE comun.c_actividades
ADD CONSTRAINT pk_c_actividades PRIMARY KEY (generico, uso, actividad);

SELECT 'Clave primaria agregada exitosamente' as status;

-- =====================================================
-- PASO 4: Actualizar SP para usar DISTINCT (por seguridad)
-- =====================================================

CREATE OR REPLACE FUNCTION comun.catalogo_actividades_list()
RETURNS TABLE (
    generico SMALLINT,
    uso SMALLINT,
    actividad SMALLINT,
    concepto VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT  -- ✅ Agregado DISTINCT como seguridad
        a.generico,
        a.uso,
        a.actividad,
        TRIM(a.concepto)::VARCHAR as concepto
    FROM comun.c_actividades a
    ORDER BY a.generico, a.uso, a.actividad;
END;
$$ LANGUAGE plpgsql;

SELECT 'SP actualizado con DISTINCT' as status;

-- =====================================================
-- PASO 5: Verificar resultados
-- =====================================================

-- Verificar que no haya duplicados
SELECT
    generico,
    uso,
    actividad,
    COUNT(*) as veces
FROM comun.c_actividades
GROUP BY generico, uso, actividad
HAVING COUNT(*) > 1;

-- Si la consulta anterior no devuelve nada, está OK

-- Verificar que el SP devuelve registros únicos
SELECT 'Total registros en tabla: ' || COUNT(*) as status FROM comun.c_actividades;
SELECT 'Total registros del SP: ' || COUNT(*) as status FROM comun.catalogo_actividades_list();

-- Estas dos consultas deben devolver el MISMO número

-- =====================================================
-- RESUMEN
-- =====================================================
/*
ANTES:
- Tabla sin PK ❌
- 1274 registros (con duplicados) ❌
- SP devuelve duplicados ❌
- Frontend muestra doble ❌

DESPUÉS:
- Tabla con PK (generico, uso, actividad) ✅
- ~637 registros (sin duplicados) ✅
- SP devuelve registros únicos ✅
- Frontend muestra correcto ✅
*/
