-- ========================================
-- DESPLIEGUE FINAL: DatosRequerimientos
-- Base: padron_licencias
-- TODOS los errores corregidos
-- ========================================

\c padron_licencias;

-- SP 1/4: sp_get_locales
DROP FUNCTION IF EXISTS sp_get_locales(integer);

CREATE OR REPLACE FUNCTION sp_get_locales(p_id_local integer)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion char(2),
    letra_local varchar(3),
    bloque varchar(3),
    nombre varchar(30),
    descripcion_local varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion,
           a.letra_local, a.bloque, a.nombre, a.descripcion_local
    FROM comun.ta_11_locales a
    WHERE a.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;

SELECT '✓ SP 1/4: sp_get_locales' as status;

-- SP 2/4: sp_get_mercado (ALIAS AGREGADO)
DROP FUNCTION IF EXISTS sp_get_mercado(smallint, smallint);

CREATE OR REPLACE FUNCTION sp_get_mercado(p_oficina smallint, p_num_mercado smallint)
RETURNS TABLE (
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar,
    cuenta_ingreso integer,
    cuenta_energia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.oficina, m.num_mercado_nvo, m.categoria, m.descripcion,
           m.cuenta_ingreso, m.cuenta_energia
    FROM comun.ta_11_mercados m
    WHERE m.oficina = p_oficina AND m.num_mercado_nvo = p_num_mercado;
END;
$$ LANGUAGE plpgsql;

SELECT '✓ SP 2/4: sp_get_mercado' as status;

-- SP 3/4: sp_get_requerimientos
DROP FUNCTION IF EXISTS sp_get_requerimientos(smallint, integer, integer);

CREATE OR REPLACE FUNCTION sp_get_requerimientos(p_modulo smallint, p_folio integer, p_control_otr integer)
RETURNS TABLE (
    id_control integer,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    fecha_emision date,
    clave_practicado varchar,
    vigencia varchar,
    fecha_actualiz date,
    usuario integer,
    id_usuario integer,
    usuario_1 varchar,
    nombre varchar,
    estado varchar,
    id_rec smallint,
    nivel smallint,
    zona smallint,
    zona_apremio smallint,
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    clave_secuestro smallint,
    clave_remate varchar,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar,
    fecha_pago date,
    recaudadora smallint,
    caja varchar,
    operacion integer,
    importe_pago numeric,
    clave_mov varchar,
    hora_practicado timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.modulo, a.control_otr, a.folio, a.diligencia,
           a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos,
           a.fecha_emision, a.clave_practicado, a.vigencia, a.fecha_actualiz,
           a.usuario, b.id_usuario, b.usuario as usuario_1, b.nombre, b.estado,
           b.id_rec, b.nivel, a.zona, a.zona_apremio, a.fecha_practicado,
           a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora,
           a.ejecutor, a.clave_secuestro, a.clave_remate, a.fecha_remate,
           a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora,
           a.caja, a.operacion, a.importe_pago, a.clave_mov, a.hora_practicado
    FROM comun.ta_15_apremios a
    JOIN comun.ta_12_passwords b ON a.usuario = b.id_usuario
    WHERE a.modulo = p_modulo AND a.folio = p_folio AND a.control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;

SELECT '✓ SP 3/4: sp_get_requerimientos' as status;

-- SP 4/4: sp_get_periodos
DROP FUNCTION IF EXISTS sp_get_periodos(integer);

CREATE OR REPLACE FUNCTION sp_get_periodos(p_control_otr integer)
RETURNS TABLE (
    id_control integer,
    control_otr integer,
    ayo smallint,
    periodo smallint,
    importe numeric,
    recargos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id_control, p.control_otr, p.ayo, p.periodo, p.importe, p.recargos
    FROM comun.ta_15_periodos p
    WHERE p.control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;

SELECT '✓ SP 4/4: sp_get_periodos' as status;

-- ========================================
-- VERIFICACIÓN
-- ========================================

SELECT '========================================' as info;
SELECT 'SPs DESPLEGADOS' as info;
SELECT '========================================' as info;

SELECT proname as "SP", pronargs as "Params"
FROM pg_proc
WHERE proname IN ('sp_get_locales', 'sp_get_mercado', 'sp_get_requerimientos', 'sp_get_periodos')
ORDER BY proname;

-- ========================================
-- PRUEBAS
-- ========================================

SELECT '========================================' as info;
SELECT 'PRUEBA: sp_get_locales(1)' as info;
SELECT '========================================' as info;

SELECT * FROM sp_get_locales(1) LIMIT 1;

SELECT '========================================' as info;
SELECT 'COMPLETADO - Listo para usar' as info;
SELECT '========================================' as info;
