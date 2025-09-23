-- Stored Procedure: report_folios_elaborados_usuario
-- Tipo: Report
-- Descripción: Devuelve los folios elaborados por el usuario actual (vigila) en una fecha dada, tanto vigentes como históricos.
-- Generado para formulario: sfrm_report_pagos
-- Fecha: 2025-08-27 14:28:30

CREATE OR REPLACE FUNCTION report_folios_elaborados_usuario(p_fechora date, p_vigila integer)
RETURNS TABLE (
    vigilante integer,
    inspector varchar(100),
    axo smallint,
    folio integer,
    placa varchar(10),
    fecha_folio date,
    estado smallint,
    infraccion smallint,
    tarifa numeric(12,2),
    descripcion varchar(100),
    usu_inicial integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.vigilante,
           TRIM(COALESCE(c.ap_pater, '.')) || ' ' || TRIM(COALESCE(c.ap_mater, '.')) || ' ' || TRIM(COALESCE(c.nombre, '.')) AS inspector,
           a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa, 'Vigente' AS descripcion, a.usu_inicial
    FROM ta14_folios_adeudo a
    JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
    JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
    WHERE a.fecha_folio = p_fechora AND a.usu_inicial = p_vigila
    UNION ALL
    SELECT a.vigilante,
           TRIM(COALESCE(c.ap_pater, '.')) || ' ' || TRIM(COALESCE(c.ap_mater, '.')) || ' ' || TRIM(COALESCE(c.nombre, '.')) AS inspector,
           a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa, d.descripcion, a.usu_inicial
    FROM ta14_folios_histo a
    JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
    JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
    JOIN ta14_codigomovtos d ON a.codigo_movto = d.codigo_movto
    WHERE a.fecha_folio = p_fechora AND a.usu_inicial = p_vigila
    ORDER BY 1,3,4;
END;
$$ LANGUAGE plpgsql;