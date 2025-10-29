-- Stored Procedure: sp_consultar_bloqueos
-- Tipo: Report
-- Descripción: Consulta todos los movimientos de bloqueo/desbloqueo de un anuncio.
-- Generado para formulario: BloquearAnunciorm
-- Fecha: 2025-08-26 14:36:16

CREATE OR REPLACE FUNCTION sp_consultar_bloqueos(p_id_anuncio INTEGER)
RETURNS TABLE (
    id_bloqueo INTEGER,
    id_tramite INTEGER,
    id_licencia INTEGER,
    bloqueado SMALLINT,
    capturista VARCHAR,
    fecha_mov DATE,
    observa VARCHAR,
    estado VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        id_bloqueo,
        id_tramite,
        id_licencia,
        bloqueado,
        capturista,
        fecha_mov,
        observa,
        CASE WHEN bloqueado = 1 THEN 'BLOQUEADO' ELSE 'NO BLOQUEADO' END AS estado
    FROM bloqueo
    WHERE id_anuncio = p_id_anuncio
    ORDER BY fecha_mov DESC, id_bloqueo DESC;
END;
$$ LANGUAGE plpgsql;