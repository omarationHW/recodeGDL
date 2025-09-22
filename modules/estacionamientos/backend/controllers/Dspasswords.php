<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Handle unified API requests via /api/execute
     */
    public function handle(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'error' => null
        ];

        try {
            switch ($eRequest) {
                case 'passwords.list':
                    $usuario = $params['usuario'] ?? null;
                    $result = DB::select('SELECT * FROM sp_passwords_list(?)', [$usuario]);
                    $response['success'] = true;
                    $response['data'] = $result;
                    break;
                case 'passwords.create':
                    $usuario = $params['usuario'] ?? null;
                    $nombre = $params['nombre'] ?? null;
                    $estado = $params['estado'] ?? null;
                    $id_rec = $params['id_rec'] ?? null;
                    $nivel = $params['nivel'] ?? null;
                    $result = DB::select('SELECT * FROM sp_passwords_create(?,?,?,?,?)', [
                        $usuario, $nombre, $estado, $id_rec, $nivel
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'passwords.update':
                    $id_usuario = $params['id_usuario'] ?? null;
                    $usuario = $params['usuario'] ?? null;
                    $nombre = $params['nombre'] ?? null;
                    $estado = $params['estado'] ?? null;
                    $id_rec = $params['id_rec'] ?? null;
                    $nivel = $params['nivel'] ?? null;
                    $result = DB::select('SELECT * FROM sp_passwords_update(?,?,?,?,?,?)', [
                        $id_usuario, $usuario, $nombre, $estado, $id_rec, $nivel
                    ]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                case 'passwords.delete':
                    $id_usuario = $params['id_usuario'] ?? null;
                    $result = DB::select('SELECT * FROM sp_passwords_delete(?)', [$id_usuario]);
                    $response['success'] = true;
                    $response['data'] = $result[0] ?? null;
                    break;
                default:
                    $response['error'] = 'Unknown eRequest: ' . $eRequest;
            }
        } catch (\Exception $e) {
            $response['error'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }
}
