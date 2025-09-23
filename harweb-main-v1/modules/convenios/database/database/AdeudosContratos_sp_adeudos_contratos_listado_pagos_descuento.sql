-- Stored Procedure: sp_adeudos_contratos_listado_pagos_descuento
-- Tipo: Report
-- Descripción: Listado de contratos que pagaron con descuento
-- Generado para formulario: AdeudosContratos
-- Fecha: 2025-08-27 13:38:13

CREATE OR REPLACE FUNCTION sp_adeudos_contratos_listado_pagos_descuento(p_colonia integer)
RETURNS TABLE(
    colonia integer,
    calle integer,
    folio integer,
    fecha_pago date,
    oficina_pago integer,
    caja_pago text,
    operacion_pago integer,
    pago_parcial integer,
    total_parciales integer,
    importe numeric,
    cve_descuento integer,
    cve_bonificacion integer,
    descripcion text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.colonia, a.calle, a.folio, b.fecha_pago, b.oficina_pago, b.caja_pago, b.operacion_pago,
           b.pago_parcial, b.total_parciales, b.importe, b.cve_descuento, b.cve_bonificacion, c.descripcion
    FROM ta_17_convenios a
    JOIN ta_17_pagos b ON a.id_convenio = b.id_convenio
    JOIN ta_17_colonias c ON a.colonia = c.colonia
    WHERE a.colonia = p_colonia AND b.cve_descuento > 0
    ORDER BY a.colonia, a.calle, a.folio;
END;
$$ LANGUAGE plpgsql;