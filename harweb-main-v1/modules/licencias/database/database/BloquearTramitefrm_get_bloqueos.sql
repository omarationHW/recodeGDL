-- Stored Procedure: get_bloqueos
-- Tipo: Catalog
-- Descripción: Obtiene el historial de bloqueos/desbloqueos de un trámite.
-- Generado para formulario: BloquearTramitefrm
-- Fecha: 2025-08-27 16:06:44

CREATE OR REPLACE FUNCTION get_bloqueos(p_id_tramite integer)
RETURNS TABLE (
    id_tramite integer,
    id_licencia integer,
    bloqueado smallint,
    capturista varchar,
    fecha_mov date,
    observa varchar,
    estado varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id_tramite,
        b.id_licencia,
        b.bloqueado,
        b.capturista,
        b.fecha_mov,
        b.observa,
        CASE WHEN b.bloqueado = 1 THEN 'BLOQUEADO' ELSE 'NO BLOQUEADO' END AS estado
    FROM bloqueo b
    WHERE b.id_tramite = p_id_tramite
    ORDER BY b.fecha_mov DESC, b.id_licencia DESC;
END;
$$ LANGUAGE plpgsql;