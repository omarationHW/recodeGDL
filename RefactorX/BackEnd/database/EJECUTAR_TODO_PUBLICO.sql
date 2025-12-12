-- ============================================================================
-- SCRIPT COMPLETO PARA CREAR TODO EN EL ESQUEMA 'publico'
-- Base de datos: multas_reglamentos
-- Esquema: publico
-- ============================================================================

-- PASO 1: Crear la tabla fosas
-- ============================================================================
CREATE TABLE IF NOT EXISTS publico.fosas (
    id_control INTEGER PRIMARY KEY,
    cementerio VARCHAR(200),
    clase VARCHAR(100),
    seccion VARCHAR(50),
    linea VARCHAR(50),
    fosa VARCHAR(50),
    nombre_titular VARCHAR(300),
    anio_minimo INTEGER,
    anio_maximo INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_fosas_id_control ON publico.fosas(id_control);
CREATE INDEX IF NOT EXISTS idx_fosas_cementerio ON publico.fosas(cementerio);
CREATE INDEX IF NOT EXISTS idx_fosas_titular ON publico.fosas(nombre_titular);

-- PASO 2: Crear el stored procedure
-- ============================================================================
CREATE OR REPLACE FUNCTION publico.recaudadora_drecgo_fosa(
    p_folio INTEGER
)
RETURNS TABLE (
    id_control INTEGER,
    cementerio VARCHAR,
    clase VARCHAR,
    seccion VARCHAR,
    linea VARCHAR,
    fosa VARCHAR,
    nombre_titular VARCHAR,
    anio_minimo INTEGER,
    anio_maximo INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.id_control,
        f.cementerio,
        f.clase,
        f.seccion,
        f.linea,
        f.fosa,
        f.nombre_titular,
        f.anio_minimo,
        f.anio_maximo
    FROM
        publico.fosas f
    WHERE
        CASE
            WHEN p_folio IS NULL OR p_folio = 0 THEN TRUE
            ELSE f.id_control = p_folio
        END
    ORDER BY
        f.id_control;
END;
$$;

-- PASO 3: Insertar datos de ejemplo
-- ============================================================================
INSERT INTO publico.fosas (
    id_control, cementerio, clase, seccion, linea, fosa,
    nombre_titular, anio_minimo, anio_maximo
) VALUES
    (2, 'PANTEÓN DE MEZQUITÁN', 'PERPETUA', 'A', '3', '45',
     'MARÍA GUADALUPE PÉREZ GARCÍA', 2010, 2030),
    (7, 'PANTEÓN MUNICIPAL SAN PEDRO TLAQUEPAQUE', 'TEMPORAL', 'B', '5', '128',
     'JOSÉ LUIS HERNÁNDEZ RODRÍGUEZ', 2015, 2025),
    (12, 'PANTEÓN DE SANTA PAULA', 'PERPETUA', 'C', '2', '89',
     'ROBERTO CARLOS MARTÍNEZ LÓPEZ', 2008, 2050)
ON CONFLICT (id_control) DO NOTHING;

-- PASO 4: Verificar la creación
-- ============================================================================
SELECT 'Tabla creada correctamente' as status;
SELECT * FROM publico.fosas WHERE id_control IN (2, 7, 12);

SELECT 'Stored procedure creado correctamente' as status;
SELECT routine_name, routine_schema
FROM information_schema.routines
WHERE routine_name = 'recaudadora_drecgo_fosa'
  AND routine_schema = 'publico';

-- PASO 5: Probar el stored procedure
-- ============================================================================
SELECT 'Prueba con folio 2:' as test;
SELECT * FROM publico.recaudadora_drecgo_fosa(2);

SELECT 'Prueba con folio 7:' as test;
SELECT * FROM publico.recaudadora_drecgo_fosa(7);

SELECT 'Prueba con folio 12:' as test;
SELECT * FROM publico.recaudadora_drecgo_fosa(12);

SELECT 'Prueba con folio 0 (todos):' as test;
SELECT * FROM publico.recaudadora_drecgo_fosa(0);
