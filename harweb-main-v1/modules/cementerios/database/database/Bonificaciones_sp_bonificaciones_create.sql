-- Stored Procedure: sp_bonificaciones_create
-- Tipo: CRUD
-- Descripción: Crea una nueva bonificación en ta_13_bonifrcm
-- Generado para formulario: Bonificaciones
-- Fecha: 2025-08-28 17:48:25

CREATE OR REPLACE FUNCTION sp_bonificaciones_create(
    p_oficio integer,
    p_axo integer,
    p_doble varchar,
    p_control_rcm integer,
    p_cementerio varchar,
    p_clase integer,
    p_clase_alfa varchar,
    p_seccion integer,
    p_seccion_alfa varchar,
    p_linea integer,
    p_linea_alfa varchar,
    p_fosa integer,
    p_fosa_alfa varchar,
    p_fecha_ofic date,
    p_importe_bonificar numeric,
    p_importe_bonificado numeric,
    p_importe_resto numeric,
    p_usuario integer,
    p_fecha_mov timestamp,
    OUT p_error text
) RETURNS void AS $$
BEGIN
    INSERT INTO ta_13_bonifrcm (
        control_bon, oficio, axo, doble, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, fecha_ofic, importe_bonificar, importe_bonificado, importe_resto, usuario, fecha_mov
    ) VALUES (
        DEFAULT, p_oficio, p_axo, p_doble, p_control_rcm, p_cementerio, p_clase, p_clase_alfa, p_seccion, p_seccion_alfa, p_linea, p_linea_alfa, p_fosa, p_fosa_alfa, p_fecha_ofic, p_importe_bonificar, p_importe_bonificado, p_importe_resto, p_usuario, p_fecha_mov
    );
    p_error := NULL;
EXCEPTION WHEN OTHERS THEN
    p_error := SQLERRM;
END;
$$ LANGUAGE plpgsql;