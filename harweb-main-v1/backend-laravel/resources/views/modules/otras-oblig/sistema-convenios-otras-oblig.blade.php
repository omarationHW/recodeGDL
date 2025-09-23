@extends('layouts.app')

@section('title', 'Sistema Convenios Otras Obligaciones')

@section('content')
<div class="container-fluid">
    <div class="row">
        <div class="col-12">
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h3 mb-0">🆕 Sistema Integral de Convenios</h1>
                    <p class="text-muted">Gestión moderna de convenios para otras obligaciones fiscales</p>
                </div>
                <div>
                    <span class="badge bg-success fs-6">NUEVO</span>
                </div>
            </div>

            <!-- Vue Component Container -->
            <div id="sistema-convenios-otras-oblig-app">
                <sistema-convenios-otras-oblig></sistema-convenios-otras-oblig>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="{{ mix('js/modules/otras-oblig/sistema-convenios-otras-oblig.js') }}"></script>
@endsection