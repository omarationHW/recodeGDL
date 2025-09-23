-- Stored Procedure: sp_listados_ade_aseo
-- Tipo: Report
-- Descripción: Obtiene listado de adeudos de aseo según filtros.
-- Generado para formulario: Listados_Ade
-- Fecha: 2025-08-27 15:21:31

CREATE OR REPLACE PROCEDURE sp_listados_ade_aseo(
    p_tipo_aseo text,
    p_contrato1 integer,
    p_contrato2 integer,
    p_id_rec integer,
    p_axo integer,
    p_mes integer
)
LANGUAGE plpgsql AS $$
BEGIN
    SELECT a.*, b.*, c.descripcion,
      (SELECT COALESCE(SUM(importe_gastos),0) FROM ta_15_apremios WHERE modulo=16 AND control_otr=a.control_contrato AND clave_practicado='P' AND vigencia='1') AS total_gasto
    FROM ta_16_contratos a
    JOIN ta_16_pagos b ON a.control_contrato = b.control_contrato
    JOIN ta_16_tipo_aseo c ON a.ctrol_aseo = c.ctrol_aseo
    WHERE a.id_rec = p_id_rec
      AND (p_tipo_aseo IS NULL OR c.tipo_aseo = p_tipo_aseo)
      AND a.num_contrato BETWEEN p_contrato1 AND p_contrato2
      AND EXTRACT(YEAR FROM b.aso_mes_pago) <= p_axo
      AND EXTRACT(MONTH FROM b.aso_mes_pago) <= p_mes
    ORDER BY a.num_contrato;
END;
$$;