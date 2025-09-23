-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: LigaRequisitos
-- Generado: 2025-08-27 18:39:43
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_ligarequisito_add
-- Tipo: CRUD
-- Descripción: Agrega un requisito a un giro (tabla giro_req)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_ligarequisito_add(p_id_giro INTEGER, p_req INTEGER, p_usuario TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM giro_req WHERE id_giro = p_id_giro AND req = p_req) THEN
        RAISE EXCEPTION 'El requisito ya está ligado a este giro';
    END IF;
    INSERT INTO giro_req (id_giro, req) VALUES (p_id_giro, p_req);
    -- Opcional: registrar en bitácora
END;
$$;

-- ============================================

-- SP 2/3: sp_ligarequisito_remove
-- Tipo: CRUD
-- Descripción: Elimina un requisito de un giro (tabla giro_req)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_ligarequisito_remove(p_id_giro INTEGER, p_req INTEGER, p_usuario TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM giro_req WHERE id_giro = p_id_giro AND req = p_req) THEN
        RAISE EXCEPTION 'El requisito no está ligado a este giro';
    END IF;
    DELETE FROM giro_req WHERE id_giro = p_id_giro AND req = p_req;
    -- Opcional: registrar en bitácora
END;
$$;

-- ============================================

-- SP 3/3: sp_ligarequisito_report
-- Tipo: Report
-- Descripción: Devuelve el listado de giros y sus requisitos ligados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ligarequisito_report()
RETURNS TABLE(
    id_giro INTEGER,
    descripcion TEXT,
    req INTEGER,
    req_descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT g.id_giro, g.descripcion, r.req, gr.descripcion
    FROM c_giros g
    LEFT JOIN giro_req r ON g.id_giro = r.id_giro
    LEFT JOIN c_girosreq gr ON r.req = gr.req
    WHERE g.id_giro > 500 AND g.tipo = 'L'
    ORDER BY g.descripcion, r.req;
END;
$$ LANGUAGE plpgsql;

-- ============================================

