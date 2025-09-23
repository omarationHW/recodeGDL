-- Stored Procedure: sp_get_clave_by_vigencia
-- Tipo: Catalog
-- Descripción: Obtiene la clave por vigencia
-- Generado para formulario: ConsRequerimientos
-- Fecha: 2025-08-26 23:23:01

CREATE OR REPLACE FUNCTION sp_get_clave_by_vigencia(
    p_vigencia varchar
)
RETURNS TABLE (
    id_clave integer,
    tipo_clave smallint,
    concepto_tipo varchar,
    clave varchar,
    descrip varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_clave, tipo_clave, concepto_tipo, clave, descrip
    FROM ta_15_claves
    WHERE tipo_clave = 5 AND clave = p_vigencia;
END;
$$ LANGUAGE plpgsql;