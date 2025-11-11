-- Stored Procedure: sp_autorizades_catalogo_aplicacion
-- Tipo: Catalog
-- Descripción: Devuelve catálogo de aplicaciones (modulos) válidos para descuentos.
-- Generado para formulario: AutorizaDes
-- Fecha: 2025-08-27 13:32:56

CREATE OR REPLACE FUNCTION sp_autorizades_catalogo_aplicacion() RETURNS TABLE (
    id_modulo INTEGER,
    descripcion TEXT,
    aplicacion TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT id_modulo, descripcion, aplicacion FROM padron_licencias.comun.ta_12_modulos WHERE id_modulo IN (11,13,14,16,24,28);
END;
$$ LANGUAGE plpgsql;