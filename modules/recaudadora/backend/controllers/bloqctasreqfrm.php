<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class BloqCtasReqController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del formulario BloqCtasReq
     * Entrada: {
     *   "eRequest": {
     *      "action": "listar|bloquear|desbloquear|consultar|historial|enviar_catastro|desbloqueo_masivo",
     *      ... parámetros ...
     *   }
     * }
     */
    public function execute(Request $request)
    {
        $eRequest = $request->input('eRequest');
        $action = $eRequest['action'] ?? null;
        $response = ["success" => false, "message" => "Acción no válida", "data" => null];

        switch ($action) {
            case 'listar':
                $response = $this->listar($eRequest);
                break;
            case 'consultar':
                $response = $this->consultar($eRequest);
                break;
            case 'bloquear':
                $response = $this->bloquear($eRequest);
                break;
            case 'desbloquear':
                $response = $this->desbloquear($eRequest);
                break;
            case 'historial':
                $response = $this->historial($eRequest);
                break;
            case 'enviar_catastro':
                $response = $this->enviarCatastro($eRequest);
                break;
            case 'desbloqueo_masivo':
                $response = $this->desbloqueoMasivo($eRequest);
                break;
            default:
                $response = ["success" => false, "message" => "Acción no reconocida", "data" => null];
        }
        return response()->json(["eResponse" => $response]);
    }

    private function listar($params)
    {
        $tipo = $params['tipo'] ?? 'bloqueadas'; // bloqueadas|desbloqueadas|catastro|enviados
        $fecha = $params['fecha'] ?? null;
        $recaud = $params['recaud'] ?? null;
        $query = "SELECT * FROM norequeribles WHERE 1=1";
        $bindings = [];
        if ($tipo === 'bloqueadas') {
            $query .= " AND user_baja IS NULL";
        } elseif ($tipo === 'desbloqueadas') {
            $query .= " AND user_baja IS NOT NULL";
        }
        if ($fecha) {
            $query .= " AND feccap::date = ?";
            $bindings[] = $fecha;
        }
        if ($recaud) {
            $query .= " AND recaud = ?";
            $bindings[] = $recaud;
        }
        $result = DB::select($query, $bindings);
        return ["success" => true, "message" => "Listado obtenido", "data" => $result];
    }

    private function consultar($params)
    {
        $recaud = $params['recaud'] ?? null;
        $urbrus = $params['urbrus'] ?? null;
        $cuenta = $params['cuenta'] ?? null;
        if (!$recaud || !$urbrus || !$cuenta) {
            return ["success" => false, "message" => "Datos incompletos", "data" => null];
        }
        $cuentaData = DB::selectOne("SELECT * FROM convcta WHERE recaud=? AND urbrus=? AND cuenta=?", [$recaud, $urbrus, $cuenta]);
        if (!$cuentaData) {
            return ["success" => false, "message" => "Cuenta no encontrada", "data" => null];
        }
        $bloqueo = DB::selectOne("SELECT * FROM norequeribles WHERE cvecuenta=? ORDER BY feccap DESC LIMIT 1", [$cuentaData->cvecuenta]);
        $historial = DB::select("SELECT * FROM h_norequeribles WHERE cvecuenta=? ORDER BY feccap DESC", [$cuentaData->cvecuenta]);
        return ["success" => true, "message" => "Consulta exitosa", "data" => ["cuenta" => $cuentaData, "bloqueo" => $bloqueo, "historial" => $historial]];
    }

    private function bloquear($params)
    {
        $validator = Validator::make($params, [
            'recaud' => 'required|integer',
            'urbrus' => 'required|string',
            'cuenta' => 'required|integer',
            'motivo' => 'required|string',
            'fecha_desbloqueo' => 'required|date',
            'usuario' => 'required|string',
            'tipo_bloq' => 'nullable|integer',
            'tipo_inconf' => 'nullable|integer',
            'fecha_envio' => 'nullable|date',
            'lote_envio' => 'nullable|integer'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        $cuenta = DB::selectOne("SELECT * FROM convcta WHERE recaud=? AND urbrus=? AND cuenta=?", [$params['recaud'], $params['urbrus'], $params['cuenta']]);
        if (!$cuenta) {
            return ["success" => false, "message" => "Cuenta no encontrada", "data" => null];
        }
        $exists = DB::selectOne("SELECT 1 FROM norequeribles WHERE cvecuenta=? AND user_baja IS NULL", [$cuenta->cvecuenta]);
        if ($exists) {
            return ["success" => false, "message" => "La cuenta ya está bloqueada", "data" => null];
        }
        $id = DB::table('norequeribles')->insertGetId([
            'recaud' => $params['recaud'],
            'urbrus' => $params['urbrus'],
            'cuenta' => $params['cuenta'],
            'cvecuenta' => $cuenta->cvecuenta,
            'feccap' => now(),
            'capturista' => $params['usuario'],
            'observacion' => $params['motivo'],
            'fecbaja' => $params['fecha_desbloqueo'],
            'tipo_bloq' => $params['tipo_bloq'] ?? 200,
            'fecha_envio' => $params['fecha_envio'] ?? null,
            'lote_envio' => $params['lote_envio'] ?? null
        ]);
        return ["success" => true, "message" => "Cuenta bloqueada correctamente", "data" => ["id" => $id]];
    }

    private function desbloquear($params)
    {
        $validator = Validator::make($params, [
            'recaud' => 'required|integer',
            'urbrus' => 'required|string',
            'cuenta' => 'required|integer',
            'motivo' => 'required|string',
            'fecha_desbloqueo' => 'required|date',
            'usuario' => 'required|string'
        ]);
        if ($validator->fails()) {
            return ["success" => false, "message" => $validator->errors()->first(), "data" => null];
        }
        $cuenta = DB::selectOne("SELECT * FROM convcta WHERE recaud=? AND urbrus=? AND cuenta=?", [$params['recaud'], $params['urbrus'], $params['cuenta']]);
        if (!$cuenta) {
            return ["success" => false, "message" => "Cuenta no encontrada", "data" => null];
        }
        $bloqueo = DB::table('norequeribles')
            ->where('cvecuenta', $cuenta->cvecuenta)
            ->whereNull('user_baja')
            ->orderByDesc('feccap')
            ->first();
        if (!$bloqueo) {
            return ["success" => false, "message" => "No existe bloqueo vigente para esta cuenta", "data" => null];
        }
        DB::table('norequeribles')->where('id', $bloqueo->id)->update([
            'fecbaja' => $params['fecha_desbloqueo'],
            'user_baja' => $params['usuario'],
            'observacion' => $bloqueo->observacion."\n".$params['motivo'],
            'tipo_bloq' => 200
        ]);
        return ["success" => true, "message" => "Cuenta desbloqueada correctamente", "data" => ["id" => $bloqueo->id]];
    }

    private function historial($params)
    {
        $cvecuenta = $params['cvecuenta'] ?? null;
        if (!$cvecuenta) {
            return ["success" => false, "message" => "Falta cvecuenta", "data" => null];
        }
        $historial = DB::select("SELECT * FROM h_norequeribles WHERE cvecuenta=? ORDER BY feccap DESC", [$cvecuenta]);
        return ["success" => true, "message" => "Historial obtenido", "data" => $historial];
    }

    private function enviarCatastro($params)
    {
        $usuario = $params['usuario'] ?? null;
        $recaud = $params['recaud'] ?? null;
        if (!$usuario || !$recaud) {
            return ["success" => false, "message" => "Faltan datos", "data" => null];
        }
        $result = DB::selectOne("SELECT sp_grabainconf(?, ?) as cuentas", [$recaud, $usuario]);
        return ["success" => true, "message" => "Cuentas enviadas a Catastro", "data" => $result];
    }

    private function desbloqueoMasivo($params)
    {
        $usuario = $params['usuario'] ?? null;
        if (!$usuario) {
            return ["success" => false, "message" => "Falta usuario", "data" => null];
        }
        $result = DB::selectOne("SELECT spd_norequeribles(?) as cuentas", [$usuario]);
        return ["success" => true, "message" => "Desbloqueo masivo realizado", "data" => $result];
    }
}
