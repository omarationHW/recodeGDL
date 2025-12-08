-- ================================================================
-- DEPLOY: ABC_Recaudadoras - COMPLETO
-- Módulo: aseo_contratado
-- Fecha: 2025-11-26
-- Descripción: Deploy completo de todos los SPs de ABC_Recaudadoras
-- ================================================================

\echo '=================================================='
\echo 'DEPLOY: ABC_Recaudadoras - Stored Procedures'
\echo 'Fecha: 2025-11-26'
\echo '=================================================='

\echo ''
\echo 'Creando SP 1/5: sp_list_recaudadoras...'

CREATE OR REPLACE FUNCTION sp_list_recaudadoras(p_search VARCHAR DEFAULT NULL)
RETURNS TABLE(
    num_rec SMALLINT,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.num_rec,
        r.descripcion
    FROM ta_16_recaudadoras r
    WHERE
        p_search IS NULL
        OR r.descripcion ILIKE '%' || p_search || '%'
        OR CAST(r.num_rec AS TEXT) LIKE '%' || p_search || '%'
    ORDER BY r.num_rec;
END;
$$ LANGUAGE plpgsql;

\echo 'SP sp_list_recaudadoras creado exitosamente.'

-- ============================================

\echo ''
\echo 'Creando SP 2/5: sp_get_next_num_recaudadora...'

CREATE OR REPLACE FUNCTION sp_get_next_num_recaudadora()
RETURNS TABLE(next_num SMALLINT) AS $$
BEGIN
    RETURN QUERY
    SELECT COALESCE(MAX(num_rec), 0) + 1 AS next_num
    FROM ta_16_recaudadoras;
END;
$$ LANGUAGE plpgsql;

\echo 'SP sp_get_next_num_recaudadora creado exitosamente.'

-- ============================================

\echo ''
\echo 'Creando SP 3/5: sp_insert_recaudadora...'

CREATE OR REPLACE FUNCTION sp_insert_recaudadora(p_num_rec SMALLINT, p_descripcion VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_recaudadoras WHERE num_rec = p_num_rec) THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una recaudadora con ese número.';
    ELSE
        INSERT INTO ta_16_recaudadoras(num_rec, descripcion) VALUES (p_num_rec, p_descripcion);
        RETURN QUERY SELECT TRUE, 'Recaudadora agregada correctamente.';
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'SP sp_insert_recaudadora creado exitosamente.'

-- ============================================

\echo ''
\echo 'Creando SP 4/5: sp_update_recaudadora...'

CREATE OR REPLACE FUNCTION sp_update_recaudadora(p_num_rec SMALLINT, p_descripcion VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ta_16_recaudadoras WHERE num_rec = p_num_rec) THEN
        RETURN QUERY SELECT FALSE, 'No existe la recaudadora.';
    ELSE
        UPDATE ta_16_recaudadoras SET descripcion = p_descripcion WHERE num_rec = p_num_rec;
        RETURN QUERY SELECT TRUE, 'Recaudadora actualizada correctamente.';
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'SP sp_update_recaudadora creado exitosamente.'

-- ============================================

\echo ''
\echo 'Creando SP 5/5: sp_delete_recaudadora...'

CREATE OR REPLACE FUNCTION sp_delete_recaudadora(p_num_rec SMALLINT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_16_contratos WHERE id_rec = p_num_rec;
    IF v_count > 0 THEN
        RETURN QUERY SELECT FALSE, 'No se puede eliminar: existen contratos asociados.';
    END IF;
    DELETE FROM ta_16_recaudadoras WHERE num_rec = p_num_rec;
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Recaudadora eliminada correctamente.';
    ELSE
        RETURN QUERY SELECT FALSE, 'No existe la recaudadora.';
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'SP sp_delete_recaudadora creado exitosamente.'

-- ============================================

\echo ''
\echo '=================================================='
\echo 'DEPLOY COMPLETADO'
\echo 'Total SPs creados: 5'
\echo '  - sp_list_recaudadoras'
\echo '  - sp_get_next_num_recaudadora'
\echo '  - sp_insert_recaudadora'
\echo '  - sp_update_recaudadora'
\echo '  - sp_delete_recaudadora'
\echo '=================================================='
