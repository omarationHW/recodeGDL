-- Stored Procedure: sp_menu_get_menu
-- Tipo: Catalog
-- Descripción: Devuelve el menú de opciones disponibles para el usuario según su nivel.
-- Generado para formulario: Menu
-- Fecha: 2025-08-28 13:23:04

CREATE OR REPLACE FUNCTION sp_menu_get_menu(p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
  v_nivel SMALLINT;
  v_menu JSON;
BEGIN
  SELECT nivel INTO v_nivel FROM ta_12_passwords WHERE usuario = p_usuario;
  -- Ejemplo de menú, debe adaptarse a la lógica real de permisos
  v_menu := json_build_array(
    json_build_object('nombre', 'Controles', 'opciones', json_build_array(
      json_build_object('id', 101, 'titulo', 'Alta de Fuente de Sodas', 'enabled', v_nivel >= 1),
      json_build_object('id', 102, 'titulo', 'Alta de Juegos Mecánicos', 'enabled', v_nivel >= 1)
    )),
    json_build_object('nombre', 'Reportes', 'opciones', json_build_array(
      json_build_object('id', 301, 'titulo', 'Edo. Cuenta', 'enabled', v_nivel >= 1)
    ))
  );
  RETURN v_menu;
END;
$$ LANGUAGE plpgsql;