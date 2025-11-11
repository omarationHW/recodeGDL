-- Stored Procedure: sp_busca_folios_divadmin
-- Tipo: Report
-- Descripción: Busca folios de adeudo según opción de búsqueda (por placa, por placa y folio, por año y folio) para pagos diversos admin.
-- Generado para formulario: AplicaPgo_DivAdmin
-- Fecha: 2025-08-27 13:22:25

CREATE OR REPLACE FUNCTION sp_busca_folios_divadmin(
    opcion integer,
    placa varchar,
    folio integer,
    axo integer
)
RETURNS TABLE (
    ret_axo integer,
    ret_folio integer,
    ret_placa varchar,
    fecha_folio date,
    estado smallint,
    infraccion smallint,
    tarifa numeric,
    porc_cobro numeric,
    descripcion varchar,
    pago varchar,
    usu_inicial integer,
    notif varchar,
    num_acuerdo integer,
    costo_fijo01 numeric,
    ord varchar,
    afec varchar,
    zona smallint,
    espacio smallint,
    fecha_baja varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa,
        COALESCE(f.porc_cobro, 100) as porc_cobro,
        'Vigente' as descripcion,
        '' as pago,
        a.usu_inicial,
        n.folionot as notif,
        COALESCE(a.num_acuerdo,0) as num_acuerdo,
        b.costo_fijo01,
        CASE a.infraccion WHEN 1 THEN 'A' WHEN 2 THEN 'A' WHEN 3 THEN 'A' ELSE 'B' END as ord,
        'A' as afec,
        a.zona,
        a.espacio,
        '' as fecha_baja
    FROM ta14_folios_adeudo a
    JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
    LEFT JOIN ta14_folios_free f ON a.axo = f.axo AND a.folio = f.folio AND f.clave = 'A'
    LEFT JOIN ta14_notifica_edo n ON a.num_acuerdo = n.num_acuerdo AND n.num_acuerdo IS NOT NULL
    WHERE (
        (opcion = 0 AND a.placa = placa)
        OR (opcion = 1 AND a.placa = placa AND a.folio = folio)
        OR (opcion = 2 AND a.axo = axo AND a.folio = folio)
    )
    ORDER BY ord, a.axo, a.placa, a.folio;
END;
$$ LANGUAGE plpgsql;