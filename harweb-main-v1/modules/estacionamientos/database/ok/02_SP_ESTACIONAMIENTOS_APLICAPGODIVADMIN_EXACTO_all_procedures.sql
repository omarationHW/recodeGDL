-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: AplicaPgo_DivAdmin (EXACTO del archivo original)
-- Archivo: 02_SP_ESTACIONAMIENTOS_APLICAPGODIVADMIN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_busca_folios_divadmin
-- Tipo: Report
-- Descripción: Busca folios de adeudo según opción de búsqueda (por placa, por placa y folio, por año y folio) para pagos diversos admin.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_folios_divadmin(
    opcion integer,
    placa varchar,
    folio integer,
    axo integer
)
RETURNS TABLE (
    axo integer,
    folio integer,
    placa varchar,
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
    FROM public.ta14_folios_adeudo a
    JOIN public.ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
    LEFT JOIN public.ta14_folios_free f ON a.axo = f.axo AND a.folio = f.folio AND f.clave = 'A'
    LEFT JOIN public.ta14_notifica_edo n ON a.num_acuerdo = n.num_acuerdo AND n.num_acuerdo IS NOT NULL
    WHERE (
        (opcion = 0 AND a.placa = placa)
        OR (opcion = 1 AND a.placa = placa AND a.folio = folio)
        OR (opcion = 2 AND a.axo = axo AND a.folio = folio)
    )
    ORDER BY ord, a.axo, a.placa, a.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_aplica_pago_divadmin
-- Tipo: CRUD
-- Descripción: Aplica el pago de diversos admin para un folio específico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_aplica_pago_divadmin(
    parAxo integer,
    parFolio integer,
    parFecha date,
    parReca integer,
    parCaja varchar,
    parOper integer,
    parUsuario varchar
)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
BEGIN
    -- Aquí va la lógica de aplicación de pago, por ejemplo:
    UPDATE public.ta14_folios_adeudo
    SET estado = 2, -- ejemplo: 2 = pagado
        fecha_pago = parFecha,
        recaudadora = parReca,
        caja = parCaja,
        operacion = parOper,
        usuario_pago = parUsuario
    WHERE axo = parAxo AND folio = parFolio;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Pago aplicado correctamente';
    ELSE
        RETURN QUERY SELECT false, 'No se encontró el folio';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================