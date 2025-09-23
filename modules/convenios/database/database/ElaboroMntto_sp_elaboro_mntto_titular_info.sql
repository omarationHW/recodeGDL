-- Stored Procedure: sp_elaboro_mntto_titular_info
-- Tipo: Catalog
-- Descripción: Obtiene información de titular y elabora para mostrar en el formulario
-- Generado para formulario: ElaboroMntto
-- Fecha: 2025-08-27 14:33:12

CREATE OR REPLACE FUNCTION sp_elaboro_mntto_titular_info(
    p_id_rec integer,
    p_id_usu_titular integer,
    p_id_usu_elaboro integer
) RETURNS TABLE(
    recaudadora varchar,
    usutitular varchar,
    titular varchar,
    usuelabora varchar,
    elabora varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.recaudadora,
        t.usuario as usutitular,
        t.nombre as titular,
        e.usuario as usuelabora,
        e.nombre as elabora
    FROM ta_12_passwords t
    JOIN ta_12_recaudadoras r ON r.id_rec = t.id_rec
    JOIN ta_12_passwords e ON e.id_usuario = p_id_usu_elaboro AND e.id_rec = t.id_rec AND e.estado = t.estado
    WHERE t.id_usuario = p_id_usu_titular AND t.id_rec = p_id_rec AND t.estado = 'A';
END;
$$ LANGUAGE plpgsql;