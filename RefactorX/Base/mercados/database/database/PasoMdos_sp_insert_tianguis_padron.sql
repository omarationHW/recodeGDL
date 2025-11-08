-- Stored Procedure: sp_insert_tianguis_padron
-- Tipo: CRUD
-- Descripción: Inserta un registro de Tianguis en el padrón de locales si no existe
-- Generado para formulario: PasoMdos
-- Fecha: 2025-08-27 00:29:53

CREATE OR REPLACE PROCEDURE sp_insert_tianguis_padron(
    p_folio INTEGER,
    p_nombre VARCHAR,
    p_domicilio VARCHAR,
    p_superficie NUMERIC,
    p_giro VARCHAR,
    p_descuento NUMERIC,
    p_motivo_descuento VARCHAR,
    p_id_usuario INTEGER,
    p_fecha_modificacion TIMESTAMP,
    p_vigencia VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_11_locales (
        id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque,
        id_contribuy_prop, id_contribuy_renta, nombre, arrendatario, domicilio, sector, zona,
        descripcion_local, superficie, giro, fecha_alta, fecha_baja, fecha_modificacion, vigencia,
        id_usuario, clave_cuota, bloqueo
    ) VALUES (
        DEFAULT, 1, 214, 1, 'SS', p_folio, NULL, NULL,
        1, NULL, p_nombre, NULL, p_domicilio, 'J', 5,
        NULL, p_superficie, p_giro, '2009-01-01', NULL, p_fecha_modificacion, p_vigencia,
        p_id_usuario, 15, 0
    );
END;
$$;