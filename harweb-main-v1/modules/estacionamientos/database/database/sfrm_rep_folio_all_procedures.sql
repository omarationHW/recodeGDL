-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_rep_folio
-- Generado: 2025-08-27 14:30:56
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_inspectors
-- Tipo: Catalog
-- Descripción: Obtiene la lista de inspectores/vigilantes disponibles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_inspectors()
RETURNS TABLE(id_esta_persona INTEGER, inspector TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT b.id_esta_persona,
           TRIM(b.ap_pater) || ' ' || TRIM(b.ap_mater) || ' ' || TRIM(b.nombre) AS inspector
      FROM ta14_agentes a
      JOIN ta14_personas b ON a.id_esta_persona = b.id_esta_persona;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_folios_report
-- Tipo: Report
-- Descripción: Obtiene el reporte de folios elaborados o capturados, filtrando por fecha y vigilante si aplica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_folios_report(
  p_fecha DATE,
  p_vigila INTEGER DEFAULT NULL,
  p_mode TEXT DEFAULT 'elaborados' -- 'elaborados', 'capturados'
)
RETURNS TABLE(
  vigilante INTEGER,
  inspector TEXT,
  axo SMALLINT,
  folio INTEGER,
  placa TEXT,
  fecha_folio DATE,
  estado SMALLINT,
  infraccion SMALLINT,
  tarifa NUMERIC,
  descripcion TEXT,
  usu_inicial INTEGER,
  usuario TEXT
) AS $$
BEGIN
  IF p_mode = 'elaborados' THEN
    RETURN QUERY
      SELECT a.vigilante,
             TRIM(c.ap_pater) || ' ' || TRIM(c.ap_mater) || ' ' || TRIM(c.nombre) AS inspector,
             a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa,
             'Vigente' AS descripcion, a.usu_inicial,
             u.usuario
        FROM ta14_folios_adeudo a
        JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
        JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
        LEFT JOIN ta_12_passwords u ON a.usu_inicial = u.id_usuario
        WHERE a.fecha_folio = p_fecha
        AND (p_vigila IS NULL OR a.vigilante = p_vigila)
      UNION ALL
      SELECT a.vigilante,
             TRIM(c.ap_pater) || ' ' || TRIM(c.ap_mater) || ' ' || TRIM(c.nombre) AS inspector,
             a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa,
             d.descripcion, a.usu_inicial,
             u.usuario
        FROM ta14_folios_histo a
        JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
        JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
        JOIN ta14_codigomovtos d ON a.codigo_movto = d.codigo_movto
        LEFT JOIN ta_12_passwords u ON a.usu_inicial = u.id_usuario
        WHERE a.fecha_folio = p_fecha
        AND (p_vigila IS NULL OR a.vigilante = p_vigila)
      ORDER BY 1,3,4;
  ELSIF p_mode = 'capturados' THEN
    RETURN QUERY
      SELECT a.vigilante,
             TRIM(c.ap_pater) || ' ' || TRIM(c.ap_mater) || ' ' || TRIM(c.nombre) AS inspector,
             a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa,
             'Vigente' AS descripcion, a.usu_inicial,
             u.usuario
        FROM ta14_folios_adeudo a
        JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
        JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
        LEFT JOIN ta_12_passwords u ON a.usu_inicial = u.id_usuario
        WHERE a.fec_cap = p_fecha
        AND (p_vigila IS NULL OR a.vigilante = p_vigila)
      UNION ALL
      SELECT a.vigilante,
             TRIM(c.ap_pater) || ' ' || TRIM(c.ap_mater) || ' ' || TRIM(c.nombre) AS inspector,
             a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa,
             d.descripcion, a.usu_inicial,
             u.usuario
        FROM ta14_folios_histo a
        JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
        JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
        JOIN ta14_codigomovtos d ON a.codigo_movto = d.codigo_movto
        LEFT JOIN ta_12_passwords u ON a.usu_inicial = u.id_usuario
        WHERE a.fec_cap = p_fecha
        AND (p_vigila IS NULL OR a.vigilante = p_vigila)
      ORDER BY 1,3,4;
  ELSE
    RETURN QUERY SELECT NULL::INTEGER, NULL::TEXT, NULL::SMALLINT, NULL::INTEGER, NULL::TEXT, NULL::DATE, NULL::SMALLINT, NULL::SMALLINT, NULL::NUMERIC, NULL::TEXT, NULL::INTEGER, NULL::TEXT WHERE FALSE;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_folios_by_inspector
-- Tipo: Report
-- Descripción: Obtiene el conteo de folios hechos por cada inspector en una fecha dada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_folios_by_inspector(p_fecha DATE)
RETURNS TABLE(
  vigilante INTEGER,
  inspector TEXT,
  folios INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.vigilante,
           TRIM(COALESCE(c.ap_pater, '.')) || ' ' || TRIM(COALESCE(c.ap_mater, '.')) || ' ' || TRIM(COALESCE(c.nombre, '.')) AS inspector,
           COUNT(a.folio) AS folios
      FROM ta14_folios_adeudo a
      JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
      WHERE a.fecha_folio = p_fecha
      GROUP BY a.vigilante, inspector
      ORDER BY inspector;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_get_usuarios
-- Tipo: Catalog
-- Descripción: Obtiene la lista de usuarios del sistema.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_usuarios()
RETURNS TABLE(
  id_usuario INTEGER,
  usuario TEXT,
  nombre TEXT,
  estado TEXT,
  id_rec SMALLINT,
  nivel SMALLINT
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec, nivel
      FROM ta_12_passwords;
END;
$$ LANGUAGE plpgsql;

-- ============================================

