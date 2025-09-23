-- Stored Procedure: sp_autorizades_catalogo_quien
-- Tipo: Catalog
-- Descripción: Devuelve catálogo de personas autorizadas para descuentos según permisos del usuario.
-- Generado para formulario: AutorizaDes
-- Fecha: 2025-08-27 13:32:56

CREATE OR REPLACE FUNCTION sp_autorizades_catalogo_quien(
    p_usuario_id INTEGER
) RETURNS TABLE (
    cveaut INTEGER,
    quien TEXT,
    nombre TEXT,
    porcentajetope INTEGER
) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_autoriza WHERE id_modulo = 15 AND id_usuario = p_usuario_id AND tag = 26) THEN
        RETURN QUERY SELECT cveaut, quien, nombre, porcentajetope FROM ta_15_quienautor WHERE vigencia = 'V' ORDER BY cveaut DESC;
    ELSE
        RETURN QUERY SELECT cveaut, quien, nombre, porcentajetope FROM ta_15_quienautor WHERE funcionario = 'N' AND vigencia = 'V';
    END IF;
END;
$$ LANGUAGE plpgsql;