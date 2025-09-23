-- Stored Procedure: rptreq_pba_get_report_data
-- Tipo: Report
-- Descripción: Obtiene los datos principales del reporte de requerimiento de pago y embargo, incluyendo cálculo de recargos y total de gastos.
-- Generado para formulario: RptReq_pba
-- Fecha: 2025-08-27 15:11:39

CREATE OR REPLACE FUNCTION rptreq_pba_get_report_data(
    vmerc1 integer,
    vmerc2 integer,
    vlocal1 integer,
    vlocal2 integer,
    vsecc text
)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local smallint,
    letra_local varchar,
    bloque varchar,
    id_contribuy_prop integer,
    id_contribuy_renta integer,
    nombre varchar,
    arrendatario varchar,
    domicilio varchar,
    sector varchar,
    zona smallint,
    descripcion_local varchar,
    superficie float,
    giro smallint,
    fecha_alta date,
    fecha_baja date,
    fecha_modificacion timestamp,
    vigencia varchar,
    id_usuario integer,
    clave_cuota smallint,
    id_adeudo_local integer,
    id_local_1 integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta_1 timestamp,
    id_usuario_1 integer,
    descripcion varchar,
    renta numeric,
    total_gasto numeric,
    recargos numeric
) AS $$
DECLARE
    vaxo integer;
    vmes integer;
    vdia integer;
    sql text;
BEGIN
    -- Obtener fecha actual del sistema
    SELECT EXTRACT(YEAR FROM CURRENT_DATE), EXTRACT(MONTH FROM CURRENT_DATE), EXTRACT(DAY FROM CURRENT_DATE)
      INTO vaxo, vmes, vdia;

    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque,
           a.id_contribuy_prop, a.id_contribuy_renta, a.nombre, a.arrendatario, a.domicilio, a.sector, a.zona,
           a.descripcion_local, a.superficie, a.giro, a.fecha_alta, a.fecha_baja, a.fecha_modificacion, a.vigencia,
           a.id_usuario, a.clave_cuota, b.id_adeudo_local, b.id_local as id_local_1, b.axo, b.periodo, b.importe,
           b.fecha_alta as fecha_alta_1, b.id_usuario as id_usuario_1, c.descripcion,
           b.importe as renta,
           COALESCE((SELECT SUM(importe_gastos) FROM ta_15_apremios WHERE modulo=11 AND control_otr=a.id_local AND clave_practicado='P' AND vigencia='1'), 0) as total_gasto,
           rptreq_pba_calc_recargos(b.axo, b.periodo, b.importe, vaxo, vmes, vdia) as recargos
    FROM ta_11_locales a
    JOIN ta_11_adeudo_local b ON a.id_local = b.id_local
    JOIN ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
    WHERE a.num_mercado >= vmerc1 AND a.num_mercado <= vmerc2
      AND (
        (b.axo < vaxo)
        OR (b.axo = vaxo AND (
            CASE WHEN vdia > 12 THEN b.periodo <= vmes ELSE b.periodo <= vmes - 1 END
        ))
      )
      AND (
        vsecc = 'todas' OR (
          a.seccion = vsecc AND a.local >= vlocal1 AND a.local <= vlocal2
        )
      );
END;
$$ LANGUAGE plpgsql;