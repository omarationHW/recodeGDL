<?php
$host = '192.168.20.31';
$port = '5432';
$dbname = 'padron_licencias';  // CORREGIDO: Base de datos correcta
$user = 'postgres';
$password = 'F3rnand0';

echo "========================================\n";
echo "DESPLIEGUE CORREGIDO: DatosRequerimientos\n";
echo "Base de datos: padron_licencias\n";
echo "========================================\n\n";

try {
    echo "Conectando a PostgreSQL...\n";
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname;connect_timeout=10", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ Conexión exitosa a $dbname\n\n";

    $sps = [
        'sp_get_locales' => "
            CREATE OR REPLACE FUNCTION sp_get_locales(p_id_local integer)
            RETURNS TABLE (
                id_local integer,
                oficina smallint,
                num_mercado smallint,
                categoria smallint,
                seccion char(2),
                letra_local char(1),
                bloque char(1),
                nombre varchar(30),
                descripcion_local varchar
            ) AS \$\$
            BEGIN
                RETURN QUERY
                SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion,
                       a.letra_local, a.bloque, a.nombre, a.descripcion_local
                FROM comun.ta_11_locales a
                WHERE a.id_local = p_id_local;
            END;
            \$\$ LANGUAGE plpgsql;
        ",

        'sp_get_mercado' => "
            CREATE OR REPLACE FUNCTION sp_get_mercado(p_oficina smallint, p_num_mercado smallint)
            RETURNS TABLE (
                oficina smallint,
                num_mercado_nvo smallint,
                categoria smallint,
                descripcion varchar,
                cuenta_ingreso integer,
                cuenta_energia integer
            ) AS \$\$
            BEGIN
                RETURN QUERY
                SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia
                FROM comun.ta_11_mercados
                WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado;
            END;
            \$\$ LANGUAGE plpgsql;
        ",

        'sp_get_requerimientos' => "
            CREATE OR REPLACE FUNCTION sp_get_requerimientos(p_modulo smallint, p_folio integer, p_control_otr integer)
            RETURNS TABLE (
                id_control integer, modulo smallint, control_otr integer, folio integer,
                diligencia varchar, importe_global numeric, importe_multa numeric,
                importe_recargo numeric, importe_gastos numeric, fecha_emision date,
                clave_practicado varchar, vigencia varchar, fecha_actualiz date, usuario integer,
                id_usuario integer, usuario_1 varchar, nombre varchar, estado varchar,
                id_rec smallint, nivel smallint, zona smallint, zona_apremio smallint,
                fecha_practicado date, fecha_entrega1 date, fecha_entrega2 date,
                fecha_citatorio date, hora timestamp, ejecutor smallint,
                clave_secuestro smallint, clave_remate varchar, fecha_remate date,
                porcentaje_multa smallint, observaciones varchar, fecha_pago date,
                recaudadora smallint, caja varchar, operacion integer,
                importe_pago numeric, clave_mov varchar, hora_practicado timestamp
            ) AS \$\$
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
            \$\$ LANGUAGE plpgsql;
        ",

        'sp_get_periodos' => "
            CREATE OR REPLACE FUNCTION sp_get_periodos(p_control_otr integer)
            RETURNS TABLE (
                id_control integer,
                control_otr integer,
                ayo smallint,
                periodo smallint,
                importe numeric,
                recargos numeric
            ) AS \$\$
            BEGIN
                RETURN QUERY
                SELECT id_control, control_otr, ayo, periodo, importe, recargos
                FROM comun.ta_15_periodos
                WHERE control_otr = p_control_otr;
            END;
            \$\$ LANGUAGE plpgsql;
        "
    ];

    $count = 0;
    foreach ($sps as $name => $sql) {
        echo "Desplegando $name...\n";
        try {
            $pdo->exec($sql);
            echo "  ✓ $name desplegado\n";
            $count++;
        } catch (PDOException $e) {
            echo "  ✗ ERROR: " . $e->getMessage() . "\n";
        }
    }

    echo "\n========================================\n";
    echo "Verificando SPs...\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT proname, pronargs
        FROM pg_proc
        WHERE proname IN ('sp_get_locales', 'sp_get_mercado', 'sp_get_requerimientos', 'sp_get_periodos')
        ORDER BY proname
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "✓ {$row['proname']} ({$row['pronargs']} parámetros)\n";
    }

    echo "\n========================================\n";
    echo "DESPLIEGUE COMPLETADO: $count/4 SPs\n";
    echo "========================================\n\n";

    // Probar sp_get_locales
    echo "Probando sp_get_locales(1)...\n";
    $stmt = $pdo->query("SELECT * FROM sp_get_locales(1) LIMIT 1");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "✓ sp_get_locales funciona correctamente\n";
        echo "  Datos: " . json_encode($result, JSON_PRETTY_PRINT) . "\n";
    }

} catch (PDOException $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
