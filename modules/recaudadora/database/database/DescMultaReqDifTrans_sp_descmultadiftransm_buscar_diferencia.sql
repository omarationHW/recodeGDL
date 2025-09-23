-- Stored Procedure: sp_descmultadiftransm_buscar_diferencia
-- Tipo: Report
-- Descripción: Busca diferencias de transmisión con multa vigente por folio
-- Generado para formulario: DescMultaReqDifTrans
-- Fecha: 2025-08-27 00:14:47

CREATE OR REPLACE FUNCTION sp_descmultadiftransm_buscar_diferencia(p_folio INTEGER)
RETURNS TABLE(
    id_descmulta INTEGER,
    foliot INTEGER,
    porcentaje INTEGER,
    fecalta DATE,
    captalta VARCHAR,
    fecbaja DATE,
    captbaja VARCHAR,
    estado VARCHAR,
    cvepago INTEGER,
    folio INTEGER,
    autoriza INTEGER,
    cvedepto INTEGER,
    autoriza_nombre VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_descmulta, a.foliot, a.porcentaje, a.fecalta, a.captalta, a.fecbaja, a.captbaja, a.estado, a.cvepago, a.folio, a.autoriza, a.cvedepto, c.nombre as autoriza_nombre, c.descripcion
    FROM descmultadiftransm a
    LEFT JOIN c_autdescmul c ON a.autoriza = c.cveautoriza
    WHERE a.foliot = p_folio AND a.estado = 'V';
END;
$$ LANGUAGE plpgsql;