-- Stored Procedure: sp_del34_gen_contrato
-- Tipo: CRUD
-- Descripción: Aplica la baja/cancelación de una concesión.
-- Generado para formulario: GBaja
-- Fecha: 2025-08-27 13:58:32

CREATE OR REPLACE FUNCTION sp_del34_gen_contrato(par_tabla TEXT, par_id_34_datos INTEGER, par_Axo_Fin INTEGER, par_Mes_Fin INTEGER, par_usuario TEXT)
RETURNS TABLE (
    status INTEGER,
    concepto_status TEXT
) AS $$
DECLARE
    tiene_adeudos INTEGER;
BEGIN
    -- Verifica si hay adeudos pendientes
    SELECT COUNT(*) INTO tiene_adeudos
    FROM t34_conceptos c
    WHERE c.cve_tab = par_tabla AND c.id_datos = par_id_34_datos AND (c.axo > par_Axo_Fin OR (c.axo = par_Axo_Fin AND c.mes > par_Mes_Fin));
    IF tiene_adeudos > 0 THEN
        RETURN QUERY SELECT -1, 'No es posible dar de baja, existen adeudos posteriores.';
        RETURN;
    END IF;
    -- Aplica la baja (actualiza status y fecha_fin)
    UPDATE t34_datos SET status = 'CANCELADO', fecha_fin = make_date(par_Axo_Fin, par_Mes_Fin, 1), usuario_baja = par_usuario WHERE id_34_datos = par_id_34_datos;
    RETURN QUERY SELECT 1, 'Se ejecutó correctamente la Cancelación del Local/Concesión.';
END;
$$ LANGUAGE plpgsql;