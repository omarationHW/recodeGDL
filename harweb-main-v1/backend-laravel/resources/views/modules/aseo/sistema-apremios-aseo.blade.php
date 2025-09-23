@extends('layouts.app')

@section('title', 'Sistema Apremios Aseo')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">🆕 Sistema Integral de Apremios</h1>
                    <p class="text-muted">Gestión avanzada de apremios para servicios de aseo</p>
                </div>
                <div>
                    <span class="badge bg-success fs-6">NUEVO</span>
                </div>
            </div>

            <!-- Vue Component Container -->
            <div id="sistema-apremios-aseo-app">
                <sistema-apremios-aseo></sistema-apremios-aseo>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ mix('js/modules/aseo/sistema-apremios-aseo.js') }}"></script>
@endsection