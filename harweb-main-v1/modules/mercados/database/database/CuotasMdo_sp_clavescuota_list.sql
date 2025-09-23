-- Stored Procedure: sp_clavescuota_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de cuota
-- Generado para formulario: CuotasMdo
-- Fecha: 2025-08-26 23:34:39

CREATE OR REPLACE FUNCTION sp_clavescuota_list()
RETURNS TABLE (clave_cuota INTEGER, descripcion VARCHAR(100)) AS $$
BEGIN
    RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota ORDER BY clave_cuota;
END;
$$ LANGUAGE plpgsql;