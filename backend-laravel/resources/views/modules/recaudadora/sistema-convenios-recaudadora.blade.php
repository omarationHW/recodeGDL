@extends('layouts.app')

@section('title', 'Sistema Convenios Recaudadora')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">🆕 Sistema Integral de Convenios</h1>
                    <p class="text-muted">Gestión moderna de convenios para recaudación fiscal</p>
                </div>
                <div>
                    <span class="badge bg-success fs-6">NUEVO</span>
                </div>
            </div>

            <!-- Vue Component Container -->
            <div id="sistema-convenios-recaudadora-app">
                <sistema-convenios-recaudadora></sistema-convenios-recaudadora>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ mix('js/modules/recaudadora/sistema-convenios-recaudadora.js') }}"></script>
@endsection