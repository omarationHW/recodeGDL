-- Stored Procedure: sp_consultareg_mercados
-- Tipo: Catalog
-- Descripción: Busca un registro de mercado por oficina, mercado, sección, local, letra y bloque.
-- Generado para formulario: ConsultaReg
-- Fecha: 2025-08-27 13:40:42

CREATE OR REPLACE FUNCTION sp_consultareg_mercados(
    p_oficina integer,
    p_num_mercado integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
) RETURNS TABLE (
    id_local integer,
    oficina integer,
    num_mercado integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    descripcion_local varchar,
    superficie float,
    giro integer,
    fecha_alta date,
    fecha_baja date,
    fecha_modificacion timestamp,
    vigencia varchar,
    id_usuario integer,
    clave_cuota integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND seccion = p_seccion
      AND local = p_local
      AND (CASE WHEN p_letra_local IS NULL OR p_letra_local = '' THEN letra_local IS NULL ELSE letra_local = p_letra_local END)
      AND (CASE WHEN p_bloque IS NULL OR p_bloque = '' THEN bloque IS NULL ELSE bloque = p_bloque END)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;