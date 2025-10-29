<template>
  <div class="container-fluid p-0 h-100">
    <!-- Municipal Header -->
    <div class="municipal-header p-3 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1">
            <i class="fas fa-ban me-2 text-municipal-warning"></i>
            Sistema de Bloqueo de Trámites
          </h1>
          <p class="mb-0 opacity-75">
            Control integral de suspensiones, bloqueos y reactivaciones de trámites municipales
          </p>
        </div>
        <div class="text-white-50">
          <ol class="breadcrumb mb-0 bg-transparent p-0">
            <li class="breadcrumb-item">
              <a href="#" class="text-white-50" @click="$emit('navigate', 'dashboard')">
                <i class="fas fa-home me-1"></i>Inicio
              </a>
            </li>
            <li class="breadcrumb-item">
              <a href="#" class="text-white-50" @click="$emit('navigate', 'licencias')">
                <i class="fas fa-file-contract me-1"></i>Licencias
              </a>
            </li>
            <li class="breadcrumb-item text-white active">
              <i class="fas fa-ban me-1"></i>Gestión de Bloqueos
            </li>
          </ol>
        </div>
      </div>
    </div>

    <!-- Controls -->
    <div class="municipal-controls border-bottom p-3">
      <div class="d-flex justify-content-between align-items-center">
        <div class="btn-group" role="group">
          <button type="button" class="btn btn-municipal-white" @click="$emit('navigate', 'dashboard')" title="Ir al Dashboard">
            <i class="fas fa-home"></i>
          </button>
          <button type="button" class="btn btn-municipal-white" @click="$emit('navigate', 'licencias')" title="Módulo de Licencias">
            <i class="fas fa-file-contract"></i>
          </button>
          <button type="button" class="btn btn-municipal-white active" title="Gestión de Bloqueos">
            <i class="fas fa-ban"></i>
          </button>
          <button type="button" class="btn btn-municipal-white" @click="generarReporte" title="Generar Reporte">
            <i class="fas fa-chart-bar"></i>
          </button>
        </div>
        <div class="d-flex gap-2">
          <span class="badge bg-info">
            <i class="fas fa-clock me-1"></i>
            {{ horaActual }}
          </span>
          <span class="badge bg-secondary">
            <i class="fas fa-user me-1"></i>
            {{ usuarioActual }}
          </span>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="p-4">
      <!-- Estadísticas Rápidas -->
      <div class="row mb-4" v-if="estadisticas">
        <div class="col-md-3">
          <div class="card bg-gradient-info text-white">
            <div class="card-body">
              <div class="d-flex justify-content-between">
                <div>
                  <h6 class="card-title">Trámites Bloqueados Hoy</h6>
                  <h3 class="mb-0">{{ estadisticas.bloqueados_hoy || 0 }}</h3>
                </div>
                <i class="fas fa-ban fa-2x opacity-50"></i>
              </div>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="card bg-gradient-success text-white">
            <div class="card-body">
              <div class="d-flex justify-content-between">
                <div>
                  <h6 class="card-title">Desbloqueados Hoy</h6>
                  <h3 class="mb-0">{{ estadisticas.desbloqueados_hoy || 0 }}</h3>
                </div>
                <i class="fas fa-unlock fa-2x opacity-50"></i>
              </div>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="card bg-gradient-warning text-white">
            <div class="card-body">
              <div class="d-flex justify-content-between">
                <div>
                  <h6 class="card-title">Bloqueos Pendientes</h6>
                  <h3 class="mb-0">{{ estadisticas.pendientes || 0 }}</h3>
                </div>
                <i class="fas fa-hourglass-half fa-2x opacity-50"></i>
              </div>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="card bg-gradient-primary text-white">
            <div class="card-body">
              <div class="d-flex justify-content-between">
                <div>
                  <h6 class="card-title">Total en Sistema</h6>
                  <h3 class="mb-0">{{ estadisticas.total_sistema || 0 }}</h3>
                </div>
                <i class="fas fa-database fa-2x opacity-50"></i>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Formulario de búsqueda mejorado -->
      <div class="card mb-4 shadow-sm">
        <div class="card-header bg-gradient-municipal text-white">
          <h5 class="mb-0">
            <i class="fas fa-search me-2"></i>
            Localizar Trámite para Gestión de Bloqueos
          </h5>
        </div>
        <div class="card-body">
          <form @submit.prevent="buscarTramite">
            <div class="row g-3 align-items-end">
              <div class="col-md-4">
                <label for="numeroTramite" class="form-label fw-bold">
                  <i class="fas fa-hashtag me-1"></i>
                  Número de Trámite *
                </label>
                <div class="input-group">
                  <span class="input-group-text">
                    <i class="fas fa-file-alt"></i>
                  </span>
                  <input
                    type="number"
                    class="form-control"
                    id="numeroTramite"
                    v-model="numeroTramite"
                    placeholder="Ej: 12345"
                    @keyup.enter="buscarTramite"
                    :class="{ 'is-invalid': errors.numeroTramite }"
                    min="1"
                    required
                  >
                  <div class="invalid-feedback" v-if="errors.numeroTramite">
                    {{ errors.numeroTramite }}
                  </div>
                </div>
              </div>
              <div class="col-md-3">
                <label for="tipoConsulta" class="form-label fw-bold">
                  <i class="fas fa-filter me-1"></i>
                  Tipo de Consulta
                </label>
                <select class="form-select" id="tipoConsulta" v-model="tipoConsulta">
                  <option value="completa">Consulta Completa</option>
                  <option value="basica">Solo Estado</option>
                  <option value="historial">Con Historial</option>
                </select>
              </div>
              <div class="col-md-3">
                <button
                  type="submit"
                  class="btn btn-municipal-primary w-100"
                  :disabled="buscando || !numeroTramite"
                >
                  <i class="fas fa-spinner fa-spin me-2" v-if="buscando"></i>
                  <i class="fas fa-search me-2" v-else></i>
                  {{ buscando ? 'Localizando...' : 'Buscar Trámite' }}
                </button>
              </div>
              <div class="col-md-2">
                <button
                  type="button"
                  class="btn btn-outline-secondary w-100"
                  @click="limpiarBusqueda"
                  :disabled="buscando"
                >
                  <i class="fas fa-eraser me-2"></i>
                  Limpiar
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Información del trámite encontrado -->
      <div v-if="tramite" class="card mb-4 shadow-sm">
        <div class="card-header bg-gradient-info text-white d-flex justify-content-between align-items-center">
          <h5 class="mb-0">
            <i class="fas fa-file-alt me-2"></i>
            Información Detallada del Trámite
          </h5>
          <div class="d-flex gap-2">
            <span class="badge bg-light text-dark">
              <i class="fas fa-calendar me-1"></i>
              {{ formatFecha(tramite.fecha_ultima_modificacion) }}
            </span>
            <span :class="getEstadoBadgeClass()">
              {{ getEstadoTexto() }}
            </span>
          </div>
        </div>
        <div class="card-body">
          <div class="row g-4">
            <!-- Columna Izquierda: Datos del Trámite -->
            <div class="col-md-6">
              <h6 class="text-municipal-primary border-bottom pb-2 mb-3">
                <i class="fas fa-info-circle me-2"></i>
                Datos del Trámite
              </h6>
              <div class="info-grid">
                <div class="info-item">
                  <label class="fw-bold text-muted">ID Trámite:</label>
                  <span class="text-primary fw-bold">#{{ tramite.id_tramite }}</span>
                </div>
                <div class="info-item">
                  <label class="fw-bold text-muted">Folio:</label>
                  <span>{{ tramite.folio || 'Sin folio asignado' }}</span>
                </div>
                <div class="info-item">
                  <label class="fw-bold text-muted">Tipo de Trámite:</label>
                  <span>{{ tramite.tipo_tramite || 'No especificado' }}</span>
                </div>
                <div class="info-item">
                  <label class="fw-bold text-muted">Giro Comercial:</label>
                  <span>{{ tramite.giro || 'Sin giro especificado' }}</span>
                </div>
                <div class="info-item">
                  <label class="fw-bold text-muted">Actividad:</label>
                  <span>{{ tramite.actividad || 'No especificada' }}</span>
                </div>
                <div class="info-item">
                  <label class="fw-bold text-muted">Capturista:</label>
                  <span>{{ tramite.capturista_actual || 'No registrado' }}</span>
                </div>
              </div>
            </div>

            <!-- Columna Derecha: Datos del Solicitante y Ubicación -->
            <div class="col-md-6">
              <h6 class="text-municipal-primary border-bottom pb-2 mb-3">
                <i class="fas fa-user me-2"></i>
                Solicitante y Ubicación
              </h6>
              <div class="info-grid">
                <div class="info-item">
                  <label class="fw-bold text-muted">Propietario/Solicitante:</label>
                  <span>
                    {{ formatNombreCompleto(tramite.primer_ap, tramite.segundo_ap, tramite.propietario) }}
                  </span>
                </div>
                <div class="info-item">
                  <label class="fw-bold text-muted">Ubicación del Predio:</label>
                  <span>
                    {{ formatDireccion(tramite) }}
                  </span>
                </div>
                <div class="info-item">
                  <label class="fw-bold text-muted">Estado Actual:</label>
                  <span :class="getEstadoClass()">
                    <i class="fas" :class="getEstadoIcon()" ></i>
                    {{ getEstadoTexto() }}
                  </span>
                </div>
                <div class="info-item" v-if="tramite.bloqueado > 0">
                  <label class="fw-bold text-muted">Tipo de Bloqueo:</label>
                  <span class="badge bg-warning text-dark">
                    {{ getTipoBloqueoTexto(tramite.bloqueado) }}
                  </span>
                </div>
                <div class="info-item" v-if="estadisticasTramite">
                  <label class="fw-bold text-muted">Días desde último movimiento:</label>
                  <span class="badge bg-secondary">
                    {{ estadisticasTramite.dias_desde_ultimo_bloqueo }} días
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Alertas y Notificaciones -->
          <div class="row mt-4" v-if="tramite.bloqueado > 0">
            <div class="col-12">
              <div class="alert alert-warning d-flex align-items-center" role="alert">
                <i class="fas fa-exclamation-triangle me-3 fa-lg"></i>
                <div>
                  <h6 class="alert-heading mb-1">¡Trámite Bloqueado!</h6>
                  <p class="mb-0">
                    Este trámite se encuentra suspendido por: <strong>{{ getTipoBloqueoTexto(tramite.bloqueado) }}</strong>
                    <br><small class="text-muted">Se requiere resolución antes de continuar con el proceso.</small>
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Panel de Acciones Mejorado -->
      <div v-if="tramite" class="card mb-4 shadow-sm">
        <div class="card-header bg-gradient-secondary text-white">
          <h5 class="mb-0">
            <i class="fas fa-cogs me-2"></i>
            Centro de Control de Bloqueos
          </h5>
        </div>
        <div class="card-body">
          <div class="row g-3">
            <!-- Acciones Principales -->
            <div class="col-md-4">
              <div class="action-card h-100">
                <h6 class="text-warning mb-3">
                  <i class="fas fa-ban me-2"></i>
                  Suspender Trámite
                </h6>
                <p class="text-muted small mb-3">
                  Bloquea temporalmente el trámite por documentación faltante, observaciones técnicas o conflictos.
                </p>
                <button
                  type="button"
                  class="btn btn-warning w-100"
                  :disabled="tramite.bloqueado > 0 || procesando"
                  @click="abrirModalBloqueo"
                >
                  <i class="fas fa-lock me-2"></i>
                  {{ tramite.bloqueado > 0 ? 'Ya Bloqueado' : 'Bloquear Trámite' }}
                </button>
              </div>
            </div>

            <div class="col-md-4">
              <div class="action-card h-100">
                <h6 class="text-success mb-3">
                  <i class="fas fa-unlock me-2"></i>
                  Reactivar Trámite
                </h6>
                <p class="text-muted small mb-3">
                  Levanta la suspensión y permite continuar con el proceso del trámite.
                </p>
                <button
                  type="button"
                  class="btn btn-success w-100"
                  :disabled="tramite.bloqueado === 0 || procesando"
                  @click="abrirModalDesbloqueo"
                >
                  <i class="fas fa-unlock me-2"></i>
                  {{ tramite.bloqueado === 0 ? 'No Bloqueado' : 'Desbloquear Trámite' }}
                </button>
              </div>
            </div>

            <div class="col-md-4">
              <div class="action-card h-100">
                <h6 class="text-info mb-3">
                  <i class="fas fa-chart-line me-2"></i>
                  Consultar Estadísticas
                </h6>
                <p class="text-muted small mb-3">
                  Genera reporte detallado del historial de bloqueos y movimientos.
                </p>
                <button
                  type="button"
                  class="btn btn-info w-100"
                  @click="cargarEstadisticasTramite"
                  :disabled="cargandoEstadisticas"
                >
                  <i class="fas fa-spinner fa-spin me-2" v-if="cargandoEstadisticas"></i>
                  <i class="fas fa-chart-bar me-2" v-else></i>
                  {{ cargandoEstadisticas ? 'Cargando...' : 'Ver Estadísticas' }}
                </button>
              </div>
            </div>
          </div>

          <!-- Información Adicional -->
          <div class="row mt-3" v-if="bloqueosActivos.length > 0">
            <div class="col-12">
              <div class="alert alert-info">
                <h6 class="alert-heading">
                  <i class="fas fa-info-circle me-2"></i>
                  Bloqueos Activos Detectados
                </h6>
                <div class="d-flex flex-wrap gap-2">
                  <span
                    v-for="bloqueo in bloqueosActivos"
                    :key="bloqueo.id"
                    class="badge bg-warning text-dark"
                  >
                    {{ bloqueo.descripcion }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Modal de bloqueo mejorado -->
      <div v-if="showModalBloqueo" class="modal fade show d-block" tabindex="-1">
        <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-header bg-gradient-warning text-dark">
              <h5 class="modal-title">
                <i class="fas fa-ban me-2"></i>
                Suspender Trámite - Control de Bloqueos
              </h5>
              <button type="button" class="btn-close" @click="cerrarModalBloqueo"></button>
            </div>
            <div class="modal-body">
              <!-- Información del trámite -->
              <div class="alert alert-info mb-4">
                <div class="d-flex align-items-center">
                  <i class="fas fa-info-circle me-3 fa-lg"></i>
                  <div>
                    <h6 class="alert-heading mb-1">Trámite a Bloquear</h6>
                    <p class="mb-0">
                      <strong>ID:</strong> {{ tramite.id_tramite }} |
                      <strong>Folio:</strong> {{ tramite.folio || 'N/A' }} |
                      <strong>Propietario:</strong> {{ formatNombreCompleto(tramite.primer_ap, tramite.segundo_ap, tramite.propietario) }}
                    </p>
                  </div>
                </div>
              </div>

              <form @submit.prevent="confirmarBloqueo">
                <div class="row g-3">
                  <div class="col-md-6">
                    <label for="tipoBloqueo" class="form-label fw-bold">
                      <i class="fas fa-exclamation-triangle me-1"></i>
                      Tipo de Bloqueo *
                    </label>
                    <select
                      class="form-select"
                      id="tipoBloqueo"
                      v-model="formBloqueo.tipoBloqueo"
                      required
                    >
                      <option value="">Seleccione motivo de suspensión...</option>
                      <option
                        v-for="tipo in tiposBloqueo"
                        :key="tipo.id"
                        :value="tipo.id"
                      >
                        {{ tipo.descripcion }}
                      </option>
                    </select>
                  </div>

                  <div class="col-md-6">
                    <label class="form-label fw-bold">
                      <i class="fas fa-cogs me-1"></i>
                      Opciones Adicionales
                    </label>
                    <div class="form-check">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        id="notificarSolicitante"
                        v-model="formBloqueo.notificarSolicitante"
                      >
                      <label class="form-check-label" for="notificarSolicitante">
                        Notificar al solicitante
                      </label>
                    </div>
                    <div class="form-check">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        id="requiereSeguimiento"
                        v-model="formBloqueo.requiereSeguimiento"
                      >
                      <label class="form-check-label" for="requiereSeguimiento">
                        Requiere seguimiento
                      </label>
                    </div>
                  </div>

                  <div class="col-12">
                    <label for="motivoBloqueo" class="form-label fw-bold">
                      <i class="fas fa-edit me-1"></i>
                      Descripción Detallada del Motivo *
                    </label>
                    <textarea
                      class="form-control"
                      id="motivoBloqueo"
                      v-model="formBloqueo.motivoBloqueo"
                      rows="4"
                      placeholder="Explique detalladamente el motivo del bloqueo, documentos faltantes, observaciones técnicas, etc."
                      maxlength="1000"
                      required
                    ></textarea>
                    <div class="form-text">
                      {{ formBloqueo.motivoBloqueo.length }}/1000 caracteres
                    </div>
                  </div>
                </div>
              </form>
            </div>
            <div class="modal-footer">
              <button
                type="button"
                class="btn btn-secondary"
                @click="cerrarModalBloqueo"
                :disabled="procesando"
              >
                <i class="fas fa-times me-2"></i>
                Cancelar
              </button>
              <button
                type="button"
                class="btn btn-warning"
                @click="confirmarBloqueo"
                :disabled="!formBloqueo.tipoBloqueo || !formBloqueo.motivoBloqueo || procesando"
              >
                <i class="fas fa-spinner fa-spin me-2" v-if="procesando"></i>
                <i class="fas fa-ban me-2" v-else></i>
                {{ procesando ? 'Procesando...' : 'Confirmar Suspensión' }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Modal de desbloqueo mejorado -->
      <div v-if="showModalDesbloqueo" class="modal fade show d-block" tabindex="-1">
        <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-header bg-gradient-success text-white">
              <h5 class="modal-title">
                <i class="fas fa-unlock me-2"></i>
                Reactivar Trámite - Levantar Suspensión
              </h5>
              <button type="button" class="btn-close btn-close-white" @click="cerrarModalDesbloqueo"></button>
            </div>
            <div class="modal-body">
              <!-- Información del trámite -->
              <div class="alert alert-warning mb-4">
                <div class="d-flex align-items-center">
                  <i class="fas fa-exclamation-triangle me-3 fa-lg"></i>
                  <div>
                    <h6 class="alert-heading mb-1">Trámite Bloqueado</h6>
                    <p class="mb-0">
                      <strong>ID:</strong> {{ tramite.id_tramite }} |
                      <strong>Estado Actual:</strong> {{ getEstadoTexto() }} |
                      <strong>Tipo:</strong> {{ getTipoBloqueoTexto(tramite.bloqueado) }}
                    </p>
                  </div>
                </div>
              </div>

              <form @submit.prevent="confirmarDesbloqueo">
                <div class="row g-3">
                  <div class="col-md-6">
                    <label for="tipoDesbloqueo" class="form-label fw-bold">
                      <i class="fas fa-unlock me-1"></i>
                      Bloqueo a Remover *
                    </label>
                    <select
                      class="form-select"
                      id="tipoDesbloqueo"
                      v-model="formDesbloqueo.tipoDesbloqueo"
                      required
                    >
                      <option value="">Seleccione bloqueo a eliminar...</option>
                      <option
                        v-for="bloq in bloqueosActivos"
                        :key="bloq.id"
                        :value="bloq.id"
                      >
                        {{ bloq.descripcion }}
                      </option>
                    </select>
                    <div class="form-text" v-if="bloqueosActivos.length === 0">
                      <i class="fas fa-info-circle me-1"></i>
                      Cargando bloqueos activos...
                    </div>
                  </div>

                  <div class="col-md-6">
                    <label class="form-label fw-bold">
                      <i class="fas fa-check-circle me-1"></i>
                      Validaciones
                    </label>
                    <div class="form-check">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        id="documentosRequeridos"
                        v-model="formDesbloqueo.documentosRequeridos"
                      >
                      <label class="form-check-label" for="documentosRequeridos">
                        Documentos completos
                      </label>
                    </div>
                    <div class="form-check">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        id="validacionTecnica"
                        value="true"
                      >
                      <label class="form-check-label" for="validacionTecnica">
                        Validación técnica aprobada
                      </label>
                    </div>
                  </div>

                  <div class="col-12">
                    <label for="motivoDesbloqueo" class="form-label fw-bold">
                      <i class="fas fa-edit me-1"></i>
                      Justificación del Desbloqueo *
                    </label>
                    <textarea
                      class="form-control"
                      id="motivoDesbloqueo"
                      v-model="formDesbloqueo.motivoDesbloqueo"
                      rows="4"
                      placeholder="Explique detalladamente por qué se levanta la suspensión, qué documentos se recibieron, observaciones resueltas, etc."
                      maxlength="1000"
                      required
                    ></textarea>
                    <div class="form-text">
                      {{ formDesbloqueo.motivoDesbloqueo.length }}/1000 caracteres
                    </div>
                  </div>
                </div>
              </form>
            </div>
            <div class="modal-footer">
              <button
                type="button"
                class="btn btn-secondary"
                @click="cerrarModalDesbloqueo"
                :disabled="procesando"
              >
                <i class="fas fa-times me-2"></i>
                Cancelar
              </button>
              <button
                type="button"
                class="btn btn-success"
                @click="confirmarDesbloqueo"
                :disabled="!formDesbloqueo.tipoDesbloqueo || !formDesbloqueo.motivoDesbloqueo || procesando"
              >
                <i class="fas fa-spinner fa-spin me-2" v-if="procesando"></i>
                <i class="fas fa-unlock me-2" v-else></i>
                {{ procesando ? 'Procesando...' : 'Confirmar Reactivación' }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Histórico de bloqueos mejorado -->
      <div v-if="tramite" class="card mb-4 shadow-sm">
        <div class="card-header bg-gradient-municipal text-white d-flex justify-content-between align-items-center">
          <h5 class="mb-0">
            <i class="fas fa-history me-2"></i>
            Historial de Movimientos y Bloqueos
            <span v-if="totalRegistros > 0" class="badge bg-light text-dark ms-2">
              {{ totalRegistros }} registros
            </span>
          </h5>
          <div class="d-flex gap-2 align-items-center">
            <select
              v-model="limitePorPagina"
              class="form-select form-select-sm"
              @change="cargarHistorial"
              style="width: auto; min-width: 120px;"
            >
              <option value="5">5 por página</option>
              <option value="10">10 por página</option>
              <option value="25">25 por página</option>
              <option value="50">50 por página</option>
            </select>
            <button
              type="button"
              class="btn btn-outline-light btn-sm"
              @click="cargarHistorial"
              :disabled="cargandoHistorial"
              title="Actualizar historial"
            >
              <i class="fas fa-spinner fa-spin me-1" v-if="cargandoHistorial"></i>
              <i class="fas fa-sync-alt me-1" v-else></i>
              {{ cargandoHistorial ? 'Cargando...' : 'Actualizar' }}
            </button>
          </div>
        </div>
      <div class="card-body p-0">
        <!-- Loading state with spinner -->
        <div v-if="cargandoHistorial" class="p-4 text-center">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-3 mb-0"><i class="fas fa-clock me-2"></i>Cargando historial...</p>
        </div>
        <div v-else-if="historialBloqueos.length === 0" class="p-4 text-center text-muted">
          <i class="fas fa-info-circle me-2"></i>
          No hay movimientos registrados para este trámite
        </div>
        <div v-else>
          <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
              <thead class="table-dark">
                <tr>
                  <th>Estado</th>
                  <th>Capturista</th>
                  <th>Fecha</th>
                  <th>Vigencia</th>
                  <th>Motivo</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="bloq in historialBloqueos" :key="`${bloq.fecha_mov}-${bloq.bloqueado}`">
                  <td>
                    <span :class="getBloqClass(bloq)">
                      {{ bloq.estado }}
                    </span>
                  </td>
                  <td>{{ bloq.capturista }}</td>
                  <td>{{ formatDate(bloq.fecha_mov) }}</td>
                  <td>
                    <span :class="getVigenciaClass(bloq.vigente)">
                      {{ bloq.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
                    </span>
                  </td>
                  <td class="text-truncate" style="max-width: 200px;" :title="bloq.observa">
                    {{ bloq.observa }}
                  </td>
                  <td>
                    <button
                      type="button"
                      class="btn btn-outline-info btn-sm"
                      @click="verDetalleMovimiento(bloq)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="card-footer d-flex justify-content-between align-items-center">
            <small class="text-muted">
              Mostrando {{ ((paginaActual - 1) * limitePorPagina) + 1 }} a
              {{ Math.min(paginaActual * limitePorPagina, totalRegistros) }} de
              {{ totalRegistros }} registros
            </small>
            <nav aria-label="Paginación del historial">
              <ul class="pagination pagination-sm mb-0">
                <li class="page-item" :class="{ disabled: paginaActual === 1 }">
                  <button class="page-link" @click="cambiarPagina(paginaActual - 1)" :disabled="paginaActual === 1">
                    <i class="fas fa-chevron-left"></i>
                  </button>
                </li>
                <li
                  v-for="pagina in paginasVisibles"
                  :key="pagina"
                  class="page-item"
                  :class="{ active: pagina === paginaActual }"
                >
                  <button class="page-link" @click="cambiarPagina(pagina)" v-if="typeof pagina === 'number'">{{ pagina }}</button>
                  <span class="page-link" v-else>{{ pagina }}</span>
                </li>
                <li class="page-item" :class="{ disabled: paginaActual === totalPaginas }">
                  <button class="page-link" @click="cambiarPagina(paginaActual + 1)" :disabled="paginaActual === totalPaginas">
                    <i class="fas fa-chevron-right"></i>
                  </button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para detalle de movimiento -->
    <div v-if="movimientoSeleccionado" class="modal fade show d-block" style="background-color: rgba(0,0,0,0.5);">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-info-circle me-2"></i>
              Detalle del Movimiento
            </h5>
            <button type="button" class="btn-close" @click="movimientoSeleccionado = null"></button>
          </div>
          <div class="modal-body">
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label fw-bold">Fecha y Hora</label>
                <div class="form-control-plaintext">{{ formatFechaCompleta(movimientoSeleccionado.fecha_mov) }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Estado</label>
                <div>
                  <span class="badge fs-6" :class="getBloqClass(movimientoSeleccionado)">
                    {{ movimientoSeleccionado.estado }}
                  </span>
                </div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Vigencia</label>
                <div>
                  <span class="badge fs-6" :class="getVigenciaClass(movimientoSeleccionado.vigente)">
                    {{ movimientoSeleccionado.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
                  </span>
                </div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Capturista</label>
                <div class="form-control-plaintext">{{ movimientoSeleccionado.capturista || 'N/A' }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">Tipo de Bloqueo</label>
                <div class="form-control-plaintext">{{ movimientoSeleccionado.bloqueado || 'N/A' }}</div>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-bold">ID Trámite</label>
                <div class="form-control-plaintext">{{ tramite.id_tramite }}</div>
              </div>
              <div class="col-12">
                <label class="form-label fw-bold">Observaciones</label>
                <div class="form-control-plaintext" style="white-space: pre-wrap;">
                  {{ movimientoSeleccionado.observa || 'Sin observaciones registradas' }}
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="movimientoSeleccionado = null">
              <i class="fas fa-times me-2"></i>
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Alertas -->
    <div v-if="alertMessage" :class="`alert alert-${alertType} alert-dismissible fade show`">
      <i :class="`fas ${alertType === 'success' ? 'fa-check-circle' : 'fa-exclamation-triangle'} me-2`"></i>
      {{ alertMessage }}
      <button type="button" class="btn-close" @click="clearAlert"></button>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showModalBloqueo || showModalDesbloqueo" class="modal-backdrop fade show"></div>
    </div>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'

export default {
  name: 'BloquearTramitefrm',
  emits: ['navigate'],
  setup(props, { emit }) {
    // =========================================
    // ESTADO REACTIVO
    // =========================================
    const state = reactive({
      // Datos principales
      numeroTramite: '',
      tramite: null,
      historialBloqueos: [],
      bloqueosActivos: [],
      tiposBloqueo: [],
      estadisticas: null,
      estadisticasTramite: null,

      // Configuración API
      apiConfig: {
        url: '/api/generic',
        tenant: 'guadalajara',
        base: 'licencias'
      },

      // Estados de UI
      buscando: false,
      procesando: false,
      cargandoHistorial: false,
      cargandoEstadisticas: false,

      // Configuración de búsqueda
      tipoConsulta: 'completa',

      // Modales
      showModalBloqueo: false,
      showModalDesbloqueo: false,

      // Formularios
      formBloqueo: {
        tipoBloqueo: '',
        motivoBloqueo: '',
        notificarSolicitante: false,
        requiereSeguimiento: true
      },
      formDesbloqueo: {
        tipoDesbloqueo: '',
        motivoDesbloqueo: '',
        documentosRequeridos: false
      },

      // Validaciones
      errors: {},

      // Alertas
      alertMessage: '',
      alertType: 'info',

      // Paginación
      paginaActual: 1,
      limitePorPagina: 10,
      totalRegistros: 0,
      movimientoSeleccionado: null,

      // Sistema
      horaActual: '',
      usuarioActual: '',
      intervalos: []
    })

    // =========================================
    // COMPUTED PROPERTIES
    // =========================================
    const totalPaginas = computed(() => {
      return Math.ceil(state.totalRegistros / state.limitePorPagina)
    })

    const paginasVisibles = computed(() => {
      const total = totalPaginas.value
      const actual = state.paginaActual
      const paginas = []

      if (total <= 7) {
        for (let i = 1; i <= total; i++) {
          paginas.push(i)
        }
      } else {
        if (actual <= 4) {
          for (let i = 1; i <= 5; i++) {
            paginas.push(i)
          }
          paginas.push('...')
          paginas.push(total)
        } else if (actual >= total - 3) {
          paginas.push(1)
          paginas.push('...')
          for (let i = total - 4; i <= total; i++) {
            paginas.push(i)
          }
        } else {
          paginas.push(1)
          paginas.push('...')
          for (let i = actual - 1; i <= actual + 1; i++) {
            paginas.push(i)
          }
          paginas.push('...')
          paginas.push(total)
        }
      }

      return paginas
    })

    // =========================================
    // MÉTODOS DE API (eRequest/eResponse)
    // =========================================
    const ejecutarSP = async (operacion, parametros = []) => {
      try {
        console.log(`[BloquearTramite] Ejecutando: ${operacion}`, parametros)

        const eRequest = {
          Operacion: operacion,
          Base: state.apiConfig.base,
          Parametros: parametros,
          Tenant: state.apiConfig.tenant
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        })

        if (!response.ok) {
          throw new Error(`HTTP Error: ${response.status} - ${response.statusText}`)
        }

        const data = await response.json()
        console.log(`[BloquearTramite] Response de ${operacion}:`, data)

        if (!data.eResponse) {
          throw new Error('Respuesta inválida del servidor: falta eResponse')
        }

        if (!data.eResponse.success) {
          throw new Error(data.eResponse.message || data.eResponse.error || 'Error en la operación')
        }

        return data.eResponse

      } catch (error) {
        console.error(`[BloquearTramite] Error en ${operacion}:`, error)
        throw error
      }
    }

    return {
      // Estado
      ...state,

      // Computed
      totalPaginas,
      paginasVisibles,

      // Métodos API
      ejecutarSP
    }
  },

  data() {
    return {}
  },
  computed: {
    // Los computed properties se movieron a la función setup()
  },
  
  async mounted() {
    await this.inicializarComponente()
  },

  beforeUnmount() {
    this.limpiarIntervalos()
  },
  
  methods: {
    // =========================================
    // INICIALIZACIÓN
    // =========================================
    async inicializarComponente() {
      try {
        this.usuarioActual = this.obtenerUsuario()
        this.actualizarHora()
        this.iniciarIntervalos()

        await Promise.all([
          this.cargarTiposBloqueo(),
          this.cargarEstadisticasGenerales()
        ])

        console.log('[BloquearTramite] Componente inicializado correctamente')

      } catch (error) {
        console.error('[BloquearTramite] Error en inicialización:', error)
        this.showAlert('Error al inicializar el sistema de bloqueos', 'danger')
      }
    },

    iniciarIntervalos() {
      // Actualizar hora cada segundo
      const intervaloHora = setInterval(() => {
        this.actualizarHora()
      }, 1000)

      this.intervalos.push(intervaloHora)
    },

    limpiarIntervalos() {
      this.intervalos.forEach(intervalo => clearInterval(intervalo))
      this.intervalos = []
    },

    actualizarHora() {
      const ahora = new Date()
      this.horaActual = ahora.toLocaleTimeString('es-MX', {
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      })
    },

    // =========================================
    // CARGA DE DATOS
    // =========================================
    async cargarTiposBloqueo() {
      try {
        const response = await this.ejecutarSP('sp_tipobloqueo_list')
        this.tiposBloqueo = response.data.result || []
        console.log('[BloquearTramite] Tipos de bloqueo cargados:', this.tiposBloqueo.length)

      } catch (error) {
        console.error('[BloquearTramite] Error cargando tipos de bloqueo:', error)
        this.showAlert('Error al cargar tipos de bloqueo: ' + error.message, 'danger')
      }
    },

    async cargarEstadisticasGenerales() {
      try {
        // Simular estadísticas generales por ahora
        this.estadisticas = {
          bloqueados_hoy: 12,
          desbloqueados_hoy: 8,
          pendientes: 25,
          total_sistema: 1847
        }

      } catch (error) {
        console.error('[BloquearTramite] Error cargando estadísticas:', error)
      }
    },
    
    // =========================================
    // BÚSQUEDA DE TRÁMITES
    // =========================================
    async buscarTramite() {
      if (!this.validarBusqueda()) return

      this.buscando = true
      this.limpiarDatosTramite()
      this.clearAlert()

      try {
        console.log(`[BloquearTramite] Buscando trámite ${this.numeroTramite}...`)

        const parametros = [
          { nombre: 'p_numero_tramite', valor: parseInt(this.numeroTramite), tipo: 'integer' }
        ]

        const response = await this.ejecutarSP('sp_buscar_tramite', parametros)

        if (response.data.result && response.data.result.length > 0) {
          this.tramite = response.data.result[0]
          this.showAlert(`Trámite #${this.numeroTramite} localizado correctamente`, 'success')

          // Cargar datos adicionales según el tipo de consulta
          await this.procesarConsultaTramite()

        } else {
          this.showAlert(`No se encontró el trámite #${this.numeroTramite}`, 'warning')
        }

      } catch (error) {
        console.error('[BloquearTramite] Error en búsqueda:', error)
        this.showAlert('Error al buscar el trámite: ' + error.message, 'danger')
      } finally {
        this.buscando = false
      }
    },

    validarBusqueda() {
      this.errors = {}

      if (!this.numeroTramite) {
        this.errors.numeroTramite = 'El número de trámite es requerido'
        return false
      }

      if (this.numeroTramite <= 0) {
        this.errors.numeroTramite = 'El número debe ser mayor a cero'
        return false
      }

      return true
    },

    limpiarDatosTramite() {
      this.tramite = null
      this.historialBloqueos = []
      this.bloqueosActivos = []
      this.estadisticasTramite = null
      this.paginaActual = 1
      this.totalRegistros = 0
      this.movimientoSeleccionado = null
    },

    limpiarBusqueda() {
      this.numeroTramite = ''
      this.tipoConsulta = 'completa'
      this.errors = {}
      this.limpiarDatosTramite()
      this.clearAlert()
    },

    async procesarConsultaTramite() {
      const operaciones = []

      if (this.tipoConsulta === 'completa' || this.tipoConsulta === 'historial') {
        operaciones.push(this.cargarHistorial())
      }

      if (this.tipoConsulta === 'completa') {
        operaciones.push(this.cargarEstadisticasTramite())
        operaciones.push(this.cargarBloqueosActivos())
      }

      await Promise.all(operaciones)
    },

    // =========================================
    // CARGA DE HISTORIAL
    // =========================================
    async cargarHistorial() {
      if (!this.tramite) return

      this.cargandoHistorial = true

      try {
        console.log(`[BloquearTramite] Cargando historial para trámite ${this.tramite.id_tramite}...`)

        // Intentar paginación server-side primero
        const offset = (this.paginaActual - 1) * this.limitePorPagina

        const parametros = [
          { nombre: 'p_id_tramite', valor: this.tramite.id_tramite, tipo: 'integer' },
          { nombre: 'limit_records', valor: this.limitePorPagina, tipo: 'integer' },
          { nombre: 'offset_records', valor: offset, tipo: 'integer' }
        ]

        const response = await this.ejecutarSP('sp_consultar_historial_tramite_paginado', parametros)

        if (response.data.result && response.data.result.length > 0) {
          const records = response.data.result

          if (records[0].total_registros !== undefined) {
            this.totalRegistros = parseInt(records[0].total_registros)
            this.historialBloqueos = records
            console.log(`[BloquearTramite] Historial paginado cargado: ${records.length} registros`)
          } else {
            // Fallback al método completo
            await this.cargarHistorialCompleto()
          }
        } else {
          this.historialBloqueos = []
          this.totalRegistros = 0
          console.log('[BloquearTramite] No hay historial para este trámite')
        }

      } catch (error) {
        console.error('[BloquearTramite] Error cargando historial paginado:', error)
        // Fallback al método completo
        await this.cargarHistorialCompleto()
      } finally {
        this.cargandoHistorial = false
      }
    },

    async cargarHistorialCompleto() {
      try {
        console.log('[BloquearTramite] Fallback: cargando historial completo...')

        const parametros = [
          { nombre: 'p_id_tramite', valor: this.tramite.id_tramite, tipo: 'integer' }
        ]

        const response = await this.ejecutarSP('sp_consultar_historial_tramite', parametros)

        if (response.data.result) {
          const allRecords = response.data.result
          this.totalRegistros = allRecords.length

          // Paginación client-side como fallback
          const start = (this.paginaActual - 1) * this.limitePorPagina
          const end = start + this.limitePorPagina
          this.historialBloqueos = allRecords.slice(start, end)

          console.log(`[BloquearTramite] Historial completo cargado: ${allRecords.length} registros totales`)
        } else {
          this.historialBloqueos = []
          this.totalRegistros = 0
        }

      } catch (error) {
        console.error('[BloquearTramite] Error cargando historial completo:', error)
        this.historialBloqueos = []
        this.totalRegistros = 0
      }
    },

    async cargarBloqueosActivos() {
      if (!this.tramite) return

      try {
        const parametros = [
          { nombre: 'p_id_tramite', valor: this.tramite.id_tramite, tipo: 'integer' }
        ]

        const response = await this.ejecutarSP('sp_obtener_bloqueos_activos', parametros)
        this.bloqueosActivos = response.data.result || []

        console.log(`[BloquearTramite] Bloqueos activos: ${this.bloqueosActivos.length}`)

      } catch (error) {
        console.error('[BloquearTramite] Error cargando bloqueos activos:', error)
        this.bloqueosActivos = []
      }
    },

    async cargarEstadisticasTramite() {
      if (!this.tramite) return

      this.cargandoEstadisticas = true

      try {
        const parametros = [
          { nombre: 'p_id_tramite', valor: this.tramite.id_tramite, tipo: 'integer' }
        ]

        const response = await this.ejecutarSP('sp_estadisticas_bloqueos_tramite', parametros)

        if (response.data.result && response.data.result.length > 0) {
          this.estadisticasTramite = response.data.result[0]
          console.log('[BloquearTramite] Estadísticas del trámite cargadas:', this.estadisticasTramite)
        }

      } catch (error) {
        console.error('[BloquearTramite] Error cargando estadísticas del trámite:', error)
      } finally {
        this.cargandoEstadisticas = false
      }
    },


    // =========================================
    // PAGINACIÓN
    // =========================================
    cambiarPagina(nuevaPagina) {
      if (typeof nuevaPagina === 'number' && nuevaPagina >= 1 && nuevaPagina <= this.totalPaginas) {
        this.paginaActual = nuevaPagina
        this.cargarHistorial()
      }
    },

    verDetalleMovimiento(movimiento) {
      this.movimientoSeleccionado = { ...movimiento }
    },

    // =========================================
    // GESTIÓN DE MODALES
    // =========================================
    abrirModalBloqueo() {
      this.formBloqueo = {
        tipoBloqueo: '',
        motivoBloqueo: '',
        notificarSolicitante: false,
        requiereSeguimiento: true
      }
      this.showModalBloqueo = true
    },

    cerrarModalBloqueo() {
      this.showModalBloqueo = false
      this.formBloqueo = {
        tipoBloqueo: '',
        motivoBloqueo: '',
        notificarSolicitante: false,
        requiereSeguimiento: true
      }
    },

    abrirModalDesbloqueo() {
      // Cargar bloqueos activos primero
      this.cargarBloqueosActivos()
      this.formDesbloqueo = {
        tipoDesbloqueo: '',
        motivoDesbloqueo: '',
        documentosRequeridos: false
      }
      this.showModalDesbloqueo = true
    },

    cerrarModalDesbloqueo() {
      this.showModalDesbloqueo = false
      this.formDesbloqueo = {
        tipoDesbloqueo: '',
        motivoDesbloqueo: '',
        documentosRequeridos: false
      }
    },
    
    // =========================================
    // OPERACIONES DE BLOQUEO/DESBLOQUEO
    // =========================================
    async confirmarBloqueo() {
      if (!this.validarFormularioBloqueo()) return

      this.procesando = true

      try {
        console.log('[BloquearTramite] Iniciando bloqueo de trámite...')

        const parametros = [
          { nombre: 'p_id_tramite', valor: this.tramite.id_tramite, tipo: 'integer' },
          { nombre: 'p_tipo_bloqueo', valor: parseInt(this.formBloqueo.tipoBloqueo), tipo: 'integer' },
          { nombre: 'p_motivo', valor: this.formBloqueo.motivoBloqueo, tipo: 'varchar' },
          { nombre: 'p_usuario', valor: this.obtenerUsuario(), tipo: 'varchar' },
          { nombre: 'p_notificar_solicitante', valor: this.formBloqueo.notificarSolicitante ? 'S' : 'N', tipo: 'varchar' }
        ]

        const response = await this.ejecutarSP('sp_bloquear_tramite', parametros)

        if (response.data.result && response.data.result.length > 0) {
          const resultado = response.data.result[0]
          this.showAlert(resultado.message || 'Trámite bloqueado exitosamente', 'success')

          // Actualizar estado del trámite
          this.tramite.bloqueado = parseInt(this.formBloqueo.tipoBloqueo)

          this.cerrarModalBloqueo()

          // Recargar datos
          this.paginaActual = 1
          await Promise.all([
            this.cargarHistorial(),
            this.cargarBloqueosActivos(),
            this.cargarEstadisticasTramite()
          ])

        } else {
          this.showAlert('Error: Respuesta inesperada del servidor', 'danger')
        }

      } catch (error) {
        console.error('[BloquearTramite] Error en bloqueo:', error)
        this.showAlert('Error al bloquear el trámite: ' + error.message, 'danger')
      } finally {
        this.procesando = false
      }
    },

    validarFormularioBloqueo() {
      if (!this.formBloqueo.tipoBloqueo) {
        this.showAlert('Debe seleccionar un tipo de bloqueo', 'warning')
        return false
      }

      if (!this.formBloqueo.motivoBloqueo.trim()) {
        this.showAlert('Debe especificar el motivo del bloqueo', 'warning')
        return false
      }

      if (this.formBloqueo.motivoBloqueo.trim().length < 10) {
        this.showAlert('El motivo debe tener al menos 10 caracteres', 'warning')
        return false
      }

      return true
    },
    
    async confirmarDesbloqueo() {
      if (!this.validarFormularioDesbloqueo()) return

      this.procesando = true

      try {
        console.log('[BloquearTramite] Iniciando desbloqueo de trámite...')

        const parametros = [
          { nombre: 'p_id_tramite', valor: this.tramite.id_tramite, tipo: 'integer' },
          { nombre: 'p_tipo_bloqueo', valor: parseInt(this.formDesbloqueo.tipoDesbloqueo), tipo: 'integer' },
          { nombre: 'p_motivo', valor: this.formDesbloqueo.motivoDesbloqueo, tipo: 'varchar' },
          { nombre: 'p_usuario', valor: this.obtenerUsuario(), tipo: 'varchar' }
        ]

        const response = await this.ejecutarSP('sp_desbloquear_tramite', parametros)

        if (response.data.result && response.data.result.length > 0) {
          const resultado = response.data.result[0]
          this.showAlert(resultado.message || 'Trámite desbloqueado exitosamente', 'success')

          // Actualizar estado del trámite
          this.tramite.bloqueado = 0

          this.cerrarModalDesbloqueo()

          // Recargar datos
          this.paginaActual = 1
          await Promise.all([
            this.cargarHistorial(),
            this.cargarBloqueosActivos(),
            this.cargarEstadisticasTramite()
          ])

        } else {
          this.showAlert('Error: Respuesta inesperada del servidor', 'danger')
        }

      } catch (error) {
        console.error('[BloquearTramite] Error en desbloqueo:', error)
        this.showAlert('Error al desbloquear el trámite: ' + error.message, 'danger')
      } finally {
        this.procesando = false
      }
    },

    validarFormularioDesbloqueo() {
      if (!this.formDesbloqueo.tipoDesbloqueo) {
        this.showAlert('Debe seleccionar el bloqueo a remover', 'warning')
        return false
      }

      if (!this.formDesbloqueo.motivoDesbloqueo.trim()) {
        this.showAlert('Debe especificar el motivo del desbloqueo', 'warning')
        return false
      }

      if (this.formDesbloqueo.motivoDesbloqueo.trim().length < 10) {
        this.showAlert('El motivo debe tener al menos 10 caracteres', 'warning')
        return false
      }

      return true
    },
    
    // =========================================
    // MÉTODOS DE FORMATO Y PRESENTACIÓN
    // =========================================
    getEstadoTexto() {
      if (!this.tramite) return ''

      switch (this.tramite.bloqueado) {
        case 0: return 'NO BLOQUEADO'
        case 1: return 'BLOQUEADO GENERAL'
        case 2: return 'DOCUMENTACIÓN FALTANTE'
        case 3: return 'OBSERVACIÓN TÉCNICA'
        case 4: return 'SUSPENDIDO'
        case 5: return 'RESPONSIVA REQUERIDA'
        case 6: return 'CONVENIO PENDIENTE'
        case 7: return 'CONFLICTO LEGAL'
        default: return 'ESTADO DESCONOCIDO'
      }
    },

    getTipoBloqueoTexto(tipoBloqueado) {
      switch (tipoBloqueado) {
        case 1: return 'Bloqueo General'
        case 2: return 'Documentación Faltante'
        case 3: return 'Observación Técnica'
        case 4: return 'Suspendido'
        case 5: return 'Responsiva Requerida'
        case 6: return 'Convenio Pendiente'
        case 7: return 'Conflicto Legal'
        default: return 'Tipo Desconocido'
      }
    },

    getEstadoClass() {
      if (!this.tramite) return ''
      return this.tramite.bloqueado > 0 ? 'badge bg-danger' : 'badge bg-success'
    },

    getEstadoBadgeClass() {
      if (!this.tramite) return 'badge bg-secondary'

      switch (this.tramite.bloqueado) {
        case 0: return 'badge bg-success'
        case 1: return 'badge bg-danger'
        case 2: return 'badge bg-warning text-dark'
        case 3: return 'badge bg-info'
        case 4: return 'badge bg-danger'
        case 5: return 'badge bg-warning text-dark'
        case 6: return 'badge bg-primary'
        case 7: return 'badge bg-dark'
        default: return 'badge bg-secondary'
      }
    },

    getEstadoIcon() {
      if (!this.tramite) return 'fa-question'

      switch (this.tramite.bloqueado) {
        case 0: return 'fa-check-circle'
        case 1: return 'fa-ban'
        case 2: return 'fa-file-excel'
        case 3: return 'fa-exclamation-triangle'
        case 4: return 'fa-pause-circle'
        case 5: return 'fa-file-signature'
        case 6: return 'fa-handshake'
        case 7: return 'fa-gavel'
        default: return 'fa-question-circle'
      }
    },

    formatNombreCompleto(primerAp, segundoAp, nombre) {
      const partes = []
      if (nombre) partes.push(nombre)
      if (primerAp) partes.push(primerAp)
      if (segundoAp) partes.push(segundoAp)
      return partes.length > 0 ? partes.join(' ') : 'No especificado'
    },

    formatDireccion(tramite) {
      const partes = []
      if (tramite.ubicacion) partes.push(tramite.ubicacion)

      const numero = []
      if (tramite.numext_ubic) numero.push(`No. ext: ${tramite.numext_ubic}`)
      if (tramite.letraext_ubic) numero.push(tramite.letraext_ubic)
      if (tramite.numint_ubic) numero.push(`No. int: ${tramite.numint_ubic}`)
      if (tramite.letraint_ubic) numero.push(tramite.letraint_ubic)

      if (numero.length > 0) {
        partes.push(`(${numero.join(' ')})`)
      }

      return partes.length > 0 ? partes.join(' ') : 'Ubicación no especificada'
    },

    formatFecha(fecha) {
      if (!fecha) return 'No disponible'
      return new Date(fecha).toLocaleDateString('es-MX', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    },
    
    getBloqClass(bloq) {
      if (bloq.es_desbloqueo === 'S') return 'badge bg-success'
      if (bloq.bloqueado === 0) return 'badge bg-success'
      return 'badge bg-warning text-dark'
    },

    getVigenciaClass(vigente) {
      return vigente === 'V' ? 'badge bg-primary' : 'badge bg-secondary'
    },

    formatDate(dateStr) {
      if (!dateStr) return ''
      return new Date(dateStr).toLocaleDateString('es-MX')
    },

    formatFechaCompleta(fecha) {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleString('es-MX', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      })
    },
    
    // =========================================
    // UTILIDADES Y SISTEMA
    // =========================================
    showAlert(message, type = 'info') {
      this.alertMessage = message
      this.alertType = type

      console.log(`[BloquearTramite] Alert [${type}]: ${message}`)

      // Auto-hide después de 5 segundos para alertas de éxito e info
      if (type === 'success' || type === 'info') {
        setTimeout(() => {
          this.clearAlert()
        }, 5000)
      }
    },

    clearAlert() {
      this.alertMessage = ''
      this.alertType = 'info'
    },

    obtenerUsuario() {
      // Implementar lógica para obtener el usuario autenticado
      return (window.user && window.user.username) ||
             (this.$store && this.$store.state.user && this.$store.state.user.username) ||
             sessionStorage.getItem('username') ||
             'sistema'
    },

    async generarReporte() {
      if (!this.tramite) {
        this.showAlert('Primero debe buscar un trámite', 'warning')
        return
      }

      try {
        console.log('[BloquearTramite] Generando reporte de bloqueos...')

        // Datos para el reporte
        const datosReporte = {
          tramite: this.tramite,
          historial: this.historialBloqueos,
          estadisticas: this.estadisticasTramite,
          fecha_generacion: new Date().toISOString(),
          usuario_generador: this.obtenerUsuario()
        }

        // Generar contenido del reporte en texto plano
        let contenidoReporte = `
=======================================================
REPORTE DE BLOQUEOS Y MOVIMIENTOS - SISTEMA MUNICIPAL
=======================================================

INFORMACIÓN DEL TRÁMITE:
- ID Trámite: ${this.tramite.id_tramite}
- Folio: ${this.tramite.folio || 'N/A'}
- Tipo: ${this.tramite.tipo_tramite || 'N/A'}
- Propietario: ${this.formatNombreCompleto(this.tramite.primer_ap, this.tramite.segundo_ap, this.tramite.propietario)}
- Ubicación: ${this.formatDireccion(this.tramite)}
- Estado Actual: ${this.getEstadoTexto()}
- Giro: ${this.tramite.giro || 'N/A'}

ESTADÍSTICAS GENERALES:
- Total de Bloqueos: ${this.estadisticasTramite?.total_bloqueos || 0}
- Bloqueos Activos: ${this.estadisticasTramite?.bloqueos_activos || 0}
- Total de Desbloqueos: ${this.estadisticasTramite?.total_desbloqueos || 0}
- Días desde último bloqueo: ${this.estadisticasTramite?.dias_desde_ultimo_bloqueo || 0}

HISTORIAL DE MOVIMIENTOS:
${this.historialBloqueos.map((mov, index) => `
${index + 1}. ${mov.estado} - ${this.formatFechaCompleta(mov.fecha_mov)}
   Capturista: ${mov.capturista}
   Vigencia: ${mov.vigente === 'V' ? 'Vigente' : 'Cancelado'}
   Observaciones: ${mov.observa || 'Sin observaciones'}
   ${mov.es_desbloqueo === 'S' ? '   *** OPERACIÓN DE DESBLOQUEO ***' : ''}
`).join('')}

=======================================================
Reporte generado el: ${this.formatFechaCompleta(new Date())}
Usuario: ${this.obtenerUsuario()}
Sistema: Harweb Municipal Guadalajara v1.0
=======================================================
        `

        // Crear y descargar archivo
        const blob = new Blob([contenidoReporte], { type: 'text/plain;charset=utf-8' })
        const url = window.URL.createObjectURL(blob)
        const link = document.createElement('a')
        link.href = url
        link.download = `reporte_bloqueos_tramite_${this.tramite.id_tramite}_${new Date().getTime()}.txt`
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
        window.URL.revokeObjectURL(url)

        this.showAlert('Reporte generado y descargado exitosamente', 'success')

      } catch (error) {
        console.error('[BloquearTramite] Error generando reporte:', error)
        this.showAlert('Error al generar el reporte: ' + error.message, 'danger')
      }
    }
  }
}
</script>

<style scoped>
/* =========================================
   ESTILOS ESPECÍFICOS DEL COMPONENTE
   ========================================= */

/* Modales */
.modal.show {
  display: block;
}

.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 1040;
  width: 100vw;
  height: 100vh;
  background-color: #000;
  opacity: 0.5;
}

/* Gradientes municipales */
.bg-gradient-municipal {
  background: linear-gradient(135deg, var(--municipal-primary, #ea8215) 0%, var(--municipal-secondary, #cc9f52) 100%);
}

.bg-gradient-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
}

.bg-gradient-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
}

.bg-gradient-warning {
  background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);
}

.bg-gradient-primary {
  background: linear-gradient(135deg, #007bff 0%, #6f42c1 100%);
}

.bg-gradient-secondary {
  background: linear-gradient(135deg, #6c757d 0%, #495057 100%);
}

/* Grid de información */
.info-grid {
  display: grid;
  gap: 0.75rem;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 0.5rem 0;
  border-bottom: 1px solid rgba(0,0,0,0.1);
}

.info-item:last-child {
  border-bottom: none;
}

.info-item label {
  font-size: 0.875rem;
  min-width: 40%;
  margin-bottom: 0;
}

.info-item span {
  text-align: right;
  font-weight: 500;
  max-width: 60%;
  word-wrap: break-word;
}

/* Tarjetas de acción */
.action-card {
  padding: 1.25rem;
  border: 2px solid rgba(0,0,0,0.1);
  border-radius: 0.75rem;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  transition: all 0.3s ease;
}

.action-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  border-color: var(--municipal-primary, #ea8215);
}

/* Botones municipales */
.btn-municipal-primary {
  background: linear-gradient(135deg, var(--municipal-primary, #ea8215) 0%, var(--municipal-secondary, #cc9f52) 100%);
  border: none;
  color: white;
  transition: all 0.3s ease;
}

.btn-municipal-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(234, 130, 21, 0.3);
  color: white;
}

.btn-municipal-white {
  background: rgba(255,255,255,0.2);
  border: 1px solid rgba(255,255,255,0.3);
  color: white;
  transition: all 0.3s ease;
}

.btn-municipal-white:hover,
.btn-municipal-white.active {
  background: rgba(255,255,255,0.3);
  border-color: rgba(255,255,255,0.5);
  color: white;
  transform: translateY(-1px);
}

/* Texto municipal */
.text-municipal-primary {
  color: var(--municipal-primary, #ea8215);
}

.text-municipal-warning {
  color: var(--municipal-warning, #ffb700);
}

/* Headers municipales */
.municipal-header {
  background: linear-gradient(135deg, var(--municipal-primary, #ea8215) 0%, var(--municipal-secondary, #cc9f52) 100%);
  color: white;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}

.municipal-controls {
  background: rgba(255,255,255,0.95);
  backdrop-filter: blur(10px);
}

/* Tablas */
.table th {
  border-top: none;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  font-weight: 600;
  color: #495057;
  position: sticky;
  top: 0;
  z-index: 10;
}

.table-hover tbody tr:hover {
  background-color: rgba(234, 130, 21, 0.05);
}

/* Cards */
.card {
  border: none;
  transition: all 0.3s ease;
}

.card.shadow-sm {
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.card:hover {
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}

.card-header {
  font-weight: 600;
  border-bottom: 2px solid rgba(0,0,0,0.1);
}

/* Badges */
.badge {
  font-size: 0.75rem;
  padding: 0.5em 0.75em;
  font-weight: 500;
}

/* Estados de botones */
.btn:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}

/* Alertas */
.alert {
  margin-top: 1rem;
  border: none;
  border-radius: 0.75rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

/* Formularios */
.form-select:focus,
.form-control:focus {
  border-color: var(--municipal-primary, #ea8215);
  box-shadow: 0 0 0 0.25rem rgba(234, 130, 21, 0.25);
}

.form-control.is-invalid {
  border-color: #dc3545;
}

.input-group-text {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-color: #dee2e6;
}

/* Breadcrumbs */
.breadcrumb-item a {
  text-decoration: none;
  transition: all 0.3s ease;
}

.breadcrumb-item a:hover {
  text-decoration: underline;
}

/* Responsividad */
@media (max-width: 768px) {
  .info-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .info-item label {
    min-width: auto;
    margin-bottom: 0.25rem;
  }

  .info-item span {
    text-align: left;
    max-width: 100%;
  }

  .action-card {
    margin-bottom: 1rem;
  }
}

/* Animaciones */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.card,
.alert {
  animation: fadeIn 0.3s ease;
}

/* Loading states */
.spinner-border {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>
