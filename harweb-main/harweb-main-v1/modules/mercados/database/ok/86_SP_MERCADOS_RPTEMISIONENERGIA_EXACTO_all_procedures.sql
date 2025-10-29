-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptEmisionEnergia
-- Generado: 2025-08-27 00:53:11
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_rpt_emision_energia
-- Tipo: Report
-- Descripción: Obtiene la emisión de recibos de energía eléctrica para una oficina, mercado, año y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rpt_emision_energia(
    p_oficina INTEGER,
    p_mercado INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER
)
RETURNS TABLE (
    id_energia INTEGER,
    datoslocal TEXT,
    nombre TEXT,
    descripcion TEXT,
    cuenta_energia INTEGER,
    local_adicional TEXT,
    cantidad NUMERIC,
    importe_energia NUMERIC,
    descripcion_consumo TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_energia,
        CONCAT(a.oficina, ' ', a.num_mercado, ' ', a.categoria, ' ', a.seccion, ' ', a.local, ' ', COALESCE(a.letra_local, ''), ' ', COALESCE(a.bloque, '')) AS datoslocal,
        a.nombre,
        b.descripcion,
        b.cuenta_energia,
        d.local_adicional,
        d.cantidad,
        (d.cantidad * c.importe) AS importe_energia,
        CASE WHEN d.cve_consumo = 'F' THEN 'CONSUMO DE ENERGIA ELECTRICA' ELSE 'SERVICIO MEDIDO ENERGIA ELEC.' END AS descripcion_consumo
    FROM public.ta_11_locales a
    JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
    JOIN public.ta_11_kilowhatts c ON c.axo = p_axo AND c.periodo = p_periodo
    JOIN public.ta_11_energia d ON a.id_local = d.id_local
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_mercado
      AND a.vigencia = 'A'
      AND d.vigencia = 'E'
    GROUP BY d.id_energia, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, b.descripcion, b.cuenta_energia, d.local_adicional, d.cantidad, c.importe, d.cve_consumo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_rpt_emision_energia_pdf
-- Tipo: Report
-- Descripción: Genera el PDF del reporte de emisión de energía eléctrica y devuelve la URL del archivo generado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rpt_emision_energia_pdf(
    p_oficina INTEGER,
    p_mercado INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER
) RETURNS TABLE(pdf_url TEXT) AS $$
DECLARE
    v_pdf_url TEXT;
BEGIN
    -- Aquí se debe implementar la lógica para generar el PDF (usando alguna librería o integración)
    -- Por ejemplo, llamar un procedimiento que genere el PDF y devuelva la URL
    v_pdf_url := '/storage/reports/emision_energia_' || p_oficina || '_' || p_mercado || '_' || p_axo || '_' || p_periodo || '.pdf';
    RETURN QUERY SELECT v_pdf_url;
END;
$$ LANGUAGE plpgsql;

-- ============================================

