<?php
$host = '192.168.20.31';
$port = '5432';
$dbname = 'ingresos';
$user = 'postgres';
$password = 'F3rnand0';

echo "========================================\n";
echo "DESPLIEGUE: DatosRequerimientos - 4 SPs\n";
echo "========================================\n\n";

try {
    echo "Conectando a PostgreSQL...\n";
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname;connect_timeout=5", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ Conexión exitosa\n\n";

    // Leer archivo SQL consolidado
    $sql_file = 'RefactorX/Base/mercados/database/ok/45_SP_MERCADOS_DATOSREQUERIMIENTOS_EXACTO_all_procedures.sql';

    if (!file_exists($sql_file)) {
        throw new Exception("Archivo no encontrado: $sql_file");
    }

    $sql = file_get_contents($sql_file);

    // Remover comandos de conexión y path
    $sql = preg_replace('/\\\\c\s+\w+;/', '', $sql);
    $sql = preg_replace('/SET search_path TO \w+;/', '', $sql);

    // Separar por SPs
    $sps = preg_split('/-- SP \d+\/\d+:/', $sql);

    $sp_names = [
        'sp_get_locales',
        'sp_get_mercado',
        'sp_get_requerimientos',
        'sp_get_periodos'
    ];

    $count = 0;
    foreach ($sps as $index => $sp_sql) {
        if (empty(trim($sp_sql)) || $index == 0) continue;

        $sp_name = $sp_names[$count] ?? "sp_$count";

        echo "Desplegando $sp_name...\n";

        try {
            // Extraer el CREATE FUNCTION
            if (preg_match('/CREATE OR REPLACE FUNCTION.*?;\s*\$\$ LANGUAGE plpgsql;/s', $sp_sql, $matches)) {
                $pdo->exec($matches[0]);
                echo "  ✓ $sp_name desplegado correctamente\n";
                $count++;
            }
        } catch (PDOException $e) {
            echo "  ✗ ERROR: " . $e->getMessage() . "\n";
        }
    }

    echo "\n========================================\n";
    echo "Verificando SPs desplegados...\n";
    echo "========================================\n\n";

    foreach ($sp_names as $sp_name) {
        $stmt = $pdo->prepare("
            SELECT proname, pronargs
            FROM pg_proc
            WHERE proname = :sp_name
        ");
        $stmt->execute(['sp_name' => $sp_name]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "✓ $sp_name ({$result['pronargs']} parámetros)\n";
        } else {
            echo "✗ $sp_name NO ENCONTRADO\n";
        }
    }

    echo "\n========================================\n";
    echo "DESPLIEGUE COMPLETADO\n";
    echo "========================================\n";
    echo "Total SPs desplegados: $count/4\n\n";

    echo "Puedes probar con:\n";
    echo "SELECT * FROM sp_get_locales(1);\n";
    echo "SELECT * FROM sp_get_mercado(5, 1);\n";

} catch (PDOException $e) {
    echo "\n========================================\n";
    echo "ERROR DE CONEXIÓN\n";
    echo "========================================\n";
    echo $e->getMessage() . "\n\n";
    exit(1);
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
