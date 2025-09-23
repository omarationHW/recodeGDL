-- Stored Procedure: sp_descmultadiftransm_autorizadores
-- Tipo: Catalog
-- Descripción: Obtiene lista de autorizadores de descuentos de multa para el usuario
-- Generado para formulario: DescMultaReqDifTrans
-- Fecha: 2025-08-27 00:14:47

CREATE OR REPLACE FUNCTION sp_descmultadiftransm_autorizadores(p_usuario VARCHAR)
RETURNS TABLE(
    cveautoriza INTEGER,
    descripcion VARCHAR,
    nombre VARCHAR,
    porcentajetope INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT cveautoriza, descripcion, nombre, porcentajetope
    FROM c_autdescmul
    WHERE vigencia = 'V';
END;
$$ LANGUAGE plpgsql;