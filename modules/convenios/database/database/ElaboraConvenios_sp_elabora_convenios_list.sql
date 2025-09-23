-- Stored Procedure: sp_elabora_convenios_list
-- Tipo: Catalog
-- Descripción: Lista todos los registros de quienes elaboran convenios, incluyendo recaudador y nombre de quien elabora.
-- Generado para formulario: ElaboraConvenios
-- Fecha: 2025-08-27 14:29:39

CREATE OR REPLACE FUNCTION sp_elabora_convenios_list()
RETURNS TABLE (
    id_control INTEGER,
    id_rec INTEGER,
    id_usu_titular INTEGER,
    iniciales_titular VARCHAR(10),
    id_usu_elaboro INTEGER,
    iniciales_elaboro VARCHAR(10),
    recaudador VARCHAR(50),
    elaboro VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.id_rec, a.id_usu_titular, a.iniciales_titular, a.id_usu_elaboro, a.iniciales_elaboro,
           b.nombre AS recaudador,
           (SELECT nombre FROM ta_12_passwords WHERE id_usuario=a.id_usu_elaboro) AS elaboro
    FROM ta_17_elaboroficio a
    JOIN ta_12_passwords b ON b.id_usuario=a.id_usu_titular
    ORDER BY a.id_rec, a.id_usu_titular;
END;
$$ LANGUAGE plpgsql;