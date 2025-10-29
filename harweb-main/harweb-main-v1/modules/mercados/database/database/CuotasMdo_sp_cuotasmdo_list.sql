-- Stored Procedure: sp_cuotasmdo_list
-- Tipo: Catalog
-- Descripción: Lista todas las cuotas de mercados para un año dado
-- Generado para formulario: CuotasMdo
-- Fecha: 2025-08-26 23:34:39

CREATE OR REPLACE FUNCTION sp_cuotasmdo_list(p_axo INTEGER)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo INTEGER,
    categoria INTEGER,
    seccion VARCHAR(10),
    clave_cuota INTEGER,
    importe_cuota NUMERIC(12,2),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50),
    descripcion VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_cuotas, a.axo, a.categoria, a.seccion, a.clave_cuota, a.importe_cuota, a.fecha_alta, a.id_usuario, b.usuario, c.descripcion
    FROM ta_11_cuo_locales a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    JOIN ta_11_cve_cuota c ON a.clave_cuota = c.clave_cuota
    WHERE a.axo >= p_axo
    ORDER BY a.axo DESC, a.categoria DESC, a.seccion DESC, a.clave_cuota DESC;
END;
$$ LANGUAGE plpgsql;