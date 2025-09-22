<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class AccesoController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones (eRequest/eResponse)
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'login':
                    $response = $this->login($params);
                    break;
                case 'logout':
                    $response = $this->logout($params);
                    break;
                case 'getEjercicioMinMax':
                    $response = $this->getEjercicioMinMax();
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Login de usuario
     */
    private function login($params)
    {
        $validator = Validator::make($params, [
            'usuario' => 'required|string',
            'contrasena' => 'required|string',
            'ejercicio' => 'required|integer',
        ]);
        if ($validator->fails()) {
            return [
                'success' => false,
                'message' => 'Datos incompletos',
                'errors' => $validator->errors()
            ];
        }
        $usuario = $params['usuario'];
        $contrasena = $params['contrasena'];
        $ejercicio = $params['ejercicio'];

        // Llama al stored procedure de validación
        $result = DB::select('SELECT * FROM sp_acceso_login(?, ?, ?)', [$usuario, $contrasena, $ejercicio]);
        if (count($result) > 0 && $result[0]->success) {
            // Guardar en sesión si es necesario
            session(['usuario' => $result[0]->usuario, 'id_usuario' => $result[0]->id_usuario, 'nivel' => $result[0]->nivel]);
            return [
                'success' => true,
                'data' => $result[0],
                'message' => 'Acceso correcto'
            ];
        } else {
            return [
                'success' => false,
                'message' => $result[0]->message ?? 'Usuario o contraseña incorrectos'
            ];
        }
    }

    /**
     * Logout de usuario
     */
    private function logout($params)
    {
        session()->flush();
        return [
            'success' => true,
            'message' => 'Sesión cerrada correctamente'
        ];
    }

    /**
     * Obtener rango de ejercicios válidos
     */
    private function getEjercicioMinMax()
    {
        $result = DB::select('SELECT min_ejercicio, max_ejercicio FROM sp_acceso_ejercicio_minmax()');
        return [
            'success' => true,
            'data' => $result[0] ?? null
        ];
    }
}
