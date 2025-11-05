<template>
  <div class="container-fluid p-0 h-100">
    <!-- Municipal Header Enhanced -->
    <div class="municipal-header p-3 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1">
            <i class="fas fa-shield-alt me-2"></i>
            Sistema de Gestión de Bloqueos de Anuncios
          </h1>
          <p class="mb-0 opacity-75">
            Control integral de suspensiones, infracciones y multas publicitarias
            <span v-if="stats.total_bloqueos > 0" class="badge bg-light text-dark ms-2">
              {{ stats.total_bloqueos }} bloqueos activos
            </span>
          </p>
        </div>
        <div class="text-white-50">
          <ol class="breadcrumb mb-0 bg-transparent p-0">
            <li class="breadcrumb-item"><a href="#" class="text-white-50">Inicio</a></li>
            <li class="breadcrumb-item"><a href="#" class="text-white-50">Licencias</a></li>
            <li class="breadcrumb-item text-white active">Gestión de Bloqueos</li>
          </ol>
        </div>
      </div>
    </div>

    <!-- Enhanced Controls -->
    <div class="municipal-controls border-bottom p-3">
      <div class="d-flex justify-content-between align-items-center">
        <div class="btn-group" role="group">
          <button type="button" class="btn btn-municipal-white" @click="$router.push('/dashboard')">
            <i class="fas fa-home"></i>
          </button>
          <button type="button" class="btn btn-municipal-white" @click="$router.push('/licencias')">
            <i class="fas fa-file-contract"></i>
          </button>
          <button type="button" class="btn btn-municipal-white active">
            <i class="fas fa-shield-alt"></i>
          </button>
          <button type="button" class="btn btn-municipal-white" @click="generarReporte">
            <i class="fas fa-chart-bar"></i>
          </button>
        </div>
        <div class="d-flex gap-2">
          <button type="button" class="btn btn-outline-light btn-sm" @click="reactivarSuspensionesVencidas">
            <i class="fas fa-clock me-1"></i>
            Auto-reactivar
          </button>
          <button type="button" class="btn btn-outline-light btn-sm" @click="enviarNotificaciones">
            <i class="fas fa-bell me-1"></i>
            Notificar
          </button>
        </div>
      </div>
    </div>

    <!-- Main Content Enhanced -->
    <div class="p-4">
      <!-- Estadísticas Dashboard -->
      <div class="row mb-4" v-if="stats">
        <div class="col-md-3">
          <div class="card text-center border-danger">
            <div class="card-body">
              <i class="fas fa-ban fa-2x text-danger mb-2"></i>
              <h4 class="card-title text-danger">{{ stats.total_bloqueos || 0 }}</h4>
              <p class="card-text small">Bloqueos Activos</p>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="card text-center border-warning">
            <div class="card-body">
              <i class="fas fa-pause fa-2x text-warning mb-2"></i>
              <h4 class="card-title text-warning">{{ stats.total_suspensiones || 0 }}</h4>
              <p class="card-text small">Suspensiones Temporales</p>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="card text-center border-success">
            <div class="card-body">
              <i class="fas fa-dollar-sign fa-2x text-success mb-2"></i>
              <h4 class="card-title text-success">${{ formatearMoneda(stats.total_multas_pendientes) }}</h4>
              <p class="card-text small">Multas Pendientes</p>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="card text-center border-info">
            <div class="card-body">
              <i class="fas fa-exclamation-triangle fa-2x text-info mb-2"></i>
              <h4 class="card-title text-info">{{ stats.infracciones_pendientes || 0 }}</h4>
              <p class="card-text small">Infracciones Pendientes</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Enhanced Search Form -->
      <div class="card mb-4">
        <div class="card-header bg-primary text-white">
          <h5 class="mb-0">
            <i class="fas fa-search me-2"></i>
            Búsqueda Avanzada de Anuncios
          </h5>
        </div>
        <div class="card-body">
          <form @submit.prevent="buscarAnuncio">
            <div class="row g-3 align-items-end">
              <div class="col-md-4">
                <label for="numeroAnuncio" class="form-label fw-bold">Número de Anuncio *</label>
                <div class="input-group">
                  <span class="input-group-text"><i class="fas fa-hashtag"></i></span>
                  <input
                    type="text"
                    class="form-control"
                    id="numeroAnuncio"
                    v-model="numero_anuncio"
                    placeholder="Ej: 2024001234"
                    required
                    @keyup.enter="buscarAnuncio"
                    :class="{'is-invalid': errors.numero_anuncio}"
                  >
                  <div v-if="errors.numero_anuncio" class="invalid-feedback">
                    {{ errors.numero_anuncio }}
                  </div>
                </div>
              </div>
              <div class="col-md-3">
                <label class="form-label fw-bold">Estado Actual</label>
                <div class="form-control-plaintext bg-light p-2 rounded">
                  <span v-if="anuncio" class="d-flex align-items-center">
                    <i class="fas me-2" :class="{
                      'fa-ban text-danger': anuncio.bloqueado === 1,
                      'fa-pause text-warning': anuncio.bloqueado === 2,
                      'fa-check-circle text-success': anuncio.bloqueado === 0
                    }"></i>
                    <span :class="{
                      'text-danger fw-bold': anuncio.bloqueado === 1,
                      'text-warning fw-bold': anuncio.bloqueado === 2,
                      'text-success fw-bold': anuncio.bloqueado === 0
                    }">
                      {{ getEstadoTexto(anuncio.bloqueado) }}
                    </span>
                  </span>
                  <span v-else class="text-muted">Sin consultar</span>
                </div>
              </div>
              <div class="col-md-3">
                <button
                  type="submit"
                  class="btn btn-primary w-100"
                  :disabled="cargando || !numero_anuncio"
                >
                  <span v-if="cargando" class="spinner-border spinner-border-sm me-2"></span>
                  <i v-else class="fas fa-search me-2"></i>
                  {{ cargando ? 'Buscando...' : 'Buscar Anuncio' }}
                </button>
              </div>
              <div class="col-md-2">
                <button
                  type="button"
                  class="btn btn-outline-secondary w-100"
                  @click="limpiarBusqueda"
                  :disabled="cargando"
                >
                  <i class="fas fa-eraser me-2"></i>
                  Limpiar
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Enhanced Anuncio Information -->
      <div v-if="anuncio" class="card mb-4">
        <div class="card-header bg-info text-white d-flex justify-content-between align-items-center">
          <h5 class="mb-0">
            <i class="fas fa-info-circle me-2"></i>
            Información Completa del Anuncio
          </h5>
          <div class="d-flex gap-2">
            <span class="badge fs-6" :class="{
              'bg-danger': anuncio.bloqueado === 1,
              'bg-warning': anuncio.bloqueado === 2,
              'bg-success': anuncio.bloqueado === 0
            }">
              {{ getEstadoTexto(anuncio.bloqueado) }}
            </span>
            <span v-if="tieneInfracciones" class="badge bg-warning fs-6">
              <i class="fas fa-exclamation-triangle me-1"></i>
              Con Infracciones
            </span>
            <span v-if="tieneMultasPendientes" class="badge bg-danger fs-6">
              <i class="fas fa-dollar-sign me-1"></i>
              Multas Pendientes
            </span>
          </div>
        </div>
        <div class="card-body">
          <!-- Información básica -->
          <div class="row g-3 mb-4">
            <div class="col-md-3">
              <label class="form-label fw-bold text-primary">ID Anuncio</label>
              <div class="form-control-plaintext bg-light p-2 rounded border">
                <i class="fas fa-hashtag me-2 text-muted"></i>
                {{ anuncio.id_anuncio }}
              </div>
            </div>
            <div class="col-md-3">
              <label class="form-label fw-bold text-primary">Número Anuncio</label>
              <div class="form-control-plaintext bg-light p-2 rounded border">
                <i class="fas fa-tag me-2 text-muted"></i>
                {{ anuncio.numero_anuncio }}
              </div>
            </div>
            <div class="col-md-3">
              <label class="form-label fw-bold text-primary">Licencia Referencia</label>
              <div class="form-control-plaintext bg-light p-2 rounded border">
                <i class="fas fa-file-contract me-2 text-muted"></i>
                {{ anuncio.id_licencia }}
              </div>
            </div>
            <div class="col-md-3">
              <label class="form-label fw-bold text-primary">Área Anuncio</label>
              <div class="form-control-plaintext bg-light p-2 rounded border">
                <i class="fas fa-ruler-combined me-2 text-muted"></i>
                {{ anuncio.area_anuncio || 'N/A' }} m²
              </div>
            </div>
          </div>

          <!-- Fechas y estado -->
          <div class="row g-3 mb-4">
            <div class="col-md-4">
              <label class="form-label fw-bold text-success">Fecha Otorgamiento</label>
              <div class="form-control-plaintext bg-light p-2 rounded border">
                <i class="fas fa-calendar-check me-2 text-success"></i>
                {{ formatearFecha(anuncio.fecha_otorgamiento) }}
              </div>
            </div>
            <div class="col-md-4" v-if="anuncio.fecha_vencimiento">
              <label class="form-label fw-bold text-warning">Fecha Vencimiento</label>
              <div class="form-control-plaintext bg-light p-2 rounded border">
                <i class="fas fa-calendar-times me-2 text-warning"></i>
                {{ formatearFecha(anuncio.fecha_vencimiento) }}
              </div>
            </div>
            <div class="col-md-4" v-if="anuncio.fecha_bloqueo">
              <label class="form-label fw-bold text-danger">Fecha Bloqueo</label>
              <div class="form-control-plaintext bg-light p-2 rounded border">
                <i class="fas fa-ban me-2 text-danger"></i>
                {{ formatearFecha(anuncio.fecha_bloqueo) }}
              </div>
            </div>
          </div>

          <!-- Medidas y ubicación -->
          <div class="row g-3 mb-4">
            <div class="col-md-4">
              <label class="form-label fw-bold text-info">Medidas</label>
              <div class="form-control-plaintext bg-light p-2 rounded border">
                <i class="fas fa-expand-arrows-alt me-2 text-info"></i>
                {{ anuncio.medidas1 || 'N/A' }} x {{ anuncio.medidas2 || 'N/A' }}
              </div>
            </div>
            <div class="col-md-8">
              <label class="form-label fw-bold text-info">Ubicación Completa</label>
              <div class="form-control-plaintext bg-light p-2 rounded border">
                <i class="fas fa-map-marker-alt me-2 text-info"></i>
                {{ anuncio.ubicacion || 'N/A' }}
                <span v-if="anuncio.numext_ubic"> - Ext: {{ anuncio.numext_ubic }}</span>
                <span v-if="anuncio.letraext_ubic">{{ anuncio.letraext_ubic }}</span>
                <span v-if="anuncio.numint_ubic"> - Int: {{ anuncio.numint_ubic }}</span>
                <span v-if="anuncio.letraint_ubic">{{ anuncio.letraint_ubic }}</span>
              </div>
            </div>
          </div>

          <!-- Información financiera y responsable -->
          <div class="row g-3" v-if="anuncio.total_multas > 0 || anuncio.responsable_actual">
            <div class="col-md-4" v-if="anuncio.total_multas > 0">
              <label class="form-label fw-bold text-danger">Total Multas</label>
              <div class="form-control-plaintext bg-light p-2 rounded border">
                <i class="fas fa-dollar-sign me-2 text-danger"></i>
                ${{ formatearMoneda(anuncio.total_multas) }}
              </div>
            </div>
            <div class="col-md-4" v-if="anuncio.responsable_actual">
              <label class="form-label fw-bold text-secondary">Responsable</label>
              <div class="form-control-plaintext bg-light p-2 rounded border">
                <i class="fas fa-user me-2 text-secondary"></i>
                {{ anuncio.responsable_actual }}
              </div>
            </div>
            <div class="col-md-4" v-if="anuncio.telefono_contacto">
              <label class="form-label fw-bold text-secondary">Contacto</label>
              <div class="form-control-plaintext bg-light p-2 rounded border">
                <i class="fas fa-phone me-2 text-secondary"></i>
                {{ anuncio.telefono_contacto }}
              </div>
            </div>
          </div>

          <!-- Motivo de bloqueo actual -->
          <div v-if="anuncio.motivo_bloqueo && anuncio.bloqueado > 0" class="mt-4">
            <div class="alert alert-warning">
              <h6 class="alert-heading">
                <i class="fas fa-info-circle me-2"></i>
                Motivo del Bloqueo Actual
              </h6>
              <p class="mb-0">{{ anuncio.motivo_bloqueo }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Enhanced Action Buttons -->
      <div v-if="anuncio" class="card mb-4">
        <div class="card-header bg-secondary text-white">
          <h5 class="mb-0">
            <i class="fas fa-cogs me-2"></i>
            Acciones Disponibles
          </h5>
        </div>
        <div class="card-body">
          <div class="row g-3">
            <!-- Acciones de bloqueo -->
            <div class="col-md-6">
              <div class="d-grid gap-2">
                <button
                  v-if="puedeBloquear"
                  type="button"
                  class="btn btn-danger btn-lg"
                  @click="abrirModalBloquear"
                  :disabled="procesando"
                >
                  <i class="fas fa-ban me-2"></i>
                  Bloquear / Suspender Anuncio
                </button>
                <button
                  v-if="puedeDesbloquear"
                  type="button"
                  class="btn btn-success btn-lg"
                  @click="abrirModalDesbloquear"
                  :disabled="procesando"
                >
                  <i class="fas fa-unlock me-2"></i>
                  Desbloquear / Reactivar Anuncio
                </button>
              </div>
            </div>

            <!-- Acciones de multas -->
            <div class="col-md-6">
              <div class="d-grid gap-2">
                <button
                  v-if="tieneMultasPendientes"
                  type="button"
                  class="btn btn-warning btn-lg"
                  @click="abrirModalMultas"
                  :disabled="procesando"
                >
                  <i class="fas fa-dollar-sign me-2"></i>
                  Gestionar Multas
                  <span class="badge bg-light text-dark ms-2">
                    ${{ formatearMoneda(anuncio.total_multas) }}
                  </span>
                </button>
                <button
                  type="button"
                  class="btn btn-info btn-lg"
                  @click="cargarHistorialBloqueos"
                  :disabled="cargandoHistorial"
                >
                  <span v-if="cargandoHistorial" class="spinner-border spinner-border-sm me-2"></span>
                  <i v-else class="fas fa-history me-2"></i>
                  {{ cargandoHistorial ? 'Actualizando...' : 'Actualizar Historial' }}
                </button>
              </div>
            </div>
          </div>

          <!-- Quick stats del anuncio -->
          <div class="row mt-4 pt-3 border-top">
            <div class="col-md-3 text-center">
              <div class="text-muted small">Infracciones</div>
              <div class="h5 mb-0" :class="tieneInfracciones ? 'text-warning' : 'text-success'">
                {{ tieneInfracciones ? 'SÍ' : 'NO' }}
              </div>
            </div>
            <div class="col-md-3 text-center">
              <div class="text-muted small">Multas Pendientes</div>
              <div class="h5 mb-0" :class="tieneMultasPendientes ? 'text-danger' : 'text-success'">
                {{ tieneMultasPendientes ? 'SÍ' : 'NO' }}
              </div>
            </div>
            <div class="col-md-3 text-center">
              <div class="text-muted small">Estado Actual</div>
              <div class="h5 mb-0" :class="{
                'text-danger': anuncio.bloqueado === 1,
                'text-warning': anuncio.bloqueado === 2,
                'text-success': anuncio.bloqueado === 0
              }">
                {{ getEstadoTexto(anuncio.bloqueado) }}
              </div>
            </div>
            <div class="col-md-3 text-center">
              <div class="text-muted small">Movimientos</div>
              <div class="h5 mb-0 text-info">
                {{ bloqueos.length }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Enhanced Historial de Movimientos -->
      <div v-if="anuncio" class="card">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
          <h5 class="mb-0">
            <i class="fas fa-history me-2"></i>
            Historial Completo de Movimientos
            <span v-if="bloqueos.length > 0" class="badge bg-primary ms-2">{{ bloqueos.length }} registros</span>
          </h5>
          <div class="d-flex gap-2">
            <button
              type="button"
              class="btn btn-outline-light btn-sm"
              @click="cargarHistorialBloqueos"
              :disabled="cargandoHistorial"
            >
              <span v-if="cargandoHistorial" class="spinner-border spinner-border-sm me-1"></span>
              <i v-else class="fas fa-sync-alt me-1"></i>
              {{ cargandoHistorial ? 'Actualizando...' : 'Actualizar' }}
            </button>
            <button
              type="button"
              class="btn btn-outline-light btn-sm"
              @click="generarReporte"
            >
              <i class="fas fa-file-export me-1"></i>
              Exportar
            </button>
          </div>
        </div>
        <div class="card-body p-0">
          <!-- Loading state -->
          <div v-if="cargandoHistorial" class="p-5 text-center">
            <div class="spinner-border text-primary mb-3" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <h5 class="text-muted">
              <i class="fas fa-clock me-2"></i>
              Cargando historial detallado...
            </h5>
            <p class="text-muted mb-0">Obteniendo información de movimientos, multas e infracciones</p>
          </div>

          <!-- Empty state -->
          <div v-else-if="bloqueos.length === 0" class="p-5 text-center">
            <i class="fas fa-info-circle fa-3x text-muted mb-3"></i>
            <h5 class="text-muted">No hay movimientos registrados</h5>
            <p class="text-muted mb-0">Este anuncio no tiene historial de bloqueos o suspensiones</p>
          </div>

          <!-- Enhanced table with detailed info -->
          <div v-else class="table-responsive">
            <table class="table table-hover mb-0">
              <thead class="bg-light">
                <tr>
                  <th width="15%">
                    <i class="fas fa-flag me-1"></i>
                    Estado
                  </th>
                  <th width="15%">
                    <i class="fas fa-user me-1"></i>
                    Capturista
                  </th>
                  <th width="20%">
                    <i class="fas fa-calendar me-1"></i>
                    Fecha/Hora
                  </th>
                  <th width="15%">
                    <i class="fas fa-tags me-1"></i>
                    Categoría
                  </th>
                  <th width="15%">
                    <i class="fas fa-dollar-sign me-1"></i>
                    Multa
                  </th>
                  <th width="20%">
                    <i class="fas fa-comment me-1"></i>
                    Observaciones
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="bloqueo in bloqueos" :key="bloqueo.id_bloqueo" class="align-middle">
                  <!-- Estado con iconos mejorados -->
                  <td>
                    <span class="badge d-flex align-items-center" :class="{
                      'bg-danger': bloqueo.estado === 'BLOQUEADO',
                      'bg-warning': bloqueo.estado === 'SUSPENDIDO',
                      'bg-success': bloqueo.estado === 'DESBLOQUEADO' || bloqueo.estado === 'ACTIVO',
                      'bg-info': bloqueo.estado === 'REACTIVACION'
                    }">
                      <i class="fas me-1" :class="{
                        'fa-ban': bloqueo.estado === 'BLOQUEADO',
                        'fa-pause': bloqueo.estado === 'SUSPENDIDO',
                        'fa-unlock': bloqueo.estado === 'DESBLOQUEADO',
                        'fa-play': bloqueo.estado === 'REACTIVACION',
                        'fa-check-circle': bloqueo.estado === 'ACTIVO'
                      }"></i>
                      {{ bloqueo.estado }}
                    </span>
                  </td>

                  <!-- Capturista -->
                  <td>
                    <div class="d-flex align-items-center">
                      <div class="avatar-sm bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-2" style="width: 32px; height: 32px;">
                        {{ (bloqueo.capturista || 'N/A').charAt(0).toUpperCase() }}
                      </div>
                      <div>
                        <div class="fw-bold small">{{ bloqueo.capturista || 'N/A' }}</div>
                      </div>
                    </div>
                  </td>

                  <!-- Fecha y hora detallada -->
                  <td>
                    <div class="small">
                      <div class="fw-bold">{{ formatearFecha(bloqueo.fecha_mov) }}</div>
                      <div class="text-muted" v-if="bloqueo.hora_mov">
                        <i class="fas fa-clock me-1"></i>
                        {{ bloqueo.hora_mov }}
                      </div>
                    </div>
                  </td>

                  <!-- Categoría del motivo -->
                  <td>
                    <span v-if="bloqueo.motivo_categoria" class="badge bg-secondary small">
                      {{ bloqueo.motivo_categoria }}
                    </span>
                    <span v-else class="text-muted small">Sin categoría</span>
                  </td>

                  <!-- Información de multa -->
                  <td>
                    <div v-if="bloqueo.monto_multa && bloqueo.monto_multa > 0">
                      <div class="fw-bold text-danger">${{ formatearMoneda(bloqueo.monto_multa) }}</div>
                      <div class="small text-muted" v-if="bloqueo.fecha_limite_pago">
                        Vence: {{ formatearFecha(bloqueo.fecha_limite_pago) }}
                      </div>
                    </div>
                    <span v-else class="text-muted small">Sin multa</span>
                  </td>

                  <!-- Observaciones expandibles -->
                  <td>
                    <div class="position-relative">
                      <div
                        class="text-truncate small"
                        style="max-width: 200px;"
                        :title="bloqueo.observa"
                      >
                        {{ bloqueo.observa || 'Sin observaciones' }}
                      </div>
                      <button
                        v-if="bloqueo.observa && bloqueo.observa.length > 50"
                        type="button"
                        class="btn btn-sm btn-outline-secondary mt-1"
                        @click="mostrarDetalleCompleto(bloqueo)"
                      >
                        <i class="fas fa-expand-alt me-1"></i>
                        Ver más
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación si hay muchos registros -->
          <div v-if="bloqueos.length > 10" class="card-footer bg-light">
            <div class="d-flex justify-content-between align-items-center">
              <small class="text-muted">Mostrando {{ bloqueos.length }} registros</small>
              <button type="button" class="btn btn-sm btn-outline-primary">
                <i class="fas fa-chevron-down me-1"></i>
                Cargar más
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Modal Gestión de Multas -->
      <div v-if="multasDialog" class="modal fade show d-block" style="background-color: rgba(0,0,0,0.6);">
        <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-header bg-warning text-dark">
              <h5 class="modal-title">
                <i class="fas fa-dollar-sign me-2"></i>
                Gestión de Multas y Pagos
              </h5>
              <button type="button" class="btn-close" @click="multasDialog = false"></button>
            </div>
            <div class="modal-body">
              <!-- Resumen de multas -->
              <div class="alert alert-info mb-4">
                <h6 class="alert-heading">
                  <i class="fas fa-info-circle me-2"></i>
                  Resumen de Multas del Anuncio
                </h6>
                <div class="row">
                  <div class="col-md-6">
                    <strong>Total Adeudado:</strong> ${{ formatearMoneda(anuncio.total_multas) }}
                  </div>
                  <div class="col-md-6">
                    <strong>Anuncio:</strong> {{ anuncio.numero_anuncio }}
                  </div>
                </div>
              </div>

              <form @submit.prevent="gestionarMultas">
                <!-- Tipo de acción -->
                <div class="mb-4">
                  <label class="form-label fw-bold">Acción a Realizar</label>
                  <div class="row g-3">
                    <div class="col-md-4">
                      <div class="form-check">
                        <input
                          class="form-check-input"
                          type="radio"
                          name="accionMulta"
                          id="pagarMulta"
                          value="PAGAR"
                          v-model="formMultas.accion"
                        >
                        <label class="form-check-label" for="pagarMulta">
                          <i class="fas fa-credit-card text-success me-2"></i>
                          <strong>Registrar Pago</strong>
                        </label>
                      </div>
                    </div>
                    <div class="col-md-4">
                      <div class="form-check">
                        <input
                          class="form-check-input"
                          type="radio"
                          name="accionMulta"
                          id="cancelarMulta"
                          value="CANCELAR"
                          v-model="formMultas.accion"
                        >
                        <label class="form-check-label" for="cancelarMulta">
                          <i class="fas fa-times-circle text-danger me-2"></i>
                          <strong>Cancelar Multa</strong>
                        </label>
                      </div>
                    </div>
                    <div class="col-md-4">
                      <div class="form-check">
                        <input
                          class="form-check-input"
                          type="radio"
                          name="accionMulta"
                          id="condonarMulta"
                          value="CONDONAR"
                          v-model="formMultas.accion"
                        >
                        <label class="form-check-label" for="condonarMulta">
                          <i class="fas fa-hand-holding-heart text-info me-2"></i>
                          <strong>Condonar Multa</strong>
                        </label>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Campos para pago -->
                <div v-if="formMultas.accion === 'PAGAR'">
                  <div class="row g-3 mb-3">
                    <div class="col-md-6">
                      <label for="montoPagado" class="form-label fw-bold">Monto Pagado *</label>
                      <div class="input-group">
                        <span class="input-group-text">$</span>
                        <input
                          type="number"
                          class="form-control"
                          id="montoPagado"
                          v-model="formMultas.monto_pagado"
                          min="0"
                          step="0.01"
                          required
                        >
                        <span class="input-group-text">MXN</span>
                      </div>
                    </div>
                    <div class="col-md-6">
                      <label for="numeroRecibo" class="form-label fw-bold">Número de Recibo *</label>
                      <input
                        type="text"
                        class="form-control"
                        id="numeroRecibo"
                        v-model="formMultas.numero_recibo"
                        placeholder="Ej: REC-2024-001234"
                        required
                      >
                    </div>
                  </div>
                </div>
              </form>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" @click="multasDialog = false">
                <i class="fas fa-times me-2"></i>
                Cancelar
              </button>
              <button
                type="button"
                class="btn btn-warning"
                @click="gestionarMultas"
                :disabled="procesando || (formMultas.accion === 'PAGAR' && (!formMultas.monto_pagado || !formMultas.numero_recibo))"
              >
                <span v-if="procesando" class="spinner-border spinner-border-sm me-2"></span>
                <i v-else class="fas fa-dollar-sign me-2"></i>
                {{ procesando ? 'Procesando...' : 'Procesar ' + formMultas.accion.toLowerCase() }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Enhanced Modal Bloquear/Suspender -->
      <div v-if="bloquearDialog" class="modal fade show d-block" style="background-color: rgba(0,0,0,0.6);">
        <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-header bg-danger text-white">
              <h5 class="modal-title">
                <i class="fas fa-shield-alt me-2"></i>
                Sistema de Bloqueo y Suspensión de Anuncios
              </h5>
              <button type="button" class="btn-close btn-close-white" @click="bloquearDialog = false"></button>
            </div>
            <div class="modal-body">
              <form @submit.prevent="bloquearAnuncio">
                <!-- Tipo de acción -->
                <div class="mb-4">
                  <label class="form-label fw-bold">Tipo de Acción *</label>
                  <div class="row g-3">
                    <div class="col-md-6">
                      <div class="form-check">
                        <input
                          class="form-check-input"
                          type="radio"
                          name="tipoBloqueo"
                          id="bloqueoDefinitivo"
                          :value="1"
                          v-model="formBloqueo.tipo_bloqueo"
                        >
                        <label class="form-check-label" for="bloqueoDefinitivo">
                          <i class="fas fa-ban text-danger me-2"></i>
                          <strong>Bloqueo Definitivo</strong>
                          <div class="small text-muted">Suspende el anuncio hasta resolución manual</div>
                        </label>
                      </div>
                    </div>
                    <div class="col-md-6">
                      <div class="form-check">
                        <input
                          class="form-check-input"
                          type="radio"
                          name="tipoBloqueo"
                          id="suspensionTemporal"
                          :value="2"
                          v-model="formBloqueo.tipo_bloqueo"
                        >
                        <label class="form-check-label" for="suspensionTemporal">
                          <i class="fas fa-pause text-warning me-2"></i>
                          <strong>Suspensión Temporal</strong>
                          <div class="small text-muted">Suspende por período específico</div>
                        </label>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Días de suspensión -->
                <div v-if="formBloqueo.tipo_bloqueo === 2" class="mb-3">
                  <label for="diasSuspension" class="form-label fw-bold">Días de Suspensión *</label>
                  <input
                    type="number"
                    class="form-control"
                    id="diasSuspension"
                    v-model="formBloqueo.dias_suspension"
                    min="1"
                    max="365"
                    placeholder="Número de días"
                  >
                  <div class="form-text">La reactivación será automática al vencer el período</div>
                </div>

                <!-- Categoría del motivo -->
                <div class="mb-3">
                  <label for="categoriaMotivo" class="form-label fw-bold">Categoría de Infracción</label>
                  <select class="form-select" id="categoriaMotivo" v-model="formBloqueo.categoria">
                    <option value="">Seleccione una categoría</option>
                    <option value="UBICACION_INDEBIDA">Ubicación Indebida</option>
                    <option value="MEDIDAS_EXCEDIDAS">Medidas Excedidas</option>
                    <option value="SIN_PERMISO">Sin Permiso Vigente</option>
                    <option value="CONTENIDO_INAPROPIADO">Contenido Inapropiado</option>
                    <option value="ESTRUCTURA_PELIGROSA">Estructura Peligrosa</option>
                    <option value="NORMATIVA_MUNICIPAL">Violación Normativa Municipal</option>
                    <option value="OTRA">Otra (especificar en observaciones)</option>
                  </select>
                </div>

                <!-- Monto de multa -->
                <div class="mb-3">
                  <label for="montoMulta" class="form-label fw-bold">Monto de Multa (Opcional)</label>
                  <div class="input-group">
                    <span class="input-group-text">$</span>
                    <input
                      type="number"
                      class="form-control"
                      id="montoMulta"
                      v-model="formBloqueo.monto_multa"
                      min="0"
                      step="0.01"
                      placeholder="0.00"
                    >
                    <span class="input-group-text">MXN</span>
                  </div>
                  <div class="form-text">Si aplica multa, se generará automáticamente</div>
                </div>

                <!-- Motivo detallado -->
                <div class="mb-3">
                  <label for="motivoDetallado" class="form-label fw-bold">Motivo/Observaciones Detalladas *</label>
                  <textarea
                    id="motivoDetallado"
                    v-model="formBloqueo.motivo"
                    class="form-control"
                    rows="4"
                    placeholder="Describa detalladamente el motivo del bloqueo o suspensión..."
                    required
                    maxlength="500"
                  ></textarea>
                  <div class="form-text">{{ formBloqueo.motivo.length }}/500 caracteres</div>
                </div>
              </form>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" @click="bloquearDialog = false">
                <i class="fas fa-times me-2"></i>
                Cancelar
              </button>
              <button
                type="button"
                class="btn btn-danger"
                @click="bloquearAnuncio"
                :disabled="procesando || !formBloqueo.motivo.trim() || (formBloqueo.tipo_bloqueo === 2 && !formBloqueo.dias_suspension)"
              >
                <span v-if="procesando" class="spinner-border spinner-border-sm me-2"></span>
                <i v-else class="fas fa-shield-alt me-2"></i>
                {{ procesando ? 'Procesando...' : (formBloqueo.tipo_bloqueo === 1 ? 'Bloquear' : 'Suspender') }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Enhanced Modal Desbloquear -->
      <div v-if="desbloquearDialog" class="modal fade show d-block" style="background-color: rgba(0,0,0,0.6);">
        <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-header bg-success text-white">
              <h5 class="modal-title">
                <i class="fas fa-unlock me-2"></i>
                Sistema de Desbloqueo y Reactivación
              </h5>
              <button type="button" class="btn-close btn-close-white" @click="desbloquearDialog = false"></button>
            </div>
            <div class="modal-body">
              <!-- Información del estado actual -->
              <div class="alert alert-info mb-4">
                <h6 class="alert-heading">
                  <i class="fas fa-info-circle me-2"></i>
                  Estado Actual del Anuncio
                </h6>
                <div class="row">
                  <div class="col-md-6">
                    <strong>Estado:</strong> {{ getEstadoTexto(anuncio.bloqueado) }}
                  </div>
                  <div class="col-md-6" v-if="anuncio.fecha_bloqueo">
                    <strong>Bloqueado desde:</strong> {{ formatearFecha(anuncio.fecha_bloqueo) }}
                  </div>
                </div>
                <div v-if="anuncio.motivo_bloqueo" class="mt-2">
                  <strong>Motivo:</strong> {{ anuncio.motivo_bloqueo }}
                </div>
              </div>

              <form @submit.prevent="desbloquearAnuncio">
                <!-- Opciones de validación -->
                <div class="mb-4">
                  <label class="form-label fw-bold">Opciones de Validación</label>
                  <div class="row g-3">
                    <div class="col-md-6">
                      <div class="form-check">
                        <input
                          class="form-check-input"
                          type="checkbox"
                          id="validarMultas"
                          v-model="formDesbloqueo.validar_multas"
                        >
                        <label class="form-check-label" for="validarMultas">
                          <i class="fas fa-dollar-sign text-warning me-2"></i>
                          <strong>Validar Multas Pendientes</strong>
                          <div class="small text-muted">Verificar que no existan multas por pagar</div>
                        </label>
                      </div>
                    </div>
                    <div class="col-md-6">
                      <div class="form-check">
                        <input
                          class="form-check-input"
                          type="checkbox"
                          id="resolverInfracciones"
                          v-model="formDesbloqueo.resolver_infracciones"
                        >
                        <label class="form-check-label" for="resolverInfracciones">
                          <i class="fas fa-check-circle text-success me-2"></i>
                          <strong>Resolver Infracciones</strong>
                          <div class="small text-muted">Marcar infracciones como resueltas</div>
                        </label>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Alerta de multas pendientes -->
                <div v-if="tieneMultasPendientes && formDesbloqueo.validar_multas" class="alert alert-warning">
                  <h6 class="alert-heading">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    Multas Pendientes Detectadas
                  </h6>
                  <p class="mb-2">
                    Este anuncio tiene multas pendientes por un total de
                    <strong>${{ formatearMoneda(anuncio.total_multas) }}</strong>
                  </p>
                  <p class="mb-0">
                    Para continuar con el desbloqueo, las multas deben estar pagadas o
                    desactive la validación de multas.
                  </p>
                </div>

                <!-- Motivo del desbloqueo -->
                <div class="mb-3">
                  <label for="motivoDesbloqueoCompleto" class="form-label fw-bold">Motivo/Justificación del Desbloqueo *</label>
                  <textarea
                    id="motivoDesbloqueoCompleto"
                    v-model="formDesbloqueo.motivo"
                    class="form-control"
                    rows="4"
                    placeholder="Describa la justificación para el desbloqueo o reactivación..."
                    required
                    maxlength="500"
                  ></textarea>
                  <div class="form-text">{{ formDesbloqueo.motivo.length }}/500 caracteres</div>
                </div>
              </form>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" @click="desbloquearDialog = false">
                <i class="fas fa-times me-2"></i>
                Cancelar
              </button>
              <button
                type="button"
                class="btn btn-success"
                @click="desbloquearAnuncio"
                :disabled="procesando || !formDesbloqueo.motivo.trim()"
              >
                <span v-if="procesando" class="spinner-border spinner-border-sm me-2"></span>
                <i v-else class="fas fa-unlock me-2"></i>
                {{ procesando ? 'Procesando...' : 'Desbloquear y Reactivar' }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Enhanced Toast Notifications -->
      <div v-if="mensaje" class="position-fixed top-0 end-0 p-3" style="z-index: 1055">
        <div class="toast show" role="alert" :class="{
          'border-success': mensaje.tipo === 'success',
          'border-danger': mensaje.tipo === 'error',
          'border-warning': mensaje.tipo === 'warning',
          'border-info': mensaje.tipo === 'info'
        }">
          <div class="toast-header" :class="{
            'bg-success text-white': mensaje.tipo === 'success',
            'bg-danger text-white': mensaje.tipo === 'error',
            'bg-warning text-dark': mensaje.tipo === 'warning',
            'bg-info text-white': mensaje.tipo === 'info'
          }">
            <i class="fas me-2" :class="{
              'fa-check-circle': mensaje.tipo === 'success',
              'fa-exclamation-triangle': mensaje.tipo === 'error' || mensaje.tipo === 'warning',
              'fa-info-circle': mensaje.tipo === 'info'
            }"></i>
            <strong class="me-auto">{{
              mensaje.tipo === 'success' ? 'Éxito' :
              mensaje.tipo === 'error' ? 'Error' :
              mensaje.tipo === 'warning' ? 'Advertencia' : 'Información'
            }}</strong>
            <button type="button" class="btn-close" :class="{
              'btn-close-white': ['success', 'error', 'info'].includes(mensaje.tipo)
            }" @click="mensaje = null"></button>
          </div>
          <div class="toast-body">
            {{ mensaje.texto }}
          </div>
        </div>
      </div>

      <!-- Modal Reporte Estadísticas -->
      <div v-if="reporteDialog" class="modal fade show d-block" style="background-color: rgba(0,0,0,0.6);">
        <div class="modal-dialog modal-xl">
          <div class="modal-content">
            <div class="modal-header bg-info text-white">
              <h5 class="modal-title">
                <i class="fas fa-chart-bar me-2"></i>
                Reporte de Estadísticas de Bloqueos
              </h5>
              <button type="button" class="btn-close btn-close-white" @click="reporteDialog = false"></button>
            </div>
            <div class="modal-body">
              <div class="row">
                <div class="col-md-6">
                  <div class="card">
                    <div class="card-header">
                      <h6 class="mb-0">
                        <i class="fas fa-chart-pie me-2"></i>
                        Resumen General (Últimos 30 días)
                      </h6>
                    </div>
                    <div class="card-body">
                      <div class="row g-3">
                        <div class="col-6">
                          <div class="text-center p-3 bg-danger bg-opacity-10 rounded">
                            <i class="fas fa-ban fa-2x text-danger mb-2"></i>
                            <h4 class="mb-0 text-danger">{{ stats.total_bloqueos }}</h4>
                            <small class="text-muted">Bloqueos</small>
                          </div>
                        </div>
                        <div class="col-6">
                          <div class="text-center p-3 bg-warning bg-opacity-10 rounded">
                            <i class="fas fa-pause fa-2x text-warning mb-2"></i>
                            <h4 class="mb-0 text-warning">{{ stats.total_suspensiones }}</h4>
                            <small class="text-muted">Suspensiones</small>
                          </div>
                        </div>
                        <div class="col-6">
                          <div class="text-center p-3 bg-success bg-opacity-10 rounded">
                            <i class="fas fa-dollar-sign fa-2x text-success mb-2"></i>
                            <h4 class="mb-0 text-success">${{ formatearMoneda(stats.total_multas_pendientes) }}</h4>
                            <small class="text-muted">Multas Generadas</small>
                          </div>
                        </div>
                        <div class="col-6">
                          <div class="text-center p-3 bg-info bg-opacity-10 rounded">
                            <i class="fas fa-exclamation-triangle fa-2x text-info mb-2"></i>
                            <h4 class="mb-0 text-info">{{ stats.infracciones_pendientes }}</h4>
                            <small class="text-muted">Infracciones</small>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="card">
                    <div class="card-header">
                      <h6 class="mb-0">
                        <i class="fas fa-tools me-2"></i>
                        Herramientas de Administración
                      </h6>
                    </div>
                    <div class="card-body">
                      <div class="d-grid gap-2">
                        <button type="button" class="btn btn-outline-primary">
                          <i class="fas fa-file-export me-2"></i>
                          Exportar Reporte Completo
                        </button>
                        <button type="button" class="btn btn-outline-success">
                          <i class="fas fa-clock me-2"></i>
                          Programar Reactivaciones
                        </button>
                        <button type="button" class="btn btn-outline-warning">
                          <i class="fas fa-bell me-2"></i>
                          Configurar Notificaciones
                        </button>
                        <button type="button" class="btn btn-outline-info">
                          <i class="fas fa-chart-line me-2"></i>
                          Generar Gráficas
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" @click="reporteDialog = false">
                <i class="fas fa-times me-2"></i>
                Cerrar
              </button>
              <button type="button" class="btn btn-primary">
                <i class="fas fa-download me-2"></i>
                Descargar PDF
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'

export default {
  name: 'BloquearAnunciorm',
  setup() {
    const router = useRouter()
    const route = useRoute()

    // ============================================
    // ESTADO REACTIVO - COMPOSITION API
    // ============================================

    // Estados principales
    const numero_anuncio = ref('')
    const anuncio = ref(null)
    const bloqueos = ref([])
    const stats = ref({
      total_bloqueos: 0,
      total_suspensiones: 0,
      total_multas_pendientes: 0,
      infracciones_pendientes: 0
    })

    // Estados de UI
    const cargando = ref(false)
    const procesando = ref(false)
    const cargandoHistorial = ref(false)
    const cargandoStats = ref(false)

    // Modales y dialogs
    const bloquearDialog = ref(false)
    const desbloquearDialog = ref(false)
    const multasDialog = ref(false)
    const reporteDialog = ref(false)

    // Formularios reactivos
    const formBloqueo = reactive({
      tipo_bloqueo: 1, // 1=Bloqueo, 2=Suspensión
      motivo: '',
      categoria: '',
      monto_multa: 0,
      dias_suspension: 0
    })

    const formDesbloqueo = reactive({
      motivo: '',
      validar_multas: true,
      resolver_infracciones: true
    })

    const formMultas = reactive({
      accion: 'PAGAR', // PAGAR, CANCELAR, CONDONAR
      monto_pagado: 0,
      numero_recibo: ''
    })

    // Errores y validaciones
    const errors = ref({})
    const mensaje = ref(null)

    // Configuración API
    const apiConfig = {
      url: 'http://localhost:8000/api/generic',
      tenant: 'guadalajara',
      base: 'padron_licencias'
    }
    // ============================================
    // MÉTODOS PRINCIPALES - COMPOSITION API
    // ============================================

    /**
     * Busca un anuncio por número con información completa
     */
    const buscarAnuncio = async () => {
      if (!numero_anuncio.value?.trim()) {
        errors.value.numero_anuncio = 'Debe ingresar un número de anuncio'
        return
      }

      // Limpiar errores previos
      errors.value = {}
      cargando.value = true
      anuncio.value = null
      bloqueos.value = []
      mensaje.value = null

      try {
        // Request usando el nuevo SP completo
        const eRequest = {
          Operacion: 'buscar_anuncio_completo',
          Base: apiConfig.base,
          Parametros: [
            { nombre: 'numero_anuncio', valor: parseInt(numero_anuncio.value), tipo: 'integer' }
          ],
          Tenant: apiConfig.tenant
        }

        console.log('🔍 Buscando anuncio:', numero_anuncio.value)

        const response = await fetch(apiConfig.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        const data = await response.json()

        if (data.eResponse?.success && data.eResponse?.data?.result?.length > 0) {
          anuncio.value = data.eResponse.data.result[0]
          mostrarMensaje('success', `Anuncio ${numero_anuncio.value} encontrado exitosamente`)

          // Cargar historial de bloqueos
          await cargarHistorialBloqueos()

          // Actualizar estadísticas
          await cargarEstadisticas()

        } else {
          errors.value.numero_anuncio = 'Anuncio no encontrado'
          mostrarMensaje('error', `No se encontró el anuncio ${numero_anuncio.value}`)
        }

      } catch (error) {
        console.error('❌ Error buscando anuncio:', error)
        mostrarMensaje('error', 'Error de conexión al buscar el anuncio')
      } finally {
        cargando.value = false
      }
    }

    /**
     * Carga el historial detallado de bloqueos del anuncio
     */
    const cargarHistorialBloqueos = async () => {
      if (!anuncio.value?.id_anuncio) return

      cargandoHistorial.value = true

      try {
        const eRequest = {
          Operacion: 'consultar_historial_bloqueos_detallado',
          Base: apiConfig.base,
          Parametros: [
            { nombre: 'id_anuncio', valor: anuncio.value.id_anuncio, tipo: 'integer' }
          ],
          Tenant: apiConfig.tenant
        }

        const response = await fetch(apiConfig.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        const data = await response.json()

        if (data.eResponse?.success) {
          bloqueos.value = data.eResponse.data.result || []
          console.log('📊 Historial cargado:', bloqueos.value.length, 'registros')
        } else {
          bloqueos.value = []
        }

      } catch (error) {
        console.error('❌ Error cargando historial:', error)
        bloqueos.value = []
      } finally {
        cargandoHistorial.value = false
      }
    }

    /**
     * Carga estadísticas generales del sistema
     */
    const cargarEstadisticas = async () => {
      cargandoStats.value = true

      try {
        const eRequest = {
          Operacion: 'reporte_bloqueos_estadisticas',
          Base: apiConfig.base,
          Parametros: [
            { nombre: 'fecha_inicio', valor: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0], tipo: 'date' },
            { nombre: 'fecha_fin', valor: new Date().toISOString().split('T')[0], tipo: 'date' },
            { nombre: 'incluir_detalle', valor: 1, tipo: 'integer' }
          ],
          Tenant: apiConfig.tenant
        }

        const response = await fetch(apiConfig.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        const data = await response.json()

        if (data.eResponse?.success && data.eResponse?.data?.result?.length > 0) {
          const result = data.eResponse.data.result[0]
          stats.value = {
            total_bloqueos: result.total_bloqueos || 0,
            total_suspensiones: result.total_suspensiones || 0,
            total_multas_pendientes: result.total_multas_generadas || 0,
            infracciones_pendientes: result.infracciones_pendientes || 0
          }
        }

      } catch (error) {
        console.error('❌ Error cargando estadísticas:', error)
      } finally {
        cargandoStats.value = false
      }
    }

    /**
     * Abre el modal de bloqueo/suspensión
     */
    const abrirModalBloquear = () => {
      // Reset form
      Object.assign(formBloqueo, {
        tipo_bloqueo: 1,
        motivo: '',
        categoria: '',
        monto_multa: 0,
        dias_suspension: 0
      })
      bloquearDialog.value = true
    }

    /**
     * Abre el modal de desbloqueo
     */
    const abrirModalDesbloquear = () => {
      // Reset form
      Object.assign(formDesbloqueo, {
        motivo: '',
        validar_multas: true,
        resolver_infracciones: true
      })
      desbloquearDialog.value = true
    }

    /**
     * Abre el modal de gestión de multas
     */
    const abrirModalMultas = () => {
      // Reset form
      Object.assign(formMultas, {
        accion: 'PAGAR',
        monto_pagado: 0,
        numero_recibo: ''
      })
      multasDialog.value = true
    }

    /**
     * Ejecuta el bloqueo/suspensión completo del anuncio
     */
    const bloquearAnuncio = async () => {
      if (!anuncio.value || anuncio.value.bloqueado > 0) {
        mostrarMensaje('error', 'El anuncio ya está bloqueado o suspendido')
        return
      }

      if (!formBloqueo.motivo.trim()) {
        mostrarMensaje('error', 'Debe especificar el motivo del bloqueo')
        return
      }

      procesando.value = true

      try {
        const eRequest = {
          Operacion: 'bloquear_anuncio_completo',
          Base: apiConfig.base,
          Parametros: [
            { nombre: 'p_id_anuncio', valor: anuncio.value.id_anuncio, tipo: 'integer' },
            { nombre: 'p_tipo_bloqueo', valor: formBloqueo.tipo_bloqueo, tipo: 'integer' },
            { nombre: 'observa', valor: formBloqueo.motivo, tipo: 'string' },
            { nombre: 'motivo_categoria', valor: formBloqueo.categoria || 'BLOQUEO_GENERAL', tipo: 'string' },
            { nombre: 'monto_multa', valor: formBloqueo.monto_multa || 0, tipo: 'decimal' },
            { nombre: 'dias_suspension', valor: formBloqueo.dias_suspension || 0, tipo: 'integer' },
            { nombre: 'usuario', valor: obtenerUsuario(), tipo: 'string' }
          ],
          Tenant: apiConfig.tenant
        }

        console.log('🚫 Ejecutando bloqueo:', formBloqueo)

        const response = await fetch(apiConfig.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        const data = await response.json()

        bloquearDialog.value = false

        if (data.eResponse?.success && data.eResponse?.data?.result?.[0]?.success) {
          const result = data.eResponse.data.result[0]
          mostrarMensaje('success', result.message || 'Anuncio bloqueado exitosamente')

          // Recargar información completa
          await buscarAnuncio()

        } else {
          const errorMsg = data.eResponse?.data?.result?.[0]?.message || 'Error al procesar el bloqueo'
          mostrarMensaje('error', errorMsg)
        }

      } catch (error) {
        console.error('❌ Error en bloqueo:', error)
        mostrarMensaje('error', 'Error de conexión al procesar el bloqueo')
        bloquearDialog.value = false
      } finally {
        procesando.value = false
      }
    }

    /**
     * Ejecuta el desbloqueo completo del anuncio
     */
    const desbloquearAnuncio = async () => {
      if (!anuncio.value || anuncio.value.bloqueado === 0) {
        mostrarMensaje('error', 'El anuncio no está bloqueado')
        return
      }

      if (!formDesbloqueo.motivo.trim()) {
        mostrarMensaje('error', 'Debe especificar el motivo del desbloqueo')
        return
      }

      procesando.value = true

      try {
        const eRequest = {
          Operacion: 'desbloquear_anuncio_completo',
          Base: apiConfig.base,
          Parametros: [
            { nombre: 'p_id_anuncio', valor: anuncio.value.id_anuncio, tipo: 'integer' },
            { nombre: 'observa', valor: formDesbloqueo.motivo, tipo: 'string' },
            { nombre: 'usuario', valor: obtenerUsuario(), tipo: 'string' },
            { nombre: 'validar_multas', valor: formDesbloqueo.validar_multas ? 1 : 0, tipo: 'integer' },
            { nombre: 'resolver_infracciones', valor: formDesbloqueo.resolver_infracciones ? 1 : 0, tipo: 'integer' }
          ],
          Tenant: apiConfig.tenant
        }

        console.log('✅ Ejecutando desbloqueo:', formDesbloqueo)

        const response = await fetch(apiConfig.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        const data = await response.json()

        desbloquearDialog.value = false

        if (data.eResponse?.success && data.eResponse?.data?.result?.[0]?.success) {
          const result = data.eResponse.data.result[0]
          mostrarMensaje('success', result.message || 'Anuncio desbloqueado exitosamente')

          // Recargar información completa
          await buscarAnuncio()

        } else {
          const errorMsg = data.eResponse?.data?.result?.[0]?.message || 'Error al procesar el desbloqueo'
          mostrarMensaje('error', errorMsg)
        }

      } catch (error) {
        console.error('❌ Error en desbloqueo:', error)
        mostrarMensaje('error', 'Error de conexión al procesar el desbloqueo')
        desbloquearDialog.value = false
      } finally {
        procesando.value = false
      }
    }

    /**
     * Gestiona multas del anuncio (pago, cancelación, condonación)
     */
    const gestionarMultas = async () => {
      if (!anuncio.value) return

      if (formMultas.accion === 'PAGAR' && (!formMultas.monto_pagado || !formMultas.numero_recibo)) {
        mostrarMensaje('error', 'Para pagar debe especificar monto y número de recibo')
        return
      }

      procesando.value = true

      try {
        const eRequest = {
          Operacion: 'gestionar_multas_anuncio',
          Base: apiConfig.base,
          Parametros: [
            { nombre: 'p_id_anuncio', valor: anuncio.value.id_anuncio, tipo: 'integer' },
            { nombre: 'accion', valor: formMultas.accion, tipo: 'string' },
            { nombre: 'monto_pagado', valor: formMultas.monto_pagado || 0, tipo: 'decimal' },
            { nombre: 'numero_recibo', valor: formMultas.numero_recibo || '', tipo: 'string' },
            { nombre: 'usuario', valor: obtenerUsuario(), tipo: 'string' }
          ],
          Tenant: apiConfig.tenant
        }

        const response = await fetch(apiConfig.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        const data = await response.json()

        multasDialog.value = false

        if (data.eResponse?.success && data.eResponse?.data?.result?.[0]?.success) {
          const result = data.eResponse.data.result[0]
          mostrarMensaje('success', result.message || 'Multas procesadas exitosamente')
          await buscarAnuncio()
        } else {
          const errorMsg = data.eResponse?.data?.result?.[0]?.message || 'Error al procesar multas'
          mostrarMensaje('error', errorMsg)
        }

      } catch (error) {
        console.error('❌ Error gestionando multas:', error)
        mostrarMensaje('error', 'Error de conexión al procesar multas')
      } finally {
        procesando.value = false
      }
    }

    // ============================================
    // FUNCIONES AUXILIARES
    // ============================================

    /**
     * Formatea fechas para mostrar
     */
    const formatearFecha = (fecha) => {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleDateString('es-MX', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    /**
     * Formatea cantidades monetarias
     */
    const formatearMoneda = (cantidad) => {
      if (!cantidad || cantidad === 0) return '0.00'
      return new Intl.NumberFormat('es-MX', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      }).format(cantidad)
    }

    /**
     * Obtiene el texto del estado según el código
     */
    const getEstadoTexto = (codigo) => {
      switch (codigo) {
        case 0: return 'ACTIVO'
        case 1: return 'BLOQUEADO'
        case 2: return 'SUSPENDIDO'
        default: return 'DESCONOCIDO'
      }
    }

    /**
     * Muestra mensajes al usuario
     */
    const mostrarMensaje = (tipo, texto) => {
      mensaje.value = { tipo, texto }
      setTimeout(() => {
        mensaje.value = null
      }, 5000)
    }

    /**
     * Obtiene el usuario actual
     */
    const obtenerUsuario = () => {
      return (window.user?.username) || 'admin'
    }

    /**
     * Limpia la búsqueda actual
     */
    const limpiarBusqueda = () => {
      numero_anuncio.value = ''
      anuncio.value = null
      bloqueos.value = []
      errors.value = {}
      mensaje.value = null
    }
    /**
     * Reactivar suspensiones vencidas automáticamente
     */
    const reactivarSuspensionesVencidas = async () => {
      try {
        const eRequest = {
          Operacion: 'suspension_automatica_vencida',
          Base: apiConfig.base,
          Parametros: [
            { nombre: 'usuario_sistema', valor: obtenerUsuario(), tipo: 'string' }
          ],
          Tenant: apiConfig.tenant
        }

        const response = await fetch(apiConfig.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        const data = await response.json()

        if (data.eResponse?.success) {
          const result = data.eResponse.data.result[0]
          mostrarMensaje('success', result.message || 'Proceso de reactivación completado')
          await cargarEstadisticas()
        }

      } catch (error) {
        console.error('❌ Error en reactivación automática:', error)
        mostrarMensaje('error', 'Error al ejecutar reactivación automática')
      }
    }

    /**
     * Enviar notificaciones programadas
     */
    const enviarNotificaciones = async () => {
      try {
        const eRequest = {
          Operacion: 'sistema_notificaciones_bloqueos',
          Base: apiConfig.base,
          Parametros: [
            { nombre: 'tipo_notificacion', valor: 'VENCIMIENTO', tipo: 'string' },
            { nombre: 'dias_anticipacion', valor: 7, tipo: 'integer' }
          ],
          Tenant: apiConfig.tenant
        }

        const response = await fetch(apiConfig.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        const data = await response.json()

        if (data.eResponse?.success) {
          const result = data.eResponse.data.result[0]
          mostrarMensaje('success', result.message || 'Notificaciones enviadas')
        }

      } catch (error) {
        console.error('❌ Error enviando notificaciones:', error)
        mostrarMensaje('error', 'Error al enviar notificaciones')
      }
    }

    /**
     * Genera reporte de estadísticas
     */
    const generarReporte = () => {
      reporteDialog.value = true
    }

    // ============================================
    // COMPUTED PROPERTIES
    // ============================================

    const puedeBloquear = computed(() => {
      return anuncio.value && anuncio.value.bloqueado === 0
    })

    const puedeDesbloquear = computed(() => {
      return anuncio.value && anuncio.value.bloqueado > 0
    })

    const tieneMultasPendientes = computed(() => {
      return anuncio.value && anuncio.value.tiene_multas_pendientes === 1
    })

    const tieneInfracciones = computed(() => {
      return anuncio.value && anuncio.value.tiene_infracciones === 1
    })

    // ============================================
    // LIFECYCLE HOOKS
    // ============================================

    onMounted(async () => {
      console.log('🚀 BloquearAnunciorm - Sistema Completo Cargado')

      // Cargar estadísticas iniciales
      await cargarEstadisticas()

      // Si hay parámetros en la URL, buscar automáticamente
      if (route.query.anuncio) {
        numero_anuncio.value = route.query.anuncio
        await buscarAnuncio()
      }
    })

    // ============================================
    // RETURN PARA COMPOSITION API
    // ============================================

    return {
      // Estados reactivos
      numero_anuncio,
      anuncio,
      bloqueos,
      stats,
      cargando,
      procesando,
      cargandoHistorial,
      cargandoStats,

      // Modales
      bloquearDialog,
      desbloquearDialog,
      multasDialog,
      reporteDialog,

      // Formularios
      formBloqueo,
      formDesbloqueo,
      formMultas,

      // Estados de validación
      errors,
      mensaje,

      // Métodos principales
      buscarAnuncio,
      cargarHistorialBloqueos,
      cargarEstadisticas,
      bloquearAnuncio,
      desbloquearAnuncio,
      gestionarMultas,

      // Métodos de UI
      abrirModalBloquear,
      abrirModalDesbloquear,
      abrirModalMultas,
      limpiarBusqueda,

      // Métodos auxiliares
      formatearFecha,
      formatearMoneda,
      getEstadoTexto,
      mostrarMensaje,
      obtenerUsuario,

      // Métodos avanzados
      reactivarSuspensionesVencidas,
      enviarNotificaciones,
      generarReporte,

      // Computed
      puedeBloquear,
      puedeDesbloquear,
      tieneMultasPendientes,
      tieneInfracciones
    }
  }
}
</script>

<style scoped>
/* ============================================
   ESTILOS ESPECÍFICOS DEL COMPONENTE
   ============================================ */

.municipal-header {
  background: var(--gradient-guadalajara);
  color: white;
  border-radius: 0;
}

.municipal-controls {
  background-color: var(--slate-50);
}

.btn-municipal-white {
  background-color: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  color: white;
  transition: var(--transition-normal);
}

.btn-municipal-white:hover {
  background-color: rgba(255, 255, 255, 0.3);
  border-color: rgba(255, 255, 255, 0.5);
  color: white;
  transform: translateY(-1px);
}

.btn-municipal-white.active {
  background-color: rgba(255, 255, 255, 0.4);
  border-color: rgba(255, 255, 255, 0.6);
}

.card {
  border: none;
  box-shadow: var(--shadow-sm);
  border-radius: var(--radius-lg);
  transition: var(--transition-normal);
}

.card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-1px);
}

.card-header {
  border-radius: var(--radius-lg) var(--radius-lg) 0 0 !important;
  border-bottom: none;
  font-weight: var(--font-weight-bold);
}

.form-control, .form-select {
  border-radius: var(--radius-md);
  border: 1px solid var(--slate-300);
  transition: var(--transition-fast);
}

.form-control:focus, .form-select:focus {
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
}

.btn {
  border-radius: var(--radius-md);
  font-weight: var(--font-weight-bold);
  transition: var(--transition-normal);
}

.btn-primary {
  background-color: var(--municipal-primary);
  border-color: var(--municipal-primary);
}

.btn-primary:hover {
  background-color: var(--municipal-secondary);
  border-color: var(--municipal-secondary);
  transform: translateY(-1px);
}

.table {
  border-radius: var(--radius-md);
  overflow: hidden;
}

.table th {
  background-color: var(--slate-100);
  border-bottom: 2px solid var(--slate-200);
  font-weight: var(--font-weight-bold);
  color: var(--slate-700);
}

.badge {
  font-size: 0.75rem;
  padding: 0.375rem 0.75rem;
  border-radius: var(--radius-full);
}

.modal-content {
  border: none;
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-xl);
}

.modal-header {
  border-radius: var(--radius-xl) var(--radius-xl) 0 0;
  border-bottom: 1px solid var(--slate-200);
}

.spinner-border-sm {
  width: 1rem;
  height: 1rem;
}

.text-truncate {
  max-width: 200px;
}

.bg-light {
  background-color: var(--slate-50) !important;
}

/* Animaciones */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.card {
  animation: fadeIn 0.3s ease-out;
}

/* Estados de validación */
.is-invalid {
  border-color: var(--municipal-danger) !important;
}

.invalid-feedback {
  color: var(--municipal-danger);
  font-size: 0.875rem;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .municipal-header h1 {
    font-size: 1.25rem;
  }

  .municipal-header p {
    font-size: 0.875rem;
  }

  .btn-group .btn {
    padding: 0.5rem;
  }

  .table-responsive {
    font-size: 0.875rem;
  }
}

/* Estados de carga */
.loading-overlay {
  position: relative;
}

.loading-overlay::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(255, 255, 255, 0.8);
  z-index: 1;
}

.loading-overlay .spinner-border {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 2;
}
</style>