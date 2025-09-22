@extends('layouts.app')

@section('title', 'Sistema Convenios Estacionamientos')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">🆕 Sistema Integral de Convenios</h1>
                    <p class="text-muted">Gestión moderna de convenios para estacionamientos públicos</p>
                </div>
                <div>
                    <span class="badge bg-success fs-6">NUEVO</span>
                </div>
            </div>

            <!-- Vue Component Container -->
            <div id="sistema-convenios-estacionamientos-app">
                <sistema-convenios-estacionamientos></sistema-convenios-estacionamientos>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ mix('js/modules/estacionamientos/sistema-convenios-estacionamientos.js') }}"></script>
@endsection