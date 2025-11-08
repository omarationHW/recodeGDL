-- Stored Procedure: consultar_bloqueos
-- Tipo: Catalog
-- Descripción: Consulta todos los movimientos de bloqueo/desbloqueo de un anuncio.
-- Generado para formulario: BloquearAnunciorm
-- Fecha: 2025-08-27 16:01:27

CREATE OR REPLACE FUNCTION consultar_bloqueos(id_anuncio INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    id_licencia INTEGER,
    bloqueado SMALLINT,
    capturista TEXT,
    fecha_mov DATE,
    observa TEXT,
    estado TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        id_tramite,
        id_licencia,
        bloqueado,
        capturista,
        fecha_mov,
        observa,
        CASE WHEN bloqueado = 1 THEN 'BLOQUEADO' ELSE 'NO BLOQUEADO' END AS estado
    FROM bloqueo
    WHERE id_anuncio = consultar_bloqueos.id_anuncio
    ORDER BY fecha_mov DESC, id_tramite DESC;
END;
$$ LANGUAGE plpgsql;