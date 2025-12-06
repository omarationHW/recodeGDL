-- =====================================================
-- Script para corregir el SP sp_padron_global
-- Verifica estructura y crea el SP con tipos correctos
-- =====================================================

-- Paso 1: Ver estructura de ta_11_locales
\echo ''
\echo '1. ESTRUCTURA DE publico.ta_11_locales'
\echo '======================================='
SELECT
    column_name,
    data_type,
    character_maximum_length,
    numeric_precision,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'publico'
AND table_name = 'ta_11_locales'
ORDER BY ordinal_position;

-- Paso 2: Ver estructura de ta_11_mercados
\echo ''
\echo '2. ESTRUCTURA DE publico.ta_11_mercados'
\echo '========================================'
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'publico'
AND table_name = 'ta_11_mercados'
AND column_name IN ('descripcion', 'num_mercado', 'id_mercado', 'num_mercado_nvo', 'oficina')
ORDER BY ordinal_position;

-- Paso 3: Verificar tablas relacionadas
\echo ''
\echo '3. VERIFICAR TABLAS RELACIONADAS'
\echo '================================='
SELECT
    table_name,
    CASE WHEN table_name IS NOT NULL THEN 'EXISTE' ELSE 'NO EXISTE' END as estado
FROM information_schema.tables
WHERE table_schema = 'publico'
AND table_name IN ('ta_11_cuo_locales', 'ta_11_adeudo_local', 'ta_11_fecha_desc', 'ta_11_cve_cuota')
ORDER BY table_name;

-- Paso 4: Eliminar SP anterior
\echo ''
\echo '4. ELIMINANDO SP ANTERIOR'
\echo '========================='
DROP FUNCTION IF EXISTS publico.sp_padron_global(INTEGER, INTEGER, VARCHAR) CASCADE;
\echo 'SP anterior eliminado'

-- Paso 5: Crear nuevo SP con tipos correctos
\echo ''
\echo '5. CREANDO NUEVO SP sp_padron_global'
\echo '====================================='

CREATE OR REPLACE FUNCTION publico.sp_padron_global(
    p_year INTEGER,
    p_month INTEGER,
    p_status VARCHAR
)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHARACTER(2),
    local INTEGER,
    letra_local CHARACTER VARYING(3),
    bloque CHARACTER VARYING(5),
    nombre CHARACTER VARYING(60),
    descripcion_local CHARACTER VARYING(60),
    superficie NUMERIC(7,2),
    vigencia CHARACTER(1),
    clave_cuota SMALLINT,
    descripcion CHARACTER VARYING(30),
    renta NUMERIC(10,2),
    leyenda VARCHAR(50),
    adeudo INTEGER,
    registro VARCHAR(200)
)
AS $$
DECLARE
    v_periodo INTEGER;
BEGIN
    -- Calcular periodo (año + mes en formato YYYYMM)
    v_periodo := (p_year * 100) + p_month;

    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre,
        l.descripcion_local,
        l.superficie,
        l.vigencia,
        l.clave_cuota,
        m.descripcion,
        -- Cálculo de renta según lógica
        CASE
            -- PS con clave_cuota 4
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0)), 2)
            -- PS otros
            WHEN l.seccion = 'PS' THEN
                ROUND(((COALESCE(c.importe_cuota, 0) * l.superficie) * 30), 2)
            -- Mercado 214
            WHEN l.num_mercado = 214 THEN
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0) * COALESCE(fd.sabadosacum, 1)), 2)
            -- Default
            ELSE
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0)), 2)
        END::NUMERIC(10,2) AS renta,
        -- Leyenda de adeudo
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 'Local con Adeudo'::VARCHAR(50)
            ELSE 'Local al Corriente de Pagos'::VARCHAR(50)
        END AS leyenda,
        -- Indicador de adeudo (0 o 1)
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 1
            ELSE 0
        END::INTEGER AS adeudo,
        -- Registro concatenado
        (l.oficina::TEXT || ' ' ||
         l.num_mercado::TEXT || ' ' ||
         l.categoria::TEXT || ' ' ||
         l.seccion || ' ' ||
         l.local::TEXT || ' ' ||
         COALESCE(l.letra_local, '') || ' ' ||
         COALESCE(l.bloque, ''))::VARCHAR(200) AS registro
    FROM publico.ta_11_locales l
    INNER JOIN publico.ta_11_mercados m
        ON l.oficina = m.oficina
        AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN publico.ta_11_cuo_locales c
        ON c.axo = p_year
        AND c.categoria = l.categoria
        AND c.seccion = l.seccion
        AND c.clave_cuota = l.clave_cuota
    LEFT JOIN (
        SELECT
            id_local,
            COUNT(*)::INTEGER AS adeudos
        FROM publico.ta_11_adeudo_local
        WHERE (axo = p_year AND periodo <= p_month)
           OR (axo < p_year)
        GROUP BY id_local
    ) a ON a.id_local = l.id_local
    LEFT JOIN publico.ta_11_fecha_desc fd
        ON fd.mes = p_month
    WHERE
        (p_status = 'T' OR l.vigencia = p_status)
    ORDER BY
        l.vigencia,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque;
END;
$$ LANGUAGE plpgsql;

\echo 'SP sp_padron_global creado exitosamente'

-- Paso 6: Probar el SP
\echo ''
\echo '6. PROBANDO EL SP'
\echo '================='

-- Contar registros con vigencia 'A'
\echo 'Registros con vigencia A:'
SELECT COUNT(*) as total_vigencia_a
FROM publico.sp_padron_global(EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER, EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER, 'A');

-- Contar registros totales
\echo 'Registros totales (vigencia T):'
SELECT COUNT(*) as total_todos
FROM publico.sp_padron_global(EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER, EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER, 'T');

-- Mostrar primeros 3 registros
\echo ''
\echo 'EJEMPLOS DE REGISTROS (primeros 3):'
\echo '===================================='
SELECT
    id_local,
    oficina,
    num_mercado,
    descripcion as mercado,
    categoria,
    seccion,
    local,
    letra_local,
    nombre,
    descripcion_local,
    superficie,
    vigencia,
    clave_cuota,
    renta,
    leyenda,
    adeudo,
    registro
FROM publico.sp_padron_global(EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER, EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER, 'T')
LIMIT 3;

\echo ''
\echo '========================================'
\echo 'CORRECCIÓN COMPLETADA EXITOSAMENTE'
\echo '========================================'
