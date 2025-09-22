@extends('layouts.app')

@section('title', 'Sistema Descuentos Otras Obligaciones')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">🆕 Sistema de Descuentos y Conversión</h1>
                    <p class="text-muted">Conversión automática de procedimientos y descuentos especializados</p>
                </div>
                <div>
                    <span class="badge bg-primary fs-6">NUEVO</span>
                </div>
            </div>

            <!-- Vue Component Container -->
            <div id="sistema-descuentos-otras-oblig-app">
                <sistema-descuentos-otras-oblig></sistema-descuentos-otras-oblig>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ mix('js/modules/otras-oblig/sistema-descuentos-otras-oblig.js') }}"></script>
@endsection