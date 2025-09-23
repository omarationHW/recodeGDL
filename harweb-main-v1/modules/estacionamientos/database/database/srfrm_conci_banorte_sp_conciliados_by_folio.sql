-- Stored Procedure: sp_conciliados_by_folio
-- Tipo: Report
-- Descripción: Obtiene los registros conciliados por año y folio, con estatus calculado.
-- Generado para formulario: srfrm_conci_banorte
-- Fecha: 2025-08-27 15:02:35

CREATE OR REPLACE FUNCTION sp_conciliados_by_folio(p_axo integer, p_folio integer)
RETURNS TABLE (
    rowid integer,
    axo smallint,
    folio integer,
    fecha_folio date,
    placa varchar(7),
    infraccion smallint,
    fec_pago date,
    folio_pago varchar(21),
    medio_pago varchar(2),
    forma_pago varchar(2),
    importe_bruto numeric,
    importe_neto numeric,
    fecha_venci date,
    sucursal integer,
    hora_banco varchar(6),
    estatus_banco varchar(1),
    usu_carga integer,
    fecha_afectacion date,
    status_mpio smallint,
    placa_cambio varchar(7),
    fec_placa_cambio date,
    fec_carga_ascii date,
    fec_caja date,
    operacion integer,
    caja_ingre varchar(1),
    reca smallint,
    stat varchar(30)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.rowid, a.axo, a.folio, a.fecha_folio, a.placa, a.infraccion, a.fec_pago, a.folio_pago, a.medio_pago, a.forma_pago, a.importe_bruto, a.importe_neto, a.fecha_venci, a.sucursal, a.hora_banco, a.estatus_banco, a.usu_carga, a.fecha_afectacion, a.status_mpio, a.placa_cambio, a.fec_placa_cambio, a.fec_carga_ascii, a.fec_caja, a.operacion, a.caja_ingre, a.reca,
        CASE 
            WHEN a.status_mpio = 0 THEN 'OK'
            WHEN a.status_mpio = 1 THEN 'Doble'
            WHEN a.status_mpio = 9 THEN 'Alta'
            WHEN a.status_mpio = 4 THEN 'Er. placa'
            WHEN a.status_mpio = 5 THEN 'Histo Er. placa'
            WHEN a.status_mpio = 6 THEN 'Banorte Er. placa'
            WHEN a.status_mpio = 10 THEN 'Banorte anterioridad'
            ELSE 'Sin Afect'
        END AS stat
    FROM ta14_fol_banorte a
    WHERE a.status_mpio <> 0 AND a.axo = p_axo AND a.folio = p_folio
    ORDER BY a.status_mpio;
END;
$$ LANGUAGE plpgsql;