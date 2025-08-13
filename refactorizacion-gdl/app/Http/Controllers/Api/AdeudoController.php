<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AdeudoObra;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AdeudoController extends Controller
{
    public function registrarPago(Request $request, $id): JsonResponse
    {
        $validated = $request->validate([
            'numero_recibo' => 'required|string|max:20'
        ]);

        $service = app(\App\Services\ProyectoObraService::class);
        $success = $service->registrarPago($id, $validated['numero_recibo']);

        if ($success) {
            return response()->json([
                'success' => true,
                'message' => 'Pago registrado correctamente'
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'No se pudo registrar el pago'
        ], 400);
    }

    public function adeudosPorProyecto($idControl): JsonResponse
    {
        $adeudos = AdeudoObra::where('id_control', $idControl)
            ->orderBy('axo')
            ->orderBy('mes')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $adeudos
        ]);
    }
}