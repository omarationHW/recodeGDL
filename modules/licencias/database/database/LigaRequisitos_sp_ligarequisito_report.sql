-- Stored Procedure: sp_ligarequisito_report
-- Tipo: Report
-- Descripción: Devuelve el listado de giros y sus requisitos ligados
-- Generado para formulario: LigaRequisitos
-- Fecha: 2025-08-27 18:39:43

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