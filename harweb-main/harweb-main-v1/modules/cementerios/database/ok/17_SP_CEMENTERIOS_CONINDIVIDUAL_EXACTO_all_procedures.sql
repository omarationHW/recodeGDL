-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: CONINDIVIDUAL (EXACTO del archivo original)
-- Archivo: 17_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 11 (EXACTO)
-- ============================================

-- SP 1/11: sp_get_datosrcm
-- Tipo: Catalog
-- Descripción: Obtiene los datos principales de un registro RCM por folio
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_datosrcm(IN fol integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT * FROM public.ta_13_datosrcm WHERE control_rcm = fol;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: CONINDIVIDUAL (EXACTO del archivo original)
-- Archivo: 17_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 11 (EXACTO)
-- ============================================

-- SP 3/11: sp_get_descpens
-- Tipo: Catalog
-- Descripción: Obtiene descuentos pensionados y nombre de usuario
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_descpens(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT a.*, b.nombre FROM public.ta_13_descpens a
  JOIN public.ta_12_passwords b ON a.usuario = b.id_usuario
  WHERE a.control_rcm = control_rcm;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: CONINDIVIDUAL (EXACTO del archivo original)
-- Archivo: 17_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 11 (EXACTO)
-- ============================================

-- SP 5/11: sp_get_bonifrcm
-- Tipo: Catalog
-- Descripción: Obtiene suma de bonificaciones para un control_rcm
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_bonifrcm(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT COALESCE(SUM(importe_resto),0) AS bonifica FROM public.ta_13_bonifrcm WHERE control_rcm = control_rcm AND importe_resto > 0;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: CONINDIVIDUAL (EXACTO del archivo original)
-- Archivo: 17_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 11 (EXACTO)
-- ============================================

-- SP 7/11: sp_get_datosrcmhis
-- Tipo: Catalog
-- Descripción: Obtiene histórico de datos RCM y nombre de usuario
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_datosrcmhis(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT d.*, p.nombre AS usuari FROM public.ta_13_datosrcmhis d
  LEFT JOIN public.ta_12_passwords p ON d.usuario = p.id_usuario
  WHERE d.control_rcm = control_rcm;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: CONINDIVIDUAL (EXACTO del archivo original)
-- Archivo: 17_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 11 (EXACTO)
-- ============================================

-- SP 9/11: sp_get_datosrcmextra
-- Tipo: Catalog
-- Descripción: Obtiene personas que pagan por el RCM
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_datosrcmextra(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT * FROM public.ta_13_datosrcmextra WHERE control_rcm = control_rcm;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: CONINDIVIDUAL (EXACTO del archivo original)
-- Archivo: 17_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 11 (EXACTO)
-- ============================================

-- SP 11/11: sp_get_constot
-- Tipo: Report
-- Descripción: Obtiene totales de cajero por control y año
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_constot(IN par_control integer, IN par_axo integer)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Aquí debe ir la lógica de totales de cajero, ejemplo:
  SELECT slinea, sclave, stotal, sctaapli, sobserv
  FROM spd_13_constot(par_control, par_axo);
END;
$$;

-- ============================================

