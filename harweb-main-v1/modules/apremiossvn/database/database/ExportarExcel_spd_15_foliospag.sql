-- Stored Procedure: spd_15_foliospag
-- Tipo: Report
-- Descripción: Obtiene los folios pagos según filtros de recaudadora, módulo, folio, fechas de emisión y pago.
-- Generado para formulario: ExportarExcel
-- Fecha: 2025-08-27 13:46:54

-- PostgreSQL version of spd_15_foliospag
CREATE OR REPLACE FUNCTION spd_15_foliospag(
    prec integer,
    pmod integer,
    pfold integer,
    pfolh integer,
    pfemi date,
    pfpagd date,
    pfpagh date
)
RETURNS TABLE (
    idcontrol integer,
    moddulo integer,
    idmodulo integer,
    folio integer,
    fechaemision date,
    importepago numeric,
    fechapago date,
    perinicial text,
    perfinal text,
    registro text
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_control AS idcontrol,
        a.modulo AS moddulo,
        a.control_otr AS idmodulo,
        a.folio,
        a.fecha_emision AS fechaemision,
        COALESCE(SUM(b.importe_pago), 0) AS importepago,
        b.fecha_pago AS fechapago,
        -- Periodo inicial
        (
            SELECT CONCAT(MIN(ayo), '-', MIN(periodo))
            FROM ta_15_periodos WHERE control_otr = a.id_control
        ) AS perinicial,
        -- Periodo final
        (
            SELECT CONCAT(MAX(axo), '-', MAX(periodo))
            FROM ta_11_pagos_local WHERE id_local = b.id_local
        ) AS perfinal,
        -- Registro (local)
        (
            SELECT CONCAT(oficina, '-', num_mercado, '-', categoria, '-', seccion, '-', local, '-', COALESCE(letra_local, ''), '-', COALESCE(bloque, ''))
            FROM ta_11_locales WHERE id_local = b.id_local
        ) AS registro
    FROM ta_15_apremios a
    JOIN ta_11_pagos_local b ON b.id_local = a.control_otr
    WHERE a.zona = prec
      AND a.fecha_emision = pfemi
      AND b.fecha_pago BETWEEN pfpagd AND pfpagh
      AND a.modulo = pmod
      AND a.folio BETWEEN pfold AND pfolh
    GROUP BY a.id_control, a.modulo, a.control_otr, a.folio, a.fecha_emision, b.fecha_pago, b.id_local;
END;
$$ LANGUAGE plpgsql;