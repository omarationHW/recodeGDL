<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';  // <- Base de datos correcta
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa a padron_licencias\n\n";

    $sql = "
DROP FUNCTION IF EXISTS sp_cons_condonacion_energia(integer,integer,integer,character varying,integer,character varying,character varying);

CREATE OR REPLACE FUNCTION sp_cons_condonacion_energia(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
)
RETURNS TABLE (
    id_condonacion integer,
    id_local integer,
    id_energia integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre_local varchar,
    arrendatario varchar,
    vigencia varchar,
    axo smallint,
    periodo smallint,
    fecha_condonacion timestamp,
    importe_original numeric,
    importe_condonado numeric,
    motivo varchar,
    observacion varchar,
    usuario varchar
) AS \$\$
DECLARE
    v_db_link TEXT := 'host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2';
BEGIN
    -- Nota: Esta función requiere acceso a ambas bases de datos
    -- Las condonaciones están en mercados.public
    -- Los locales están en padron_licencias.comun

    RETURN QUERY
    SELECT
        c.id_cancelacion as id_condonacion,
        l.id_local,
        c.id_energia,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre as nombre_local,
        l.arrendatario,
        l.vigencia,
        c.axo,
        c.periodo,
        c.fecha_alta as fecha_condonacion,
        ae.importe as importe_original,
        c.importe as importe_condonado,
        c.clave_canc as motivo,
        c.observacion,
        u.usuario
    FROM comun.ta_11_locales l
    INNER JOIN dblink(v_db_link, 'SELECT id_local, id_energia FROM public.ta_11_energia') AS e(id_local integer, id_energia integer) ON l.id_local = e.id_local
    INNER JOIN dblink(v_db_link, 'SELECT id_energia, importe FROM public.ta_11_adeudo_energ') AS ae(id_energia integer, importe numeric) ON e.id_energia = ae.id_energia
    INNER JOIN dblink(v_db_link, 'SELECT id_cancelacion, id_energia, axo, periodo, fecha_alta, importe, clave_canc, observacion, id_usuario FROM public.ta_11_ade_ene_canc') AS c(id_cancelacion integer, id_energia integer, axo smallint, periodo smallint, fecha_alta timestamp, importe numeric, clave_canc varchar, observacion varchar, id_usuario integer) ON ae.id_energia = c.id_energia
    LEFT JOIN dblink(v_db_link, 'SELECT id_usuario, usuario FROM public.usuarios') AS u(id_usuario integer, usuario varchar) ON c.id_usuario = u.id_usuario
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (l.letra_local = p_letra_local OR (p_letra_local IS NULL AND l.letra_local IS NULL))
      AND (l.bloque = p_bloque OR (p_bloque IS NULL AND l.bloque IS NULL))
    ORDER BY c.axo DESC, c.periodo DESC;
END;
\$\$ LANGUAGE plpgsql;
";

    echo "Creando SP con dblink...\n";
    $pdo->exec($sql);
    echo "✓ SP creado en padron_licencias\n\n";

    echo str_repeat("=", 60) . "\n";
    echo "SP DESPLEGADO EXITOSAMENTE\n";
    echo str_repeat("=", 60) . "\n";

} catch (PDOException $e) {
    if (strpos($e->getMessage(), 'dblink') !== false) {
        echo "\n✗ Error: La extensión dblink no está habilitada.\n";
        echo "Ejecuta como superusuario:\n";
        echo "CREATE EXTENSION IF NOT EXISTS dblink;\n\n";
    }
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
