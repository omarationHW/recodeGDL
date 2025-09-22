@extends('layouts.app')

@section('title', 'Sistema Apremios Apremios')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">🆕 Sistema Integral de Apremios</h1>
                    <p class="text-muted">Gestión avanzada de procedimientos de apremio</p>
                </div>
                <div>
                    <span class="badge bg-success fs-6">NUEVO</span>
                </div>
            </div>

            <!-- Vue Component Container -->
            <div id="sistema-apremios-apremios-app">
                <sistema-apremios-apremios></sistema-apremios-apremios>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ mix('js/modules/apremios/sistema-apremios-apremios.js') }}"></script>
@endsection