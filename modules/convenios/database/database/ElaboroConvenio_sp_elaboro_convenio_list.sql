-- Stored Procedure: sp_elaboro_convenio_list
-- Tipo: Catalog
-- Descripción: Obtiene la lista de registros de quien elaboró convenio, incluyendo nombres de usuarios.
-- Generado para formulario: ElaboroConvenio
-- Fecha: 2025-08-27 14:31:25

CREATE OR REPLACE FUNCTION sp_elaboro_convenio_list()
RETURNS TABLE (
    id_control integer,
    id_rec integer,
    id_usu_titular integer,
    iniciales_titular varchar(10),
    id_usu_elaboro integer,
    iniciales_elaboro varchar(10),
    titular varchar(50),
    elaboro varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.id_rec, a.id_usu_titular, a.iniciales_titular, a.id_usu_elaboro, a.iniciales_elaboro,
           b.nombre AS titular,
           (SELECT nombre FROM ta_12_passwords WHERE id_usuario=a.id_usu_elaboro) AS elaboro
    FROM ta_17_elaboroficio a
    JOIN ta_12_passwords b ON b.id_usuario = a.id_usu_titular;
END;
$$ LANGUAGE plpgsql;