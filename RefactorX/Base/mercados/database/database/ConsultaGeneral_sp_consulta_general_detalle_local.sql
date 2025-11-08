-- Stored Procedure: sp_consulta_general_detalle_local
-- Tipo: CRUD
-- Descripción: Obtiene detalle completo de un local
-- Generado para formulario: ConsultaGeneral
-- Fecha: 2025-08-27 20:45:14

CREATE OR REPLACE FUNCTION sp_consulta_general_detalle_local(
    p_id_local integer
) RETURNS TABLE(
    id_local integer,
    mercado varchar,
    nombre varchar,
    arrendatario varchar,
    domicilio varchar,
    sector varchar,
    zona integer,
    descripcion_local varchar,
    superficie numeric,
    giro integer,
    fecha_alta date,
    fecha_baja date,
    vigencia varchar,
    usuario varchar,
    renta numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_local, m.descripcion as mercado, l.nombre, l.arrendatario, l.domicilio, l.sector, l.zona, l.descripcion_local, l.superficie, l.giro, l.fecha_alta, l.fecha_baja, l.vigencia, u.usuario, c.importe_cuota * l.superficie as renta
    FROM ta_11_locales l
    LEFT JOIN ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN ta_12_passwords u ON l.id_usuario = u.id_usuario
    LEFT JOIN ta_11_cuo_locales c ON c.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND c.categoria = l.categoria AND c.seccion = l.seccion AND c.clave_cuota = l.clave_cuota
    WHERE l.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;