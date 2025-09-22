<?php

namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class TitulosSinController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $payload = $request->input('payload', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getFolioData':
                    $response['data'] = $this->getFolioData($payload);
                    $response['success'] = true;
                    break;
                case 'getRecData':
                    $response['data'] = $this->getRecData($payload);
                    $response['success'] = true;
                    break;
                case 'getIngresos':
                    $response['data'] = $this->getIngresos($payload);
                    $response['success'] = true;
                    break;
                case 'printTituloSin':
                    $response['data'] = $this->printTituloSin($payload);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Obtiene los datos del folio
     */
    private function getFolioData($payload)
    {
        $folio = $payload['folio'] ?? null;
        $fecha = $payload['fecha'] ?? null;
        $operacion = $payload['operacion'] ?? null;
        if (!$folio) {
            throw new \Exception('Folio requerido');
        }
        $result = DB::select('SELECT * FROM sp_titulosin_get_folio(?, ?, ?)', [$folio, $fecha, $operacion]);
        return $result[0] ?? null;
    }

    /**
     * Obtiene los datos de la recaudadora
     */
    private function getRecData($payload)
    {
        $rec = $payload['rec'] ?? null;
        if (!$rec) {
            throw new \Exception('Recaudadora requerida');
        }
        $result = DB::select('SELECT * FROM sp_titulosin_get_rec(?)', [$rec]);
        return $result[0] ?? null;
    }

    /**
     * Obtiene los datos de ingresos
     */
    private function getIngresos($payload)
    {
        $fecha = $payload['fecha'] ?? null;
        $ofna = $payload['ofna'] ?? null;
        $caja = $payload['caja'] ?? null;
        $operacion = $payload['operacion'] ?? null;
        if (!$fecha || !$ofna || !$caja || !$operacion) {
            throw new \Exception('Datos de ingreso incompletos');
        }
        $result = DB::select('SELECT * FROM sp_titulosin_get_ingresos(?, ?, ?, ?)', [$fecha, $ofna, $caja, $operacion]);
        return $result[0] ?? null;
    }

    /**
     * Procesa la impresión del título sin referencias
     */
    private function printTituloSin($payload)
    {
        // Validación básica
        $folio = $payload['folio'] ?? null;
        $fecha = $payload['fecha'] ?? null;
        $operacion = $payload['operacion'] ?? null;
        $rec = $payload['rec'] ?? null;
        $telefono = $payload['telefono'] ?? '';
        $partida = $payload['partida'] ?? null;
        if (!$folio || !$fecha || !$operacion || !$rec) {
            throw new \Exception('Datos requeridos para impresión');
        }
        // Llama al SP que genera/prepara los datos para impresión
        $result = DB::select('SELECT * FROM sp_titulosin_print(?, ?, ?, ?, ?)', [
            $folio, $fecha, $operacion, $rec, $telefono
        ]);
        // El SP puede devolver los datos a imprimir (PDF, JSON, etc.)
        return $result[0] ?? null;
    }
}
