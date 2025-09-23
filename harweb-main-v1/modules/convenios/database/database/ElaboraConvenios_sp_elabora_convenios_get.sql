-- Stored Procedure: sp_elabora_convenios_get
-- Tipo: Catalog
-- Descripción: Obtiene un registro específico de quien elabora convenios.
-- Generado para formulario: ElaboraConvenios
-- Fecha: 2025-08-27 14:29:39

CREATE OR REPLACE FUNCTION sp_elabora_convenios_get(
    p_id_control INTEGER
) RETURNS TABLE (
    id_control INTEGER,
    id_rec INTEGER,
    id_usu_titular INTEGER,
    iniciales_titular VARCHAR(10),
    id_usu_elaboro INTEGER,
    iniciales_elaboro VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY SELECT id_control, id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro
    FROM ta_17_elaboroficio WHERE id_control = p_id_control;
END;
$$ LANGUAGE plpgsql;