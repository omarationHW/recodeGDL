-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConIndividual
-- Generado: 2025-08-28 17:50:28
-- Total SPs: 11
-- ============================================

-- SP 1/11: sp_get_datosrcm
-- Tipo: Catalog
-- Descripción: Obtiene los datos principales de un registro RCM por folio
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_datosrcm(IN fol integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT * FROM ta_13_datosrcm WHERE control_rcm = fol;
END;
$$;

-- ============================================

-- SP 2/11: sp_get_passwords
-- Tipo: Catalog
-- Descripción: Obtiene datos de usuario por id_usuario
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_passwords(IN usuario integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT * FROM ta_12_passwords WHERE id_usuario = usuario;
END;
$$;

-- ============================================

-- SP 3/11: sp_get_descpens
-- Tipo: Catalog
-- Descripción: Obtiene descuentos pensionados y nombre de usuario
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_descpens(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT a.*, b.nombre FROM ta_13_descpens a
  JOIN ta_12_passwords b ON a.usuario = b.id_usuario
  WHERE a.control_rcm = control_rcm;
END;
$$;

-- ============================================

-- SP 4/11: sp_get_datosrcmadic
-- Tipo: Catalog
-- Descripción: Obtiene datos adicionales de RCM
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_datosrcmadic(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT * FROM ta_13_datosrcmadic WHERE control_rcm = control_rcm;
END;
$$;

-- ============================================

-- SP 5/11: sp_get_bonifrcm
-- Tipo: Catalog
-- Descripción: Obtiene suma de bonificaciones para un control_rcm
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_bonifrcm(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT COALESCE(SUM(importe_resto),0) AS bonifica FROM ta_13_bonifrcm WHERE control_rcm = control_rcm AND importe_resto > 0;
END;
$$;

-- ============================================

-- SP 6/11: sp_get_descrec
-- Tipo: Catalog
-- Descripción: Obtiene descuentos recurrentes y nombre de usuario
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_descrec(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT d.*, p.nombre FROM ta_13_descrec d
  JOIN ta_12_passwords p ON d.usuario_alta = p.usuario
  WHERE d.id_folio = control_rcm;
END;
$$;

-- ============================================

-- SP 7/11: sp_get_datosrcmhis
-- Tipo: Catalog
-- Descripción: Obtiene histórico de datos RCM y nombre de usuario
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_datosrcmhis(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT d.*, p.nombre AS usuari FROM ta_13_datosrcmhis d
  LEFT JOIN ta_12_passwords p ON d.usuario = p.id_usuario
  WHERE d.control_rcm = control_rcm;
END;
$$;

-- ============================================

-- SP 8/11: sp_get_cementerios
-- Tipo: Catalog
-- Descripción: Obtiene datos de cementerio por clave
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_cementerios(IN cementerio text)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT * FROM tc_13_cementerios WHERE cementerio = cementerio;
END;
$$;

-- ============================================

-- SP 9/11: sp_get_datosrcmextra
-- Tipo: Catalog
-- Descripción: Obtiene personas que pagan por el RCM
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_datosrcmextra(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT * FROM ta_13_datosrcmextra WHERE control_rcm = control_rcm;
END;
$$;

-- ============================================

-- SP 10/11: sp_get_pagosrcm
-- Tipo: Report
-- Descripción: Obtiene pagos y títulos para un control_rcm
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_get_pagosrcm(IN folp integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT 'Manten' AS tipopag, *, '' AS obser
    FROM ta_13_pagosrcm WHERE control_rcm = folp
  UNION
  SELECT 'Titulo', fecha, id_rec, caja, operacion, 0, control_rcm, '', 0, '', 0, '', 0, '', tipo, titulo, importe, 0, '', 0, CURRENT_DATE, observaciones
    FROM ta_13_titulos WHERE control_rcm = folp
  ORDER BY 2 DESC;
END;
$$;

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

