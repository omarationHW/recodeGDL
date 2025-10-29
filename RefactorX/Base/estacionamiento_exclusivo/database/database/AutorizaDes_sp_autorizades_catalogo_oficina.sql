-- Stored Procedure: sp_autorizades_catalogo_oficina
-- Tipo: Catalog
-- Descripción: Devuelve catálogo de oficinas (recaudadoras).
-- Generado para formulario: AutorizaDes
-- Fecha: 2025-08-27 13:32:56

CREATE OR REPLACE FUNCTION sp_autorizades_catalogo_oficina() RETURNS TABLE (
    id_rec INTEGER,
    nombre TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, zona as nombre FROM ta_12_recaudadoras a JOIN ta_12_zonas b ON a.id_zona = b.id_zona;
END;
$$ LANGUAGE plpgsql;