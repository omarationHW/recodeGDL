<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use App\Http\Controllers\Controller;

class UnidadImgController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $eResponse = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($eRequest['action']) {
                case 'getUnidadImg':
                    $unidad = DB::selectOne('SELECT * FROM get_unidad_img()');
                    $eResponse['success'] = true;
                    $eResponse['data'] = $unidad ? $unidad->unidad_img : null;
                    break;
                case 'setUnidadImg':
                    $unidad = $eRequest['params']['unidad_img'] ?? null;
                    if (!$unidad) {
                        throw new \Exception('Unidad de imagenes requerida');
                    }
                    $result = DB::selectOne('SELECT * FROM set_unidad_img(?)', [$unidad]);
                    $eResponse['success'] = $result && $result->success;
                    $eResponse['message'] = $result->msg ?? '';
                    break;
                case 'rutaimagen':
                    $id_tramite = $eRequest['params']['id_tramite'] ?? null;
                    $id_imagen = $eRequest['params']['id_imagen'] ?? null;
                    if (!$id_tramite || !$id_imagen) {
                        throw new \Exception('id_tramite e id_imagen requeridos');
                    }
                    $result = DB::selectOne('SELECT * FROM rutaimagen(?, ?)', [$id_tramite, $id_imagen]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result->ruta;
                    break;
                case 'rutadir':
                    $id_tramite = $eRequest['params']['id_tramite'] ?? null;
                    if (!$id_tramite) {
                        throw new \Exception('id_tramite requerido');
                    }
                    $result = DB::selectOne('SELECT * FROM rutadir(?)', [$id_tramite]);
                    $eResponse['success'] = true;
                    $eResponse['data'] = $result->ruta;
                    break;
                default:
                    $eResponse['message'] = 'Acción no soportada';
            }
        } catch (\Exception $ex) {
            $eResponse['success'] = false;
            $eResponse['message'] = $ex->getMessage();
        }

        return response()->json($eResponse);
    }
}
