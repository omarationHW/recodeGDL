@extends('layouts.app')

@section('title', 'Funciones Excluidas Recaudadora')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">🆕 Funciones Excluidas</h1>
                    <p class="text-muted">Funciones obsoletas removidas y sus reemplazos modernos</p>
                </div>
                <div>
                    <span class="badge bg-danger fs-6">MODERNIZACIÓN</span>
                </div>
            </div>

            <!-- Vue Component Container -->
            <div id="funciones-excluidas-recaudadora-app">
                <funciones-excluidas-recaudadora></funciones-excluidas-recaudadora>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ mix('js/modules/recaudadora/funciones-excluidas-recaudadora.js') }}"></script>
@endsection