@extends('layouts.app')

@section('title', 'Catálogo Giros con Importes - Licencias')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">🆕 Catálogo Giros con Importes</h1>
                    <p class="text-muted">Gestión integral de giros comerciales con importes automatizados</p>
                </div>
                <div>
                    <span class="badge bg-success fs-6">NUEVO</span>
                </div>
            </div>

            <!-- Vue Component Container -->
            <div id="catalogo-giros-importes-app">
                <catalogo-giros-importes></catalogo-giros-importes>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ mix('js/modules/licencias/catalogo-giros-importes.js') }}"></script>
@endsection