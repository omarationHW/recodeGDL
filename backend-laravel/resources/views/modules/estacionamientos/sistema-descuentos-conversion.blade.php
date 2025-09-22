@extends('layouts.app')

@section('title', 'Sistema Descuentos y Conversión Estacionamientos')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">🆕 Sistema de Descuentos y Conversión</h1>
                    <p class="text-muted">Conversión automática de procedimientos y descuentos</p>
                </div>
                <div>
                    <span class="badge bg-success fs-6">NUEVO</span>
                </div>
            </div>

            <!-- Vue Component Container -->
            <div id="sistema-descuentos-conversion-app">
                <sistema-descuentos-conversion></sistema-descuentos-conversion>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ mix('js/modules/estacionamientos/sistema-descuentos-conversion.js') }}"></script>
@endsection