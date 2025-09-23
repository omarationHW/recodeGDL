-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RActualiza
-- Generado: 2025-08-28 13:26:50
-- Total SPs: 3
-- ============================================

-- SP 1/3: buscar_concesion
-- Tipo: Catalog
-- Descripción: Busca un local/concesión por su control (número-letra)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_concesion(control TEXT)
RETURNS TABLE (
    id_34_datos INTEGER,
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie NUMERIC,
    fecha_inicio DATE,
    fecha_fin DATE,
    id_recaudadora INTEGER,
    sector TEXT,
    id_zona INTEGER,
    licencia INTEGER,
    status TEXT,
    unidades TEXT,
    categoria TEXT,
    seccion TEXT,
    bloque TEXT,
    nom_comercial TEXT,
    lugar TEXT,
    obs TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT A.id_34_datos, A.control, A.concesionario, A.ubicacion, A.superficie, A.fecha_inicio, A.fecha_fin, A.id_recaudadora,
           A.sector, A.id_zona, A.licencia, Z.descripcion AS status, F.descripcion AS unidades,
           B.categoria, B.seccion, B.bloque, C.concepto AS nom_comercial, D.concepto AS lugar, E.concepto AS obs
    FROM t34_datos A
    LEFT JOIN t34_adicionales B ON B.id_datos = A.id_34_datos
    LEFT JOIN t34_conceptos C ON C.id_datos = A.id_34_datos AND C.tipo = 'N'
    LEFT JOIN t34_conceptos D ON D.id_datos = A.id_34_datos AND D.tipo = 'L'
    LEFT JOIN t34_conceptos E ON E.id_datos = A.id_34_datos AND E.tipo = 'O'
    JOIN t34_status Z ON Z.id_34_stat = A.id_stat
    JOIN t34_unidades F ON F.id_34_unidad = A.id_unidad
    WHERE A.control = control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: actualizar_concesion
-- Tipo: CRUD
-- Descripción: Actualiza los datos de una concesión/local según la opción seleccionada
-- --------------------------------------------

CREATE OR REPLACE FUNCTION actualizar_concesion(
    opc INTEGER,
    id_34_datos INTEGER,
    concesionario TEXT,
    ubicacion TEXT,
    licencia INTEGER,
    superficie NUMERIC,
    descrip TEXT,
    aso_ini INTEGER,
    mes_ini INTEGER
) RETURNS TABLE (resultado INTEGER, mensaje TEXT) AS $$
DECLARE
    v_old_concesionario TEXT;
    v_old_ubicacion TEXT;
    v_old_licencia INTEGER;
    v_old_superficie NUMERIC;
    v_old_descrip TEXT;
BEGIN
    SELECT concesionario, ubicacion, licencia, superficie, (SELECT descripcion FROM t34_unidades WHERE id_34_unidad = t34_datos.id_unidad)
    INTO v_old_concesionario, v_old_ubicacion, v_old_licencia, v_old_superficie, v_old_descrip
    FROM t34_datos WHERE id_34_datos = id_34_datos;

    IF opc = 0 THEN
        IF v_old_concesionario = concesionario THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET concesionario = concesionario WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Concesionario actualizado correctamente';
    ELSIF opc = 1 THEN
        IF v_old_ubicacion = ubicacion THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET ubicacion = ubicacion WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Ubicación actualizada correctamente';
    ELSIF opc = 2 THEN
        IF v_old_licencia = licencia THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET licencia = licencia WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Licencia actualizada correctamente';
    ELSIF opc = 3 THEN
        IF v_old_superficie = superficie THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET superficie = superficie WHERE id_34_datos = id_34_datos;
        -- Aquí se puede registrar el cambio de periodo si aplica
        RETURN QUERY SELECT 0, 'Superficie actualizada correctamente';
    ELSIF opc = 4 THEN
        IF v_old_descrip = descrip THEN
            RETURN QUERY SELECT 1, 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro';
            RETURN;
        END IF;
        UPDATE t34_datos SET id_unidad = (SELECT id_34_unidad FROM t34_unidades WHERE descripcion = descrip LIMIT 1) WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Tipo de local actualizado correctamente';
    ELSIF opc = 5 THEN
        -- Inicio de obligación (actualizar fecha_inicio)
        UPDATE t34_datos SET fecha_inicio = make_date(aso_ini, mes_ini, 1) WHERE id_34_datos = id_34_datos;
        RETURN QUERY SELECT 0, 'Inicio de obligación actualizado correctamente';
    ELSE
        RETURN QUERY SELECT 1, 'Opción no válida';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: verificar_pagos
-- Tipo: CRUD
-- Descripción: Verifica si existen pagos realizados a partir de un periodo para un local/concesión
-- --------------------------------------------

CREATE OR REPLACE FUNCTION verificar_pagos(id_datos INTEGER, periodo TEXT)
RETURNS TABLE (id_34_pagos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = id_datos
      AND to_char(a.periodo, 'YYYY-MM') >= periodo
      AND b.cve_stat = 'P';
END;
$$ LANGUAGE plpgsql;

-- ============================================

