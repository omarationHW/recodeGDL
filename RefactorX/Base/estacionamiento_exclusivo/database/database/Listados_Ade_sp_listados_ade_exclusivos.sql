-- Stored Procedure: sp_listados_ade_exclusivos
-- Tipo: Report
-- Descripción: Obtiene listado de adeudos de estacionamientos exclusivos.
-- Generado para formulario: Listados_Ade
-- Fecha: 2025-08-27 15:21:31

CREATE OR REPLACE PROCEDURE sp_listados_ade_exclusivos(
    p_no_exclusivo1 integer,
    p_no_exclusivo2 integer,
    p_axo integer,
    p_mes integer,
    p_impd numeric,
    p_imph numeric,
    p_id_rec integer
)
LANGUAGE plpgsql AS $$
BEGIN
    SELECT a.*, b.*, c.tipo, b.ade_importe AS adeudo, d.propietario, e.calle,
      (SELECT COALESCE(SUM(importe_gastos),0) FROM ta_15_apremios WHERE modulo=28 AND control_otr=a.id AND clave_practicado='P' AND vigencia='1') AS total_gasto
    FROM ex_contrato a
    JOIN ex_adeudo b ON b.ex_contrato_id = a.id
    JOIN pubtipoadeudo c ON c.tipo_id = b.tipo
    JOIN ex_propietario d ON d.id = a.ex_propietario_id
    JOIN ex_ubicacion e ON e.ex_contrato_id = a.id
    WHERE a.estatus = 'V'
      AND a.no_exclusivo BETWEEN p_no_exclusivo1 AND p_no_exclusivo2
      AND ((b.axo < p_axo) OR (b.axo = p_axo AND b.mes <= p_mes))
      AND b.ade_importe BETWEEN p_impd AND p_imph
      AND a.id_rec = p_id_rec
    ORDER BY a.no_exclusivo, b.axo, b.mes;
END;
$$;