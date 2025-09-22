<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class LicenciaMicrogeneradorController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user() ? $request->user()->username : ($params['usuario'] ?? '');
        $anio = $params['anio'] ?? date('Y');
        $tipo = $params['tipo'] ?? 'L';
        $id = $params['id'] ?? null;
        $licencia = $params['licencia'] ?? null;
        $response = [
            'estatus' => 0,
            'mensaje' => 'Acción no reconocida'
        ];

        try {
            switch ($action) {
                case 'consulta':
                    $tipo = $params['tipo'] ?? 'L';
                    $id = $params['id'] ?? null;
                    if ($tipo === 'L') {
                        $licencia = $params['licencia'] ?? null;
                        $result = DB::select('SELECT * FROM licencias WHERE licencia = ? AND vigente = ?', [$licencia, 'V']);
                        if (count($result) === 0) {
                            $response = [
                                'estatus' => 0,
                                'mensaje' => 'Licencia no vigente',
                                'licencia' => null
                            ];
                        } else {
                            $sp = DB::select('SELECT * FROM lic_registro_microgenerador(?, ?, ?, ?)', [1, $result[0]->id_licencia, $anio, $user]);
                            $response = [
                                'estatus' => $sp[0]->estatus ?? 0,
                                'mensaje' => $sp[0]->mensaje ?? '',
                                'licencia' => $result[0]
                            ];
                        }
                    } else if ($tipo === 'T') {
                        $tramite = $params['tramite'] ?? null;
                        $result = DB::select('SELECT * FROM tramites WHERE id_tramite = ?', [$tramite]);
                        if (count($result) === 0) {
                            $response = [
                                'estatus' => 0,
                                'mensaje' => 'Trámite no vigente',
                                'tramite' => null
                            ];
                        } else {
                            $sp = DB::select('SELECT * FROM lic_registro_microgenerador(?, ?, ?, ?)', [1, $tramite, $anio, $user]);
                            $response = [
                                'estatus' => $sp[0]->estatus ?? 0,
                                'mensaje' => $sp[0]->mensaje ?? '',
                                'tramite' => $result[0]
                            ];
                        }
                    }
                    break;
                case 'alta':
                    $tipo = $params['tipo'] ?? 'L';
                    $id = $params['id'] ?? null;
                    $sp = DB::select('SELECT * FROM lic_registro_microgenerador(?, ?, ?, ?)', [2, $id, $anio, $user]);
                    $response = [
                        'estatus' => $sp[0]->estatus ?? 0,
                        'mensaje' => $sp[0]->mensaje ?? ''
                    ];
                    break;
                case 'cancelar':
                    $tipo = $params['tipo'] ?? 'L';
                    $id = $params['id'] ?? null;
                    $sp = DB::select('SELECT * FROM lic_registro_microgenerador(?, ?, ?, ?)', [3, $id, $anio, $user]);
                    $response = [
                        'estatus' => $sp[0]->estatus ?? 0,
                        'mensaje' => $sp[0]->mensaje ?? ''
                    ];
                    break;
                default:
                    $response = [
                        'estatus' => 0,
                        'mensaje' => 'Acción no reconocida'
                    ];
            }
        } catch (\Exception $e) {
            $response = [
                'estatus' => 0,
                'mensaje' => 'Error: ' . $e->getMessage()
            ];
        }
        return response()->json($response);
    }
}
