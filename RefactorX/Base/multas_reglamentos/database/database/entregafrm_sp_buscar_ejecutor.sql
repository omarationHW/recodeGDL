-- Stored Procedure: sp_buscar_ejecutor
-- Tipo: Catalog
-- Descripción: Busca ejecutores por número o nombre.
-- Generado para formulario: entregafrm
-- Fecha: 2025-08-27 11:57:32

CREATE OR REPLACE FUNCTION sp_buscar_ejecutor(
    p_criterio TEXT,
    p_tipo TEXT
) RETURNS TABLE (
    cveejecutor INTEGER,
    paterno TEXT,
    materno TEXT,
    nombres TEXT,
    recaud INTEGER,
    ncompleto TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    IF p_tipo = 'numero' THEN
        RETURN QUERY SELECT cveejecutor, paterno, materno, nombres, recaud, TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres) as ncompleto
        FROM ejecutor WHERE cveejecutor = p_criterio::INTEGER;
    ELSE
        RETURN QUERY SELECT cveejecutor, paterno, materno, nombres, recaud, TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres) as ncompleto
        FROM ejecutor WHERE (TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres)) ILIKE '%'||p_criterio||'%';
    END IF;
END;
$$;