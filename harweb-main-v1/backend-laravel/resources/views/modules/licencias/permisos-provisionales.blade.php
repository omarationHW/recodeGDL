@extends('layouts.app')

@section('title', 'Permisos Provisionales - Licencias')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">🆕 Permisos Provisionales</h1>
                    <p class="text-muted">Sistema avanzado de gestión de permisos provisionales</p>
                </div>
                <div>
                    <span class="badge bg-success fs-6">NUEVO</span>
                </div>
            </div>

            <!-- Vue Component Container -->
            <div id="permisos-provisionales-app">
                <permisos-provisionales></permisos-provisionales>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ mix('js/modules/licencias/permisos-provisionales.js') }}"></script>
@endsection