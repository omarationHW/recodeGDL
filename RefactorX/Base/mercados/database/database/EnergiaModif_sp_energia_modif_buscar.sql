-- Stored Procedure: sp_energia_modif_buscar
-- Tipo: CRUD
-- Descripción: Busca el registro de energía para un local específico
-- Generado para formulario: EnergiaModif
-- Fecha: 2025-08-26 23:56:17
-- Actualizado: 2025-12-04 - Corregir referencias cross-database
-- Actualizado: 2025-12-05 - Hacer letra_local y bloque opcionales

DROP FUNCTION IF EXISTS sp_energia_modif_buscar(integer, integer, integer, varchar, integer, varchar, varchar);
DROP FUNCTION IF EXISTS sp_energia_modif_buscar(integer, integer, integer, varchar, integer);

CREATE OR REPLACE FUNCTION sp_energia_modif_buscar(
    p_oficina INTEGER,
    p_num_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR,
    p_local INTEGER,
    p_letra_local VARCHAR DEFAULT NULL,
    p_bloque VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_energia INTEGER,
    id_local INTEGER,
    cve_consumo VARCHAR,
    local_adicional VARCHAR,
    cantidad NUMERIC,
    vigencia VARCHAR,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id_energia,
        e.id_local,
        e.cve_consumo::VARCHAR,
        e.local_adicional::VARCHAR,
        e.cantidad,
        e.vigencia::VARCHAR,
        e.fecha_alta,
        e.fecha_baja,
        e.fecha_modificacion,
        e.id_usuario
    FROM publico.ta_11_locales l
    INNER JOIN publico.ta_11_energia e
        ON l.id_local = e.id_local
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (p_letra_local IS NULL OR l.letra_local IS NOT DISTINCT FROM p_letra_local)
      AND (p_bloque IS NULL OR l.bloque IS NOT DISTINCT FROM p_bloque)
    LIMIT 1;
END;
$$;

COMMENT ON FUNCTION sp_energia_modif_buscar(INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER, VARCHAR, VARCHAR) IS
'Busca el registro de energía para un local específico. Los parámetros letra_local y bloque son opcionales (DEFAULT NULL).';