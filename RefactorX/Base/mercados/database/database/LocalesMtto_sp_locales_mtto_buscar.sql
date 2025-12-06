-- Stored Procedure: sp_locales_mtto_buscar
-- Tipo: CRUD
-- Descripción: Verifica si existe un local con los datos dados
-- Generado para formulario: LocalesMtto
-- Fecha: 2025-12-05
-- Base: padron_licencias

DROP FUNCTION IF EXISTS sp_locales_mtto_buscar(integer, integer, integer, varchar, integer, varchar, varchar);
DROP FUNCTION IF EXISTS sp_locales_mtto_buscar(integer, integer, integer, varchar, integer);

CREATE OR REPLACE FUNCTION sp_locales_mtto_buscar(
    p_oficina INTEGER,
    p_num_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR,
    p_local INTEGER,
    p_letra_local VARCHAR DEFAULT NULL,
    p_bloque VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    existe BOOLEAN,
    id_local INTEGER,
    mensaje VARCHAR
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_count INTEGER;
    v_id_local INTEGER;
BEGIN
    -- Buscar si existe el local
    SELECT COUNT(*), MAX(l.id_local)
    INTO v_count, v_id_local
    FROM comun.ta_11_locales l
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (p_letra_local IS NULL OR l.letra_local IS NOT DISTINCT FROM p_letra_local)
      AND (p_bloque IS NULL OR l.bloque IS NOT DISTINCT FROM p_bloque);

    -- Retornar resultado
    IF v_count > 0 THEN
        RETURN QUERY SELECT TRUE, v_id_local, 'El local ya existe'::VARCHAR;
    ELSE
        RETURN QUERY SELECT FALSE, NULL::INTEGER, 'Local no encontrado'::VARCHAR;
    END IF;
END;
$$;

COMMENT ON FUNCTION sp_locales_mtto_buscar(INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER, VARCHAR, VARCHAR) IS
'Verifica si existe un local con los datos proporcionados. Retorna existe=TRUE si el local ya existe, FALSE si no existe.';
