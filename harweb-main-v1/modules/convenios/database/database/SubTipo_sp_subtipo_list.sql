-- Stored Procedure: sp_subtipo_list
-- Tipo: Catalog
-- Descripción: Lista todos los subtipos de convenio con información de usuario
-- Generado para formulario: SubTipo
-- Fecha: 2025-08-27 15:59:10

CREATE OR REPLACE FUNCTION sp_subtipo_list()
RETURNS TABLE (
    tipo smallint,
    subtipo smallint,
    desc_subtipo varchar,
    cuenta_ingreso integer,
    id_usuario integer,
    fecha_actual timestamp,
    usuario varchar,
    nombre varchar,
    estado varchar,
    id_rec smallint,
    nivel smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.tipo, a.subtipo, a.desc_subtipo, a.cuenta_ingreso, a.id_usuario, a.fecha_actual,
           b.usuario, b.nombre, b.estado, b.id_rec, b.nivel
    FROM ta_17_subtipo_conv a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    ORDER BY a.tipo, a.subtipo;
END;
$$ LANGUAGE plpgsql;