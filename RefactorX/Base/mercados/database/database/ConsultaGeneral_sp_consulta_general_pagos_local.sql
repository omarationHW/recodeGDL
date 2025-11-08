-- Stored Procedure: sp_consulta_general_pagos_local
-- Tipo: CRUD
-- Descripción: Obtiene pagos de un local
-- Generado para formulario: ConsultaGeneral
-- Fecha: 2025-08-27 20:45:14

CREATE OR REPLACE FUNCTION sp_consulta_general_pagos_local(
    p_id_local integer
) RETURNS TABLE(
    axo integer,
    periodo integer,
    fecha_pago date,
    importe_pago numeric,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.axo, p.periodo, p.fecha_pago, p.importe_pago, u.usuario
    FROM ta_11_pagos_local p
    LEFT JOIN ta_12_passwords u ON p.id_usuario = u.id_usuario
    WHERE p.id_local = p_id_local
    ORDER BY p.axo, p.periodo;
END;
$$ LANGUAGE plpgsql;