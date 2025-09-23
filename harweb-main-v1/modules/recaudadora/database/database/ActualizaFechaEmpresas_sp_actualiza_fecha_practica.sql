-- Stored Procedure: sp_actualiza_fecha_practica
-- Tipo: CRUD
-- Descripción: Actualiza la fecha de práctica (fecent) de un folio de requerimiento de empresa
-- Generado para formulario: ActualizaFechaEmpresas
-- Fecha: 2025-08-26 20:38:17

CREATE OR REPLACE PROCEDURE sp_actualiza_fecha_practica(
    IN p_cvereq INTEGER,
    IN p_fecha_practica DATE
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE reqpredial
    SET fecent = p_fecha_practica
    WHERE cvereq = p_cvereq;
END;
$$;