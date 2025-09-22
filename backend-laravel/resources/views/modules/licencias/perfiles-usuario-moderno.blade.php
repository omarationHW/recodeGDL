@extends('layouts.app')

@section('title', 'Perfiles Usuario Modernos - Licencias')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">🆕 Perfiles Usuario Modernos</h1>
                    <p class="text-muted">Sistema modernizado de gestión de perfiles de usuario</p>
                </div>
                <div>
                    <span class="badge bg-success fs-6">NUEVO</span>
                </div>
            </div>

            <!-- Vue Component Container -->
            <div id="perfiles-usuario-moderno-app">
                <perfiles-usuario-moderno></perfiles-usuario-moderno>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ mix('js/modules/licencias/perfiles-usuario-moderno.js') }}"></script>
@endsection