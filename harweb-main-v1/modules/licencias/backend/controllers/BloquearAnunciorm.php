<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $operation = $eRequest['operation'] ?? null;
        $params = $eRequest['params'] ?? [];
        $eResponse = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($operation) {
                case 'buscar_anuncio':
                    $numero_anuncio = $params['numero_anuncio'] ?? null;
                    $result = DB::select('SELECT * FROM buscar_anuncio(:numero_anuncio)', [
                        'numero_anuncio' => $numero_anuncio
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'consultar_bloqueos':
                    $id_anuncio = $params['id_anuncio'] ?? null;
                    $result = DB::select('SELECT * FROM consultar_bloqueos(:id_anuncio)', [
                        'id_anuncio' => $id_anuncio
                    ]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result;
                    break;
                case 'bloquear_anuncio':
                    $id_anuncio = $params['id_anuncio'] ?? null;
                    $observa = $params['observa'] ?? '';
                    $usuario = $params['usuario'] ?? '';
                    $result = DB::select('SELECT * FROM bloquear_anuncio(:id_anuncio, :observa, :usuario)', [
                        'id_anuncio' => $id_anuncio,
                        'observa' => $observa,
                        'usuario' => $usuario
                    ]);
                    $eResponse['success'] = $result[0]->success;
                    $eResponse['message'] = $result[0]->message;
                    break;
                case 'desbloquear_anuncio':
                    $id_anuncio = $params['id_anuncio'] ?? null;
                    $observa = $params['observa'] ?? '';
                    $usuario = $params['usuario'] ?? '';
                    $result = DB::select('SELECT * FROM desbloquear_anuncio(:id_anuncio, :observa, :usuario)', [
                        'id_anuncio' => $id_anuncio,
                        'observa' => $observa,
                        'usuario' => $usuario
                    ]);
                    $eResponse['success'] = $result[0]->success;
                    $eResponse['message'] = $result[0]->message;
                    break;
                default:
                    $eResponse['message'] = 'Operación no soportada';
            }
        } catch (\Exception $e) {
            $eResponse['success'] = false;
            $eResponse['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $eResponse]);
    }
}
