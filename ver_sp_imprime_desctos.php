<?php
// Ver el stored procedure actual de imprime_desctos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CONTENIDO DEL STORED PROCEDURE recaudadora_imprime_desctos ===\n\n";

    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'publico'
        AND p.proname = 'recaudadora_imprime_desctos'
        AND pg_get_function_arguments(p.oid) = 'p_clave_cuenta character varying, p_ejercicio integer'
    ");

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo $result['definition'];
    } else {
        echo "No se encontró el stored procedure.\n";
    }

    // Ver ejemplos de datos en aut_desctosotorgados
    echo "\n\n=== EJEMPLOS DE DATOS EN aut_desctosotorgados ===\n\n";

    $stmt2 = $pdo->query("
        SELECT
            folio_descto,
            tipo,
            id_multa,
            axo,
            por_aut,
            monto_aut,
            fecha_inicio,
            fecha_fin,
            vigencia,
            tipo_descto,
            adeudo
        FROM publico.aut_desctosotorgados
        LIMIT 5
    ");

    $ejemplos = $stmt2->fetchAll(PDO::FETCH_ASSOC);
    foreach ($ejemplos as $ej) {
        echo "Folio: {$ej['folio_descto']}, ID Multa: {$ej['id_multa']}, Año: {$ej['axo']}, ";
        echo "% Autorizado: {$ej['por_aut']}, Monto: {$ej['monto_aut']}, ";
        echo "Vigencia: {$ej['vigencia']}\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
