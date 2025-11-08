-- Stored Procedure: catalogo_scian_get_by_id
-- Tipo: Catalog
-- Descripción: Devuelve un registro de c_scian por su código_scian.
-- Generado para formulario: BusquedaScianFrm
-- Fecha: 2025-08-26 14:57:37

CREATE OR REPLACE FUNCTION catalogo_scian_get_by_id(codigo_scian_in INTEGER)
RETURNS TABLE (
    codigo_scian INTEGER,
    descripcion VARCHAR,
    vigente CHAR(1),
    es_microgenerador CHAR(1),
    microgenerador_a CHAR(1),
    microgenerador_b CHAR(1),
    microgenerador_c CHAR(1),
    microgenerador_d CHAR(1),
    fecha_alta TIMESTAMP,
    usuario_alta VARCHAR,
    fecha_baja TIMESTAMP,
    usuario_baja VARCHAR,
    tipo CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM c_scian WHERE codigo_scian = codigo_scian_in;
END;
$$ LANGUAGE plpgsql;