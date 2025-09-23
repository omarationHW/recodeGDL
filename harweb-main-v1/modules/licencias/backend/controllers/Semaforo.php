<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class SemaforoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario Semáforo
     * Entrada: {
     *   "eRequest": {
     *     "action": "nombre_accion",
     *     "params": { ... }
     *   }
     * }
     * Salida: {
     *   "eResponse": { ... }
     * }
     */
    public function execute(Request $request)
    {
        $input = $request->input('eRequest');
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = ["success" => false, "message" => "Acción no válida", "data" => null];

        try {
            switch ($action) {
                case 'getRandomColor':
                    $response = $this->getRandomColor($params);
                    break;
                case 'registerColorResult':
                    $response = $this->registerColorResult($params);
                    break;
                case 'getStats':
                    $response = $this->getStats($params);
                    break;
                default:
                    $response = ["success" => false, "message" => "Acción no soportada", "data" => null];
            }
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            $response = ["success" => false, "message" => $e->getMessage(), "data" => null];
        }
        return response()->json(["eResponse" => $response]);
    }

    /**
     * Devuelve un color aleatorio (rojo o verde) según la lógica del semáforo
     * Entrada: { "user_id": int }
     * Salida: { "color": "ROJO|VERDE", "numcolor": int }
     */
    private function getRandomColor($params)
    {
        $numcolor = rand(1, 100);
        $color = ($numcolor <= 10) ? 'ROJO' : 'VERDE';
        return [
            "success" => true,
            "message" => "Color generado",
            "data" => ["color" => $color, "numcolor" => $numcolor]
        ];
    }

    /**
     * Registra el resultado del semáforo para un trámite/licencia
     * Entrada: { "tramite_id": int, "color": "ROJO|VERDE", "user_id": int }
     * Salida: { "success": bool, "message": string }
     */
    private function registerColorResult($params)
    {
        $validator = Validator::make($params, [
            'tramite_id' => 'required|integer',
            'color' => 'required|in:ROJO,VERDE',
            'user_id' => 'required|integer'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        // Guardar resultado en tabla semaforo_tramites
        DB::table('semaforo_tramites')->insert([
            'tramite_id' => $params['tramite_id'],
            'color' => $params['color'],
            'user_id' => $params['user_id'],
            'created_at' => now()
        ]);
        return ["success" => true, "message" => "Resultado registrado", "data" => null];
    }

    /**
     * Devuelve estadísticas de colores por usuario
     * Entrada: { "user_id": int }
     * Salida: { "rojos": int, "verdes": int }
     */
    private function getStats($params)
    {
        $user_id = $params['user_id'] ?? null;
        if (!$user_id) {
            return ["success" => false, "message" => "user_id requerido", "data" => null];
        }
        $rojos = DB::table('semaforo_tramites')->where('user_id', $user_id)->where('color', 'ROJO')->count();
        $verdes = DB::table('semaforo_tramites')->where('user_id', $user_id)->where('color', 'VERDE')->count();
        return ["success" => true, "message" => "Estadísticas obtenidas", "data" => ["rojos" => $rojos, "verdes" => $verdes]];
    }
}
