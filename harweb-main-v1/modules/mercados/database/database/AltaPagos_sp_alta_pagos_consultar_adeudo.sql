-- Stored Procedure: sp_alta_pagos_consultar_adeudo
-- Tipo: CRUD
-- Descripción: Consulta el adeudo de un local para un periodo.
-- Generado para formulario: AltaPagos
-- Fecha: 2025-08-26 20:25:40

CREATE OR REPLACE FUNCTION sp_alta_pagos_consultar_adeudo(
    p_id_local integer, p_axo integer, p_periodo integer
) RETURNS TABLE(
    id_adeudo_local integer,
    id_local integer,
    axo integer,
    periodo integer,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario
    FROM ta_11_adeudo_local
    WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;