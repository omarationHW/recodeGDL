-- Stored Procedure: sp_gen_individual_execute
-- Tipo: CRUD
-- Descripción: Registra la remesa en ta14_bitacora y retorna el conteo de pagos normales y cancelaciones.
-- Generado para formulario: Gen_Individual
-- Fecha: 2025-08-27 13:46:40

CREATE OR REPLACE FUNCTION sp_gen_individual_execute(
    p_remesa varchar
) RETURNS TABLE(
    pagos_normales integer,
    cancelaciones integer,
    total integer
) AS $$
DECLARE
    pn integer;
    can integer;
    num_remesa integer;
    fecha_fin date;
    fecha_inicio date;
BEGIN
    SELECT COUNT(*) INTO pn FROM ta14_datos_mpio WHERE remesa = p_remesa AND tipoact = 'PN';
    SELECT COUNT(*) INTO can FROM ta14_datos_mpio WHERE remesa = p_remesa AND tipoact = 'C';
    SELECT COALESCE(MAX(num_remesa),0)+1 INTO num_remesa FROM ta14_bitacora WHERE tipo IN ('C','B','D');
    SELECT fecha_inicio, fecha_fin INTO fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'C' ORDER BY fecha_fin DESC LIMIT 1;
    -- Insertar en bitacora
    INSERT INTO ta14_bitacora (control, tipo, fecha_inicio, fecha_fin, fecha_hoy, num_remesa, cant_reg)
    VALUES (0, 'C', fecha_inicio, fecha_fin, CURRENT_DATE, num_remesa, pn+can);
    RETURN QUERY SELECT pn, can, pn+can;
END;
$$ LANGUAGE plpgsql;