-- Stored Procedure: sp_list_h_bloqueo_dom
-- Tipo: Catalog
-- Descripción: Devuelve el listado de domicilios bloqueados históricos, ordenado por los campos indicados.
-- Generado para formulario: h_bloqueoDomiciliosfrm
-- Fecha: 2025-08-26 16:58:17

CREATE OR REPLACE FUNCTION sp_list_h_bloqueo_dom(p_order TEXT DEFAULT 'calle,num_ext')
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecalle INTEGER,
    calle TEXT,
    num_ext INTEGER,
    let_ext TEXT,
    num_int INTEGER,
    let_int TEXT,
    folio INTEGER,
    fecha DATE,
    hora TIMESTAMP,
    vig TEXT,
    observacion TEXT,
    capturista TEXT,
    fecha_mov TIMESTAMP,
    motivo_mov TEXT,
    tipo_mov TEXT,
    modifico TEXT,
    procedenciamov TEXT
) AS $$
BEGIN
    RETURN QUERY EXECUTE format('SELECT *,
        CASE tipo_mov
            WHEN ''EL'' THEN ''Eliminado al Desbloquear de Licencia''
            WHEN ''ED'' THEN ''Eliminado desde Bloqueo de Domicilios''
            WHEN ''MD'' THEN ''Modificado en bloqueo de Domicilio''
            ELSE tipo_mov
        END AS procedenciamov
        FROM h_bloqueo_dom ORDER BY %s', p_order);
END;
$$ LANGUAGE plpgsql;