-- Stored Procedure: sp_update_fecha_practica
-- Tipo: CRUD
-- Descripción: Actualiza la fecha de práctica (fecent) de un requerimiento.
-- Generado para formulario: ActualizaFechaEmpresas
-- Fecha: 2025-08-26 20:24:51

CREATE OR REPLACE PROCEDURE sp_update_fecha_practica(p_cvereq INTEGER, p_fecha_practica DATE)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE reqpredial SET fecent = p_fecha_practica WHERE cvereq = p_cvereq;
END;
$$;