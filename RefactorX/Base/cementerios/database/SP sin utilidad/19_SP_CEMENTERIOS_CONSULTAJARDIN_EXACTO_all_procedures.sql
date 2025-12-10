-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: CONSULTAJARDIN (EXACTO del archivo original)
-- Archivo: 19_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: consulta_jardin_by_rcm
-- Tipo: Catalog
-- Descripción: Consulta registros de regprop por clase, sección y línea (RCM)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION consulta_jardin_by_rcm(vclase integer, vsec integer, vlinea integer)
RETURNS TABLE(
  clase varchar,
  seccion varchar,
  linea varchar,
  fosa varchar,
  ppago varchar,
  nombre varchar,
  fcompra timestamp,
  otros text,
  clave smallint,
  medida float,
  calle varchar,
  colonia varchar
) AS $$
BEGIN
  RETURN QUERY
    SELECT clase, seccion, linea, fosa, ppago, nombre, fcompra, otros, clave, medida, calle, colonia
    FROM regprop
    WHERE clase = vclase::text AND seccion = vsec::text AND linea >= vlinea::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: CONSULTAJARDIN (EXACTO del archivo original)
-- Archivo: 19_SP_CEMENTERIOS_CONSULTAJARDIN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: consulta_jardin_by_partida
-- Tipo: Catalog
-- Descripción: Consulta registros de regprop por partida de pago (ppago LIKE)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION consulta_jardin_by_partida(ppago varchar)
RETURNS TABLE(
  clase varchar,
  seccion varchar,
  linea varchar,
  fosa varchar,
  ppago varchar,
  nombre varchar,
  fcompra timestamp,
  otros text,
  clave smallint,
  medida float,
  calle varchar,
  colonia varchar
) AS $$
BEGIN
  RETURN QUERY
    SELECT clase, seccion, linea, fosa, ppago, nombre, fcompra, otros, clave, medida, calle, colonia
    FROM regprop
    WHERE ppago ILIKE '%' || ppago || '%';
END;
$$ LANGUAGE plpgsql;

-- ============================================

