-- Stored Procedure: sp_intereses_list
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo completo de intereses, incluyendo usuario.
-- Generado para formulario: Intereses
-- Fecha: 2025-08-27 14:47:29

CREATE OR REPLACE FUNCTION sp_intereses_list()
RETURNS TABLE (
    axo smallint,
    mes smallint,
    porcentaje numeric(12,8),
    id_usuario integer,
    fecha_actual timestamp,
    usuario varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.axo, a.mes, a.porcentaje, a.id_usuario, a.fecha_actual, b.usuario
    FROM ta_12_intereses a
    JOIN ta_12_passwords b ON b.id_usuario = a.id_usuario
    ORDER BY a.axo ASC, a.mes ASC;
END;
$$ LANGUAGE plpgsql;