-- Stored Procedure: sp_get_bloqueos_by_tramite
-- Tipo: Catalog
-- Descripción: Obtiene todos los movimientos de bloqueo/desbloqueo de un trámite.
-- Generado para formulario: BloquearTramitefrm
-- Fecha: 2025-08-26 14:42:36

CREATE OR REPLACE FUNCTION sp_get_bloqueos_by_tramite(p_id_tramite INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    id_licencia INTEGER,
    bloqueado SMALLINT,
    capturista VARCHAR(10),
    fecha_mov DATE,
    observa VARCHAR(80),
    vigente VARCHAR(1),
    estado VARCHAR(20)
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
        b.vigente,
        CASE WHEN b.bloqueado = 1 THEN 'BLOQUEADO' ELSE 'NO BLOQUEADO' END AS estado
    FROM bloqueo b
    WHERE b.id_tramite = p_id_tramite
    ORDER BY b.fecha_mov DESC;
END;
$$ LANGUAGE plpgsql;