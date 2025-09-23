-- Stored Procedure: sp_listados_ade_publicos
-- Tipo: Report
-- Descripción: Obtiene listado de adeudos de estacionamientos públicos.
-- Generado para formulario: Listados_Ade
-- Fecha: 2025-08-27 15:21:31

CREATE OR REPLACE PROCEDURE sp_listados_ade_publicos(
    p_numesta1 integer,
    p_numesta2 integer,
    p_axo integer,
    p_mes integer,
    p_impd numeric,
    p_imph numeric,
    p_id_rec integer
)
LANGUAGE plpgsql AS $$
BEGIN
    SELECT a.*, b.*, c.tipo, b.ade_importe AS adeudo,
      (SELECT COALESCE(SUM(importe_gastos),0) FROM ta_15_apremios WHERE modulo=24 AND control_otr=a.id AND clave_practicado='P' AND vigencia='1') AS total_gasto
    FROM pubmain a
    JOIN pubadeudo b ON b.pubmain_id = a.id
    JOIN pubtipoadeudo c ON c.tipo_id = b.tipo
    WHERE a.fecha_baja IS NULL
      AND a.numesta BETWEEN p_numesta1 AND p_numesta2
      AND ((b.axo < p_axo) OR (b.axo = p_axo AND b.mes <= p_mes))
      AND b.ade_importe BETWEEN p_impd AND p_imph
      AND a.id_rec = p_id_rec
    ORDER BY a.numesta, b.axo, b.mes;
END;
$$;