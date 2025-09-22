<?php

namespace App\Http\Controllers;

use App\Models\ProyectoObra;
use Inertia\Inertia;
use Inertia\Response;

class PavimentacionController extends Controller
{
    public function index(): Response
    {
        $proyectos = ProyectoObra::with('adeudos')
            ->orderBy('contrato')
            ->get();

        return Inertia::render('Pavimentacion/Index', [
            'initialProyectos' => $proyectos
        ]);
    }
}