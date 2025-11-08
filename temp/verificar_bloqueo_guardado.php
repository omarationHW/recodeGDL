<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "Verificando bloqueos guardados:\n\n";

// 1. Ver todos los bloqueos en la tabla
echo "1. Contenido de la tabla bloqueo_rfc_lic:\n\n";
$stmt = $pdo->query("
    SELECT *
    FROM comun.bloqueo_rfc_lic
    ORDER BY hora DESC
    LIMIT 10
");

$bloqueos = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (count($bloqueos) > 0) {
    foreach ($bloqueos as $bloqueo) {
        echo "   RFC: {$bloqueo['rfc']}\n";
        echo "   ID Trámite: {$bloqueo['id_tramite']}\n";
        echo "   Licencia: {$bloqueo['licencia']}\n";
        echo "   Vigencia: {$bloqueo['vig']}\n";
        echo "   Fecha: {$bloqueo['hora']}\n";
        echo "   Observación: {$bloqueo['observacion']}\n";
        echo "   ---\n";
    }
} else {
    echo "   ⚠ No hay bloqueos registrados\n";
}

// 2. Probar el SP de listado
echo "\n2. Probando sp_bloqueorfc_list (sin filtros):\n\n";
$stmt = $pdo->query("SELECT * FROM public.sp_bloqueorfc_list(1, 10, NULL, NULL)");
$resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (count($resultados) > 0) {
    foreach ($resultados as $resultado) {
        echo "   RFC: {$resultado['rfc']}\n";
        echo "   ID Trámite: {$resultado['id_tramite']}\n";
        echo "   Propietario: {$resultado['propietario_completo']}\n";
        echo "   Actividad: {$resultado['actividad']}\n";
        echo "   Total count: {$resultado['total_count']}\n";
        echo "   ---\n";
    }
} else {
    echo "   ⚠ El SP no devuelve resultados\n";
}

// 3. Probar búsqueda por RFC específico
echo "\n3. Probando búsqueda por RFC 'GUOC961126LL9':\n\n";
$stmt = $pdo->query("SELECT * FROM public.sp_bloqueorfc_list(1, 10, 'GUOC961126LL9', NULL)");
$resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (count($resultados) > 0) {
    echo "   ✓ Encontrado:\n";
    foreach ($resultados as $resultado) {
        echo "   RFC: {$resultado['rfc']}\n";
        echo "   Propietario: {$resultado['propietario_completo']}\n";
    }
} else {
    echo "   ⚠ No se encontró el RFC\n";
}
