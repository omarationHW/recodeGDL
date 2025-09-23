-- Stored Procedure: sp_reqtransm_catalog_ejecutor
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de ejecutores activos
-- Generado para formulario: ReqTrans
-- Fecha: 2025-08-27 15:05:46

CREATE OR REPLACE FUNCTION sp_reqtransm_catalog_ejecutor() RETURNS TABLE(
    cveejecutor integer,
    nombres varchar,
    paterno varchar,
    materno varchar
) AS $$
BEGIN
    RETURN QUERY SELECT cveejecutor, nombres, paterno, materno FROM ejecutor WHERE vigencia = 'V' ORDER BY cveejecutor;
END;
$$ LANGUAGE plpgsql;