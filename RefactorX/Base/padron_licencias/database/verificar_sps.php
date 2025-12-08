<?php
/**
 * Script de Verificación de Stored Procedures
 * Módulo: padron_licencias
 * Fecha: 2025-11-21
 */

// Configuración de conexión (desde .env del BackEnd)
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "================================================\n";
    echo "   VERIFICACIÓN DE STORED PROCEDURES\n";
    echo "   Módulo: padron_licencias\n";
    echo "================================================\n\n";

    // 1. Verificar extensión pgcrypto
    $stmt = $pdo->query("SELECT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto') as existe");
    $pgcrypto = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "✓ Extensión pgcrypto: " . ($pgcrypto['existe'] ? '✅ INSTALADA' : '❌ FALTA') . "\n\n";

    // 2. Contar SPs por schema
    echo "--- CONTEO POR SCHEMA ---\n";
    $stmt = $pdo->query("
        SELECT n.nspname as schema, COUNT(*) as total
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname IN ('public', 'comun')
          AND p.prokind = 'f'
        GROUP BY n.nspname
        ORDER BY n.nspname
    ");
    $total_sps = 0;
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  {$row['schema']}: {$row['total']} funciones\n";
        $total_sps += $row['total'];
    }
    echo "  TOTAL: $total_sps funciones\n\n";

    // 3. Verificar componentes principales
    echo "--- VERIFICACIÓN POR COMPONENTE ---\n";

    $componentes = [
        // Batch 1-4
        ['consultausuario', 'consultausuariosfrm'],
        ['dictamen', 'dictamenfrm'],
        ['constancia', 'constanciafrm'],
        ['repestado', 'repestado'],
        ['repdoc', 'repdoc'],
        ['certificacion', 'certificacionesfrm'],
        ['privilegio', 'privilegios'],
        ['doctos', 'doctosfrm'],
        ['dependencia', 'dependenciasfrm'],
        ['ecologia', 'formatosEcologiafrm'],

        // Batch 5-8
        ['actividad', 'CatalogoActividades'],
        ['consanun400', 'consAnun400frm'],
        ['conslic400', 'consLic400frm'],
        ['estatus', 'estatusfrm'],
        ['cartonva', 'cartonva'],
        ['grupos_licencia', 'GruposLicenciasAbcfrm'],
        ['hasta', 'Hastafrm'],
        ['imp_licencia', 'ImpLicenciaReglamentadaFrm'],
        ['imp_oficio', 'ImpOficiofrm'],
        ['imp_recibo', 'ImpRecibofrm'],
        ['bloquear', 'Sistema de Bloqueos'],

        // Batch 9-12
        ['prepago', 'prepagofrm'],
        ['holograma', 'prophologramasfrm'],
        ['agenda', 'Agendavisitasfrm'],
        ['buscagiro', 'buscagirofrm'],
        ['busque', 'busque'],
        ['cargadatos', 'cargadatosfrm'],
        ['imagen', 'carga_imagen'],
        ['catastro', 'CatastroDM'],
        ['cruces', 'Cruces'],
        ['empresa', 'empresasfrm'],
        ['buscalle', 'formabuscalle'],
        ['catrequisitos', 'CatRequisitos'],
        ['firmausuario', 'firmausuario'],
        ['buscolonia', 'formabuscolonia'],
        ['grs_dlg', 'grs_dlg'],
        ['grupos_anuncio', 'GruposAnunciosAbcfrm'],

        // Batch 13-16
        ['firma', 'firma'],
        ['frmselcalle', 'frmselcalle'],
        ['liga_anuncio', 'ligaAnunciofrm'],
        ['psplash', 'psplash'],
        ['observacion', 'observacionfrm'],
        ['semaforo', 'Semaforo'],
        ['sgcv2', 'SGCv2'],
        ['tdmconection', 'TDMConection'],
        ['giros_vigentes', 'girosVigentesCteXgirofrm'],
        ['calc_sdos', 'modlicAdeudofrm'],
        ['reghfrm', 'REGHFRM'],
        ['rep_estadistico', 'REPESTADISTICOSLICFRM'],
        ['suspendida', 'REPSUSPENDIDASFRM'],
        ['chgfirma', 'SFRM_CHGFIRMA'],
        ['chgpass', 'SFRM_CHGPASS'],
        ['tipo_bloqueo', 'TIPOBLOQUEOFRM'],
        ['webbrowser', 'WEBBROWSER'],
        ['fechasegfrm', 'FECHASEGFRM'],
    ];

    $verificados = 0;
    $faltantes = [];

    foreach ($componentes as $comp) {
        $patron = $comp[0];
        $nombre = $comp[1];

        $stmt = $pdo->prepare("
            SELECT COUNT(*) as cnt
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname IN ('public', 'comun')
              AND p.proname LIKE ?
        ");
        $stmt->execute(["%{$patron}%"]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        $count = $result['cnt'];

        if ($count > 0) {
            echo "  ✅ $nombre: $count SPs\n";
            $verificados += $count;
        } else {
            echo "  ❌ $nombre: NO ENCONTRADO\n";
            $faltantes[] = $nombre;
        }
    }

    echo "\n--- RESUMEN ---\n";
    echo "  SPs verificados por patrón: $verificados\n";
    echo "  Componentes faltantes: " . count($faltantes) . "\n";

    if (count($faltantes) > 0) {
        echo "\n  ⚠️ Componentes sin SPs:\n";
        foreach ($faltantes as $f) {
            echo "    - $f\n";
        }
    }

    // 4. Verificar tablas auxiliares
    echo "\n--- TABLAS AUXILIARES ---\n";
    $tablas = [
        'bitacora_conexiones', 'bitacora_saldos', 'bitacora_cambio_firma',
        'bitacora_cambio_password', 'password_history', 'usuarios_firma',
        'semaforo_historial', 'navigation_events', 'bookmarks',
        'h_catastro', 'fechasegfrm', 'c_tipobloqueo', 'c_tipos_suspension',
        'sgc_tramites', 'predios'
    ];

    foreach ($tablas as $tabla) {
        $stmt = $pdo->prepare("
            SELECT EXISTS (
                SELECT 1 FROM pg_tables
                WHERE schemaname = 'comun' AND tablename = ?
            ) as existe
        ");
        $stmt->execute([$tabla]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "  " . ($result['existe'] ? '✅' : '⬜') . " comun.$tabla\n";
    }

    // 5. Listar los primeros 30 SPs del schema comun
    echo "\n--- MUESTRA DE SPs EN SCHEMA COMUN (primeros 30) ---\n";
    $stmt = $pdo->query("
        SELECT p.proname as nombre
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
          AND p.prokind = 'f'
        ORDER BY p.proname
        LIMIT 30
    ");
    $i = 1;
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  $i. {$row['nombre']}\n";
        $i++;
    }

    echo "\n================================================\n";
    echo "   VERIFICACIÓN COMPLETADA\n";
    echo "   Total SPs en BD: $total_sps\n";
    echo "================================================\n";

} catch (PDOException $e) {
    echo "❌ Error de conexión: " . $e->getMessage() . "\n";
    echo "\nVerifica:\n";
    echo "  1. PostgreSQL está corriendo\n";
    echo "  2. Base de datos 'guadalajara' existe\n";
    echo "  3. Usuario/contraseña correctos\n";
}
