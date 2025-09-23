-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DatosMovimientos
-- Generado: 2025-08-26 23:46:08
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_movimientos_by_local
-- Tipo: Report
-- Descripción: Obtiene todos los movimientos de un local específico, incluyendo datos de usuario y local.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_movimientos_by_local(p_id_local INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    axo_memo SMALLINT,
    numero_memo INTEGER,
    nombre VARCHAR,
    sector VARCHAR,
    zona SMALLINT,
    drescripcion_local VARCHAR,
    superficie FLOAT,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    tipo_movimiento SMALLINT,
    fecha TIMESTAMP,
    usuario VARCHAR,
    vigencia VARCHAR,
    clave_cuota SMALLINT,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.axo_memo, a.numero_memo, a.nombre, a.sector, a.zona, a.drescripcion_local, a.superficie, a.giro, a.fecha_alta, a.fecha_baja, a.tipo_movimiento, a.fecha, b.usuario, a.vigencia, a.clave_cuota, c.oficina, c.num_mercado, c.categoria, c.seccion
    FROM ta_11_movimientos a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN ta_11_locales c ON c.id_local = a.id_local
    WHERE a.id_local = p_id_local
    ORDER BY a.fecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_clave_movimientos
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de claves de movimiento.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_clave_movimientos()
RETURNS TABLE (
    clave_movimiento SMALLINT,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT clave_movimiento, descripcion
    FROM ta_11_clave_mov
    ORDER BY clave_movimiento;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_cve_cuotas
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de claves de cuota.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cve_cuotas()
RETURNS TABLE (
    clave_cuota SMALLINT,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT clave_cuota, descripcion
    FROM ta_11_cve_cuota
    ORDER BY clave_cuota;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_get_cuota_by_params
-- Tipo: Catalog
-- Descripción: Obtiene la cuota de un local según parámetros de año, categoría, sección y clave de cuota.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cuota_by_params(
    p_vaxo SMALLINT,
    p_vcat SMALLINT,
    p_vsec VARCHAR,
    p_vcuo SMALLINT
)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    clave_cuota SMALLINT,
    importe_cuota NUMERIC,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_cuotas, axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario
    FROM ta_11_cuo_locales
    WHERE axo = p_vaxo AND categoria = p_vcat AND seccion = p_vsec AND clave_cuota = p_vcuo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

