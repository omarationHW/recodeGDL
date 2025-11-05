<template>
  <div class="container-fluid p-0 h-100 municipal-app">
    <!-- Municipal Header Enhanced -->
    <div class="municipal-header gradient-header p-4 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div class="header-content">
          <h1 class="h2 mb-2 text-white fw-bold">
            <i class="fas fa-shield-alt me-3 text-warning"></i>
            Sistema de Bloqueo de Licencias *
          </h1>
          <p class="mb-0 text-white-75 fs-6">
            <i class="fas fa-info-circle me-2"></i>
            Control integral de suspensiones y reactivaciones de licencias comerciales
          </p>
        </div>
        <div class="header-actions">
          <div class="municipal-breadcrumb bg-white bg-opacity-15 rounded px-3 py-2">
            <nav aria-label="breadcrumb">
              <ol class="breadcrumb mb-0 small">
                <li class="breadcrumb-item">
                  <a href="#" class="text-white text-decoration-none">
                    <i class="fas fa-home me-1"></i>Inicio
                  </a>
                </li>
                <li class="breadcrumb-item">
                  <a href="#" class="text-white text-decoration-none">Licencias</a>
                </li>
                <li class="breadcrumb-item active text-warning" aria-current="page">
                  Bloquear Licencias
                </li>
              </ol>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Enhanced Controls -->
    <div class="municipal-controls bg-light border-bottom shadow-sm p-3">
      <div class="d-flex justify-content-between align-items-center">
        <div class="control-actions">
          <div class="btn-group shadow-sm" role="group" aria-label="Acciones principales">
            <button type="button" class="btn btn-municipal-outline" title="Inicio">
              <i class="fas fa-home"></i>
            </button>
            <button type="button" class="btn btn-municipal-outline" title="Nueva consulta" @click="limpiarFormulario">
              <i class="fas fa-search"></i>
            </button>
            <button type="button" class="btn btn-municipal-outline" title="Historial">
              <i class="fas fa-history"></i>
            </button>
            <button type="button" class="btn btn-municipal-outline" title="Reportes" @click="mostrarEstadisticas">
              <i class="fas fa-chart-bar"></i>
            </button>
          </div>
        </div>
        <div class="status-indicators">
          <span v-if="licenciaEncontrada" class="badge bg-success fs-6">
            <i class="fas fa-check-circle me-1"></i>
            Licencia: {{ licenciaEncontrada.licencia }}
          </span>
          <span v-if="totalRegistros > 0" class="badge bg-info fs-6 ms-2">
            <i class="fas fa-database me-1"></i>
            {{ totalRegistros }} registros
          </span>
        </div>
      </div>
    </div>

    <!-- Main Content Enhanced -->
    <div class="municipal-content p-4">

      <!-- Enhanced Search Form -->
      <div class="search-section mb-4">
        <div class="card border-0 shadow-lg">
          <div class="card-header municipal-gradient text-white border-0">
            <div class="d-flex align-items-center">
              <div class="icon-circle bg-white bg-opacity-20 me-3">
                <i class="fas fa-search text-white"></i>
              </div>
              <div>
                <h5 class="mb-1 fw-bold">Buscar Licencia Comercial</h5>
                <small class="text-white-75">Ingrese el número de licencia para consultar su estado</small>
              </div>
            </div>
          </div>
          <div class="card-body p-4">
            <form @submit.prevent="buscarLicencia" class="search-form">
              <div class="row g-3 align-items-end">
                <div class="col-md-5">
                  <label for="numeroLicencia" class="form-label fw-semibold text-municipal">
                    <i class="fas fa-id-card me-2 text-municipal"></i>
                    Número de Licencia *
                  </label>
                  <div class="input-group">
                    <span class="input-group-text bg-municipal text-white">
                      <i class="fas fa-hashtag"></i>
                    </span>
                    <input
                      type="number"
                      class="form-control form-control-lg"
                      id="numeroLicencia"
                      v-model="numeroLicencia"
                      placeholder="Ej: 12345"
                      min="1"
                      max="999999"
                      @keyup.enter="buscarLicencia"
                      :class="{ 'is-invalid': validationErrors.numeroLicencia }"
                      required
                    >
                    <div v-if="validationErrors.numeroLicencia" class="invalid-feedback">
                      {{ validationErrors.numeroLicencia }}
                    </div>
                  </div>
                  <div class="form-text">
                    <i class="fas fa-info-circle text-info me-1"></i>
                    Número de 1 a 6 dígitos
                  </div>
                </div>
                <div class="col-md-3">
                  <button
                    type="submit"
                    class="btn btn-municipal btn-lg w-100 shadow"
                    :disabled="buscando || !numeroLicencia || !isValidLicenciaNumber"
                  >
                    <i class="fas fa-search me-2"></i>
                    <span v-if="buscando">
                      <span class="spinner-border spinner-border-sm me-2" role="status"></span>
                      Buscando...
                    </span>
                    <span v-else>Buscar</span>
                  </button>
                </div>
                <div class="col-md-4">
                  <div class="search-stats bg-light rounded p-3">
                    <div class="d-flex justify-content-between align-items-center">
                      <small class="text-muted">
                        <i class="fas fa-clock me-1"></i>
                        Última búsqueda:
                      </small>
                      <small class="fw-semibold">
                        {{ ultimaBusqueda || 'Ninguna' }}
                      </small>
                    </div>
                  </div>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>

      <!-- Enhanced License Information -->
      <div v-if="licenciaEncontrada" class="license-info-section mb-4">
        <div class="card border-0 shadow-lg">
          <div class="card-header border-0 bg-white p-4">
            <div class="d-flex justify-content-between align-items-start">
              <div>
                <h5 class="mb-2 text-municipal fw-bold">
                  <i class="fas fa-file-contract me-2 text-municipal"></i>
                  Información de la Licencia
                  <span class="text-muted fs-6 fw-normal">#{{ licenciaEncontrada.licencia }}</span>
                </h5>
                <div class="license-status-indicators">
                  <span class="badge" :class="getEstadoBadgeClass(licenciaEncontrada.bloqueado)">
                    <i class="fas" :class="getEstadoIcon(licenciaEncontrada.bloqueado)"></i>
                    {{ getEstadoLicencia(licenciaEncontrada.bloqueado) }}
                  </span>
                  <span v-if="licenciaEncontrada.dias_vigencia !== undefined"
                        class="badge ms-2"
                        :class="getVigenciaBadgeClass(licenciaEncontrada.dias_vigencia)">
                    <i class="fas fa-calendar-alt me-1"></i>
                    {{ getVigenciaTexto(licenciaEncontrada.dias_vigencia) }}
                  </span>
                </div>
              </div>
              <div class="license-actions">
                <button class="btn btn-outline-municipal btn-sm"
                        @click="refrescarLicencia"
                        :disabled="buscando"
                        title="Refrescar información">
                  <i class="fas fa-sync-alt" :class="{ 'fa-spin': buscando }"></i>
                </button>
              </div>
            </div>
          </div>
          <div class="card-body p-4">
            <div class="license-details">
              <div class="row g-4">
                <!-- Información Principal -->
                <div class="col-md-6">
                  <div class="info-group">
                    <h6 class="text-municipal mb-3">
                      <i class="fas fa-id-badge me-2"></i>
                      Datos Principales
                    </h6>
                    <div class="row g-3">
                      <div class="col-6">
                        <label class="form-label fw-semibold text-muted small">ID Interno</label>
                        <div class="info-value">{{ licenciaEncontrada.id_licencia }}</div>
                      </div>
                      <div class="col-6">
                        <label class="form-label fw-semibold text-muted small">Número Licencia</label>
                        <div class="info-value text-municipal fw-bold">{{ licenciaEncontrada.licencia }}</div>
                      </div>
                      <div class="col-12">
                        <label class="form-label fw-semibold text-muted small">Giro Comercial</label>
                        <div class="info-value">{{ licenciaEncontrada.giro || 'No especificado' }}</div>
                      </div>
                    </div>
                  </div>
                </div>
                <!-- Fechas y Vigencia -->
                <div class="col-md-6">
                  <div class="info-group">
                    <h6 class="text-municipal mb-3">
                      <i class="fas fa-calendar-check me-2"></i>
                      Vigencia y Fechas
                    </h6>
                    <div class="row g-3">
                      <div class="col-6">
                        <label class="form-label fw-semibold text-muted small">Fecha Expedición</label>
                        <div class="info-value">{{ formatearFecha(licenciaEncontrada.fecha_expedicion) }}</div>
                      </div>
                      <div class="col-6">
                        <label class="form-label fw-semibold text-muted small">Vigencia Hasta</label>
                        <div class="info-value" :class="getVigenciaClass(licenciaEncontrada.vigencia_hasta)">
                          {{ formatearFecha(licenciaEncontrada.vigencia_hasta) }}
                        </div>
                      </div>
                      <div class="col-12" v-if="licenciaEncontrada.dias_vigencia !== undefined">
                        <label class="form-label fw-semibold text-muted small">Estado de Vigencia</label>
                        <div class="progress mt-1" style="height: 6px;">
                          <div class="progress-bar"
                               :class="getVigenciaProgressClass(licenciaEncontrada.dias_vigencia)"
                               :style="{ width: getVigenciaProgress(licenciaEncontrada.dias_vigencia) + '%' }"></div>
                        </div>
                        <small class="text-muted">{{ getVigenciaDetalles(licenciaEncontrada.dias_vigencia) }}</small>
                      </div>
                    </div>
                  </div>
                </div>
                <!-- Propietario -->
                <div class="col-md-6">
                  <div class="info-group">
                    <h6 class="text-municipal mb-3">
                      <i class="fas fa-user-tie me-2"></i>
                      Propietario
                    </h6>
                    <div class="propietario-info bg-light rounded p-3">
                      <div class="fw-semibold">{{ licenciaEncontrada.nombre_propietario || 'No registrado' }}</div>
                      <div v-if="licenciaEncontrada.telefono" class="text-muted small mt-1">
                        <i class="fas fa-phone me-1"></i>{{ licenciaEncontrada.telefono }}
                      </div>
                      <div v-if="licenciaEncontrada.email" class="text-muted small">
                        <i class="fas fa-envelope me-1"></i>{{ licenciaEncontrada.email }}
                      </div>
                    </div>
                  </div>
                </div>
                <!-- Ubicación -->
                <div class="col-md-6">
                  <div class="info-group">
                    <h6 class="text-municipal mb-3">
                      <i class="fas fa-map-marker-alt me-2"></i>
                      Ubicación del Negocio
                    </h6>
                    <div class="ubicacion-info bg-light rounded p-3">
                      <div class="fw-semibold">{{ licenciaEncontrada.ubicacion || 'Dirección no especificada' }}</div>
                      <div class="text-muted small mt-1">
                        <i class="fas fa-building me-1"></i>Establecimiento comercial
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Enhanced Block/Unblock Actions -->
      <div v-if="licenciaEncontrada" class="block-actions-section mb-4">
        <div class="card border-0 shadow-lg">
          <div class="card-header border-0 bg-gradient-to-r from-orange-500 to-yellow-500 text-white p-4">
            <div class="d-flex align-items-center">
              <div class="icon-circle bg-white bg-opacity-20 me-3">
                <i class="fas fa-cogs text-white"></i>
              </div>
              <div>
                <h5 class="mb-1 fw-bold">Acciones de Bloqueo/Desbloqueo</h5>
                <small class="text-white-75">Gestión del estado de la licencia comercial</small>
              </div>
            </div>
          </div>
          <div class="card-body p-4">
            <form @submit.prevent="procesarAccion" class="block-form">
              <div class="row g-4">
                <!-- Tipo de Bloqueo -->
                <div class="col-md-4">
                  <label for="tipoBloqueo" class="form-label fw-semibold text-municipal">
                    <i class="fas fa-list me-2"></i>
                    Tipo de Bloqueo *
                  </label>
                  <select
                    class="form-select form-select-lg"
                    id="tipoBloqueo"
                    v-model="tipoBloqueoSeleccionado"
                    :disabled="cargandoTipos"
                    :class="{ 'is-invalid': validationErrors.tipoBloqueo }"
                    required
                  >
                    <option value="">{{ cargandoTipos ? 'Cargando...' : 'Seleccione tipo' }}</option>
                    <option
                      v-for="tipo in tiposBloqueo"
                      :key="tipo.id"
                      :value="tipo.id"
                    >
                      {{ tipo.descripcion }}
                      <span v-if="tipo.multa_base > 0"> - ${{ formatearMoneda(tipo.multa_base) }}</span>
                    </option>
                  </select>
                  <div v-if="validationErrors.tipoBloqueo" class="invalid-feedback">
                    {{ validationErrors.tipoBloqueo }}
                  </div>
                  <div v-if="tipoBloqueoSeleccionado" class="form-text">
                    <i class="fas fa-info-circle text-info me-1"></i>
                    {{ getTipoBloqueoInfo(tipoBloqueoSeleccionado) }}
                  </div>
                </div>

                <!-- Observaciones -->
                <div class="col-md-5">
                  <label for="observaciones" class="form-label fw-semibold text-municipal">
                    <i class="fas fa-comment-alt me-2"></i>
                    Observaciones *
                  </label>
                  <textarea
                    class="form-control form-control-lg"
                    id="observaciones"
                    v-model="observaciones"
                    rows="4"
                    placeholder="Describa detalladamente el motivo del bloqueo/desbloqueo..."
                    :class="{ 'is-invalid': validationErrors.observaciones }"
                    maxlength="500"
                    required
                  ></textarea>
                  <div v-if="validationErrors.observaciones" class="invalid-feedback">
                    {{ validationErrors.observaciones }}
                  </div>
                  <div class="form-text d-flex justify-content-between">
                    <span><i class="fas fa-pencil-alt me-1"></i>Mínimo 10 caracteres</span>
                    <span class="text-muted">{{ observaciones.length }}/500</span>
                  </div>
                </div>

                <!-- Acciones -->
                <div class="col-md-3 d-flex flex-column justify-content-end">
                  <div class="d-grid gap-3">
                    <!-- Validar Acción -->
                    <button
                      type="button"
                      class="btn btn-outline-municipal"
                      @click="validarAccion"
                      :disabled="!tipoBloqueoSeleccionado || !observaciones.trim()"
                    >
                      <i class="fas fa-check-circle me-2"></i>
                      Validar
                    </button>

                    <!-- Bloquear -->
                    <button
                      v-if="licenciaEncontrada.bloqueado === 0"
                      type="submit"
                      class="btn btn-danger btn-lg shadow"
                      :disabled="procesando || !isFormValid || !validacionPasada"
                    >
                      <i class="fas fa-lock me-2"></i>
                      <span v-if="procesando">
                        <span class="spinner-border spinner-border-sm me-2"></span>
                        Bloqueando...
                      </span>
                      <span v-else>Bloquear Licencia</span>
                    </button>

                    <!-- Desbloquear -->
                    <button
                      v-if="licenciaEncontrada.bloqueado > 0"
                      type="submit"
                      class="btn btn-success btn-lg shadow"
                      :disabled="procesando || !isFormValid || !validacionPasada"
                    >
                      <i class="fas fa-unlock me-2"></i>
                      <span v-if="procesando">
                        <span class="spinner-border spinner-border-sm me-2"></span>
                        Desbloqueando...
                      </span>
                      <span v-else>Desbloquear Licencia</span>
                    </button>
                  </div>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>

      <!-- Enhanced History Section -->
      <div v-if="licenciaEncontrada" class="history-section">
        <div class="card border-0 shadow-lg">
          <div class="card-header border-0 bg-white p-4">
            <div class="d-flex justify-content-between align-items-center">
              <div>
                <h5 class="mb-2 text-municipal fw-bold">
                  <i class="fas fa-history me-2 text-municipal"></i>
                  Historial de Movimientos
                  <span v-if="totalRegistros > 0" class="badge bg-secondary ms-2">{{ totalRegistros }}</span>
                </h5>
              </div>
              <div class="d-flex gap-2 align-items-center">
                <select
                  v-model="limitePorPagina"
                  class="form-select form-select-sm"
                  @change="cargarHistorial"
                  style="width: auto;"
                >
                  <option value="5">5 por página</option>
                  <option value="10">10 por página</option>
                  <option value="25">25 por página</option>
                  <option value="50">50 por página</option>
                </select>
                <button
                  type="button"
                  class="btn btn-outline-municipal btn-sm"
                  @click="cargarHistorial"
                  :disabled="cargandoHistorial"
                  title="Actualizar historial"
                >
                  <i class="fas fa-sync-alt" :class="{ 'fa-spin': cargandoHistorial }"></i>
                </button>
              </div>
            </div>
          </div>
          <div class="card-body p-0">
            <!-- Loading State -->
            <div v-if="cargandoHistorial" class="p-4 text-center">
              <div class="spinner-border text-municipal" role="status">
                <span class="visually-hidden">Cargando historial...</span>
              </div>
              <p class="mt-3 mb-0 text-muted">
                <i class="fas fa-clock me-2"></i>
                Cargando historial de movimientos...
              </p>
            </div>

            <!-- Empty State -->
            <div v-else-if="historialBloqueos.length === 0" class="p-4 text-center text-muted">
              <i class="fas fa-inbox fa-3x mb-3 text-muted"></i>
              <h6>No hay movimientos registrados</h6>
              <p class="mb-0">Esta licencia no tiene historial de bloqueos/desbloqueos</p>
            </div>

            <!-- History Table -->
            <div v-else>
              <div class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead class="table-dark">
                    <tr>
                      <th>Fecha y Hora</th>
                      <th>Estado</th>
                      <th>Tipo</th>
                      <th>Capturista</th>
                      <th>Observaciones</th>
                      <th class="text-center">Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(bloqueo, index) in historialBloqueos" :key="bloqueo.id_bloqueo"
                        class="align-middle">
                      <td>
                        <div class="d-flex flex-column">
                          <span class="fw-semibold">{{ formatearFecha(bloqueo.fecha_mov) }}</span>
                          <small class="text-muted">{{ formatearHora(bloqueo.fecha_mov) }}</small>
                        </div>
                      </td>
                      <td>
                        <span class="badge" :class="getEstadoBadgeClass(bloqueo.bloqueado)">
                          <i class="fas" :class="getEstadoIcon(bloqueo.bloqueado)"></i>
                          {{ getEstadoBloqueo(bloqueo.bloqueado) }}
                        </span>
                      </td>
                      <td>
                        <span class="fw-semibold">{{ getTipoBloqueoNombre(bloqueo.bloqueado) }}</span>
                        <div v-if="bloqueo.motivo_legal" class="small text-muted">
                          {{ bloqueo.motivo_legal }}
                        </div>
                      </td>
                      <td>
                        <div class="d-flex align-items-center">
                          <i class="fas fa-user-circle me-2 text-muted"></i>
                          {{ bloqueo.capturista || 'Sistema' }}
                        </div>
                      </td>
                      <td>
                        <div class="text-truncate" style="max-width: 250px;" :title="bloqueo.observa">
                          {{ bloqueo.observa || 'Sin observaciones' }}
                        </div>
                      </td>
                      <td class="text-center">
                        <button
                          type="button"
                          class="btn btn-outline-info btn-sm"
                          @click="verDetalleMovimiento(bloqueo)"
                          title="Ver detalles completos"
                        >
                          <i class="fas fa-eye"></i>
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <!-- Enhanced Pagination -->
              <div class="card-footer bg-light d-flex justify-content-between align-items-center">
                <small class="text-muted">
                  Mostrando {{ ((paginaActual - 1) * limitePorPagina) + 1 }} a
                  {{ Math.min(paginaActual * limitePorPagina, totalRegistros) }} de
                  {{ totalRegistros }} registros
                </small>
                <nav aria-label="Paginación del historial" v-if="totalPaginas > 1">
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
                      <button class="page-link" @click="cambiarPagina(pagina)" v-if="typeof pagina === 'number'">
                        {{ pagina }}
                      </button>
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
      </div>

      <!-- Enhanced Movement Detail Modal -->
      <div v-if="movimientoSeleccionado" class="modal fade show d-block" style="background-color: rgba(0,0,0,0.5);">
        <div class="modal-dialog modal-lg">
          <div class="modal-content border-0 shadow-lg">
            <div class="modal-header municipal-gradient text-white border-0">
              <h5 class="modal-title fw-bold">
                <i class="fas fa-info-circle me-2"></i>
                Detalle del Movimiento
              </h5>
              <button type="button" class="btn-close btn-close-white" @click="movimientoSeleccionado = null"></button>
            </div>
            <div class="modal-body p-4">
              <div class="row g-4">
                <div class="col-md-6">
                  <label class="form-label fw-semibold text-muted small">FECHA Y HORA</label>
                  <div class="info-value">{{ formatearFechaCompleta(movimientoSeleccionado.fecha_mov) }}</div>
                </div>
                <div class="col-md-6">
                  <label class="form-label fw-semibold text-muted small">ESTADO RESULTANTE</label>
                  <div>
                    <span class="badge fs-6" :class="getEstadoBadgeClass(movimientoSeleccionado.bloqueado)">
                      <i class="fas" :class="getEstadoIcon(movimientoSeleccionado.bloqueado)"></i>
                      {{ getEstadoBloqueo(movimientoSeleccionado.bloqueado) }}
                    </span>
                  </div>
                </div>
                <div class="col-md-6">
                  <label class="form-label fw-semibold text-muted small">TIPO DE MOVIMIENTO</label>
                  <div class="info-value">{{ getTipoBloqueoNombre(movimientoSeleccionado.bloqueado) }}</div>
                </div>
                <div class="col-md-6">
                  <label class="form-label fw-semibold text-muted small">CAPTURISTA</label>
                  <div class="info-value">
                    <i class="fas fa-user-circle me-2 text-muted"></i>
                    {{ movimientoSeleccionado.capturista || 'Sistema automático' }}
                  </div>
                </div>
                <div class="col-md-6">
                  <label class="form-label fw-semibold text-muted small">ID DEL MOVIMIENTO</label>
                  <div class="info-value">{{ movimientoSeleccionado.id_bloqueo || 'N/A' }}</div>
                </div>
                <div class="col-md-6">
                  <label class="form-label fw-semibold text-muted small">VIGENCIA</label>
                  <div class="info-value">
                    <span class="badge" :class="movimientoSeleccionado.vigente === 'V' ? 'bg-success' : 'bg-secondary'">
                      {{ movimientoSeleccionado.vigente === 'V' ? 'VIGENTE' : 'CANCELADO' }}
                    </span>
                  </div>
                </div>
                <div v-if="movimientoSeleccionado.motivo_legal" class="col-12">
                  <label class="form-label fw-semibold text-muted small">MOTIVO LEGAL</label>
                  <div class="info-value bg-light rounded p-2">{{ movimientoSeleccionado.motivo_legal }}</div>
                </div>
                <div class="col-12">
                  <label class="form-label fw-semibold text-muted small">OBSERVACIONES COMPLETAS</label>
                  <div class="info-value bg-light rounded p-3" style="white-space: pre-wrap;">
                    {{ movimientoSeleccionado.observa || 'Sin observaciones registradas' }}
                  </div>
                </div>
              </div>
            </div>
            <div class="modal-footer border-0">
              <button type="button" class="btn btn-outline-municipal" @click="movimientoSeleccionado = null">
                <i class="fas fa-times me-2"></i>
                Cerrar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Enhanced Statistics Modal -->
      <div v-if="mostrandoEstadisticas" class="modal fade show d-block" style="background-color: rgba(0,0,0,0.5);">
        <div class="modal-dialog modal-xl">
          <div class="modal-content border-0 shadow-lg">
            <div class="modal-header municipal-gradient text-white border-0">
              <h5 class="modal-title fw-bold">
                <i class="fas fa-chart-bar me-2"></i>
                Estadísticas del Sistema de Bloqueos
              </h5>
              <button type="button" class="btn-close btn-close-white" @click="mostrandoEstadisticas = false"></button>
            </div>
            <div class="modal-body p-4">
              <div v-if="cargandoEstadisticas" class="text-center p-4">
                <div class="spinner-border text-municipal" role="status"></div>
                <p class="mt-3">Cargando estadísticas...</p>
              </div>
              <div v-else-if="estadisticas" class="row g-4">
                <!-- Estadísticas generales -->
                <div class="col-md-3">
                  <div class="stat-card bg-primary text-white rounded p-3">
                    <div class="d-flex align-items-center">
                      <i class="fas fa-file-contract fa-2x me-3"></i>
                      <div>
                        <div class="h4 mb-0">{{ estadisticas.total_licencias }}</div>
                        <small>Total Licencias</small>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="stat-card bg-danger text-white rounded p-3">
                    <div class="d-flex align-items-center">
                      <i class="fas fa-lock fa-2x me-3"></i>
                      <div>
                        <div class="h4 mb-0">{{ estadisticas.licencias_bloqueadas }}</div>
                        <small>Bloqueadas</small>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="stat-card bg-success text-white rounded p-3">
                    <div class="d-flex align-items-center">
                      <i class="fas fa-unlock fa-2x me-3"></i>
                      <div>
                        <div class="h4 mb-0">{{ estadisticas.licencias_activas }}</div>
                        <small>Activas</small>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="stat-card bg-info text-white rounded p-3">
                    <div class="d-flex align-items-center">
                      <i class="fas fa-percentage fa-2x me-3"></i>
                      <div>
                        <div class="h4 mb-0">{{ estadisticas.porcentaje_bloqueos.toFixed(1) }}%</div>
                        <small>% Bloqueadas</small>
                      </div>
                    </div>
                  </div>
                </div>
                <!-- Más estadísticas -->
                <div class="col-12">
                  <div class="row g-3">
                    <div class="col-md-6">
                      <div class="bg-light rounded p-3">
                        <h6 class="text-municipal">Movimientos del Mes</h6>
                        <div class="d-flex justify-content-between">
                          <span>Bloqueos: <strong>{{ estadisticas.bloqueos_mes_actual }}</strong></span>
                          <span>Desbloqueos: <strong>{{ estadisticas.desbloqueos_mes_actual }}</strong></span>
                        </div>
                      </div>
                    </div>
                    <div class="col-md-6">
                      <div class="bg-light rounded p-3">
                        <h6 class="text-municipal">Tipo Más Común</h6>
                        <div class="fw-semibold">{{ estadisticas.tipo_bloqueo_mas_comun || 'N/A' }}</div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="modal-footer border-0">
              <button type="button" class="btn btn-outline-municipal" @click="mostrandoEstadisticas = false">
                <i class="fas fa-times me-2"></i>
                Cerrar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Enhanced Toast Notifications -->
      <div v-if="mensaje" class="position-fixed top-0 end-0 p-3" style="z-index: 1050">
        <div class="toast show border-0 shadow-lg" role="alert" aria-live="polite">
          <div class="toast-header border-0" :class="mensaje.tipo === 'success' ? 'bg-success text-white' : 'bg-danger text-white'">
            <i class="fas me-2" :class="mensaje.tipo === 'success' ? 'fa-check-circle' : 'fa-exclamation-triangle'" aria-hidden="true"></i>
            <strong class="me-auto">{{ mensaje.tipo === 'success' ? 'Operación Exitosa' : 'Error en la Operación' }}</strong>
            <button type="button" class="btn-close btn-close-white" @click="mensaje = null" aria-label="Cerrar notificación"></button>
          </div>
          <div class="toast-body">
            {{ mensaje.texto }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue'

export default {
  name: 'BloquearLicenciafrm',
  setup() {
    // Reactive data
    const numeroLicencia = ref('')
    const licenciaEncontrada = ref(null)
    const tiposBloqueo = ref([])
    const tipoBloqueoSeleccionado = ref('')
    const observaciones = ref('')
    const historialBloqueos = ref([])
    const buscando = ref(false)
    const procesando = ref(false)
    const cargandoHistorial = ref(false)
    const cargandoTipos = ref(false)
    const cargandoEstadisticas = ref(false)
    const mensaje = ref(null)
    const ultimaBusqueda = ref('')
    const validacionPasada = ref(false)
    const mostrandoEstadisticas = ref(false)
    const estadisticas = ref(null)

    // Validation errors
    const validationErrors = ref({
      numeroLicencia: '',
      tipoBloqueo: '',
      observaciones: ''
    })

    // Pagination
    const paginaActual = ref(1)
    const limitePorPagina = ref(10)
    const totalRegistros = ref(0)
    const movimientoSeleccionado = ref(null)

    // Computed properties
    const totalPaginas = computed(() => {
      return Math.ceil(totalRegistros.value / limitePorPagina.value)
    })

    const isValidLicenciaNumber = computed(() => {
      const num = parseInt(numeroLicencia.value)
      return num >= 1 && num <= 999999
    })

    const isFormValid = computed(() => {
      return tipoBloqueoSeleccionado.value &&
             observaciones.value.trim().length >= 10 &&
             observaciones.value.trim().length <= 500
    })

    const paginasVisibles = computed(() => {
      const total = totalPaginas.value
      const actual = paginaActual.value
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

    // Methods
    const limpiarValidaciones = () => {
      validationErrors.value = {
        numeroLicencia: '',
        tipoBloqueo: '',
        observaciones: ''
      }
    }

    const validarFormulario = () => {
      limpiarValidaciones()
      let valido = true

      if (!numeroLicencia.value || !isValidLicenciaNumber.value) {
        validationErrors.value.numeroLicencia = 'Número de licencia inválido (1-999999)'
        valido = false
      }

      if (!tipoBloqueoSeleccionado.value) {
        validationErrors.value.tipoBloqueo = 'Seleccione un tipo de bloqueo'
        valido = false
      }

      if (!observaciones.value.trim()) {
        validationErrors.value.observaciones = 'Las observaciones son obligatorias'
        valido = false
      } else if (observaciones.value.trim().length < 10) {
        validationErrors.value.observaciones = 'Mínimo 10 caracteres'
        valido = false
      } else if (observaciones.value.trim().length > 500) {
        validationErrors.value.observaciones = 'Máximo 500 caracteres'
        valido = false
      }

      return valido
    }

    const buscarLicencia = async () => {
      if (!numeroLicencia.value || !isValidLicenciaNumber.value) {
        mostrarMensaje('error', 'Ingrese un número de licencia válido')
        return
      }

      buscando.value = true

      // Optimización: Reset de estado centralizado
      resetearEstado()

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'buscar_licencia',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'numero_licencia', valor: parseInt(numeroLicencia.value), tipo: 'integer' }
              ],
              Tenant: 'guadalajara'
            }
          })
        })

        const data = await response.json()

        if (data.eResponse.success && data.eResponse.data.result.length > 0) {
          licenciaEncontrada.value = data.eResponse.data.result[0]
          ultimaBusqueda.value = new Date().toLocaleTimeString('es-MX')
          mostrarMensaje('success', `Licencia ${numeroLicencia.value} encontrada`)

          // Optimización: Carga paralela de datos
          await Promise.all([
            cargarTiposBloqueo(),
            cargarHistorial()
          ])
        } else {
          mostrarMensaje('error', `No se encontró la licencia ${numeroLicencia.value}`)
        }

      } catch (error) {
        console.error('Error buscando licencia:', error)
        mostrarMensaje('error', 'Error al buscar la licencia. Verifique la conexión.')
      } finally {
        buscando.value = false
      }
    }

    const refrescarLicencia = async () => {
      if (!numeroLicencia.value) return
      await buscarLicencia()
    }

    const cargarTiposBloqueo = async () => {
      cargandoTipos.value = true

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_tipobloqueo_list',
              Base: 'padron_licencias',
              Parametros: [],
              Tenant: 'guadalajara'
            }
          })
        })

        const data = await response.json()

        if (data.eResponse.success) {
          tiposBloqueo.value = data.eResponse.data.result || []
        }

      } catch (error) {
        console.error('Error cargando tipos de bloqueo:', error)
        mostrarMensaje('error', 'Error al cargar tipos de bloqueo')
      } finally {
        cargandoTipos.value = false
      }
    }

    const validarAccion = async () => {
      if (!validarFormulario()) return

      try {
        const accion = licenciaEncontrada.value.bloqueado === 0 ? 'BLOQUEAR' : 'DESBLOQUEAR'

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_validar_bloqueo_licencia',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id_licencia', valor: licenciaEncontrada.value.id_licencia, tipo: 'integer' },
                { nombre: 'p_accion', valor: accion, tipo: 'string' },
                { nombre: 'p_tipo_bloqueo', valor: parseInt(tipoBloqueoSeleccionado.value), tipo: 'integer' }
              ],
              Tenant: 'guadalajara'
            }
          })
        })

        const data = await response.json()

        if (data.eResponse.success && data.eResponse.data.result.length > 0) {
          const resultado = data.eResponse.data.result[0]
          if (resultado.puede_proceder === 1) {
            validacionPasada.value = true
            mostrarMensaje('success', 'Validación exitosa. Puede proceder con la operación.')
          } else {
            validacionPasada.value = false
            mostrarMensaje('error', resultado.mensaje)
          }
        }

      } catch (error) {
        console.error('Error validando acción:', error)
        mostrarMensaje('error', 'Error en la validación')
        validacionPasada.value = false
      }
    }

    const procesarAccion = async () => {
      if (!isFormValid.value || !validacionPasada.value) {
        await validarAccion()
        return
      }

      if (licenciaEncontrada.value.bloqueado === 0) {
        await bloquearLicencia()
      } else {
        await desbloquearLicencia()
      }
    }

    const bloquearLicencia = async () => {
      procesando.value = true

      try {
        const eRequest = {
          Operacion: 'sp_bloquear_licencia',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_id_licencia', valor: licenciaEncontrada.value.id_licencia, tipo: 'integer' },
            { nombre: 'p_tipo_bloqueo', valor: parseInt(tipoBloqueoSeleccionado.value), tipo: 'integer' },
            { nombre: 'p_motivo', valor: observaciones.value.trim(), tipo: 'string' },
            { nombre: 'p_usuario', valor: obtenerUsuario(), tipo: 'string' }
          ],
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest: eRequest })
        })

        const data = await response.json()

        if (data.eResponse.success && data.eResponse.data.result[0]?.success === 1) {
          // Optimización: Actualización de estado optimista
          licenciaEncontrada.value.bloqueado = parseInt(tipoBloqueoSeleccionado.value)
          limpiarFormularioAccion()
          mostrarMensaje('success', data.eResponse.data.result[0].message)
          await cargarHistorial()
        } else {
          mostrarMensaje('error', data.eResponse.data.result[0]?.message || 'Error al bloquear licencia')
        }

      } catch (error) {
        console.error('Error bloqueando licencia:', error)
        mostrarMensaje('error', 'Error al bloquear la licencia')
      } finally {
        procesando.value = false
      }
    }

    const desbloquearLicencia = async () => {
      procesando.value = true

      try {
        const eRequest = {
          Operacion: 'sp_desbloquear_licencia',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_id_licencia', valor: licenciaEncontrada.value.id_licencia, tipo: 'integer' },
            { nombre: 'p_tipo_bloqueo', valor: parseInt(tipoBloqueoSeleccionado.value), tipo: 'integer' },
            { nombre: 'p_motivo', valor: observaciones.value.trim(), tipo: 'string' },
            { nombre: 'p_usuario', valor: obtenerUsuario(), tipo: 'string' }
          ],
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest: eRequest })
        })

        const data = await response.json()

        if (data.eResponse.success && data.eResponse.data.result[0]?.success === 1) {
          // Optimización: Actualización de estado optimista
          licenciaEncontrada.value.bloqueado = 0
          limpiarFormularioAccion()
          mostrarMensaje('success', data.eResponse.data.result[0].message)
          await cargarHistorial()
        } else {
          mostrarMensaje('error', data.eResponse.data.result[0]?.message || 'Error al desbloquear licencia')
        }

      } catch (error) {
        console.error('Error desbloqueando licencia:', error)
        mostrarMensaje('error', 'Error al desbloquear la licencia')
      } finally {
        procesando.value = false
      }
    }

    const cargarHistorial = async () => {
      if (!licenciaEncontrada.value) return

      cargandoHistorial.value = true

      try {
        const offset = (paginaActual.value - 1) * limitePorPagina.value

        // Optimización: Intentar primero el endpoint paginado, luego fallback
        const eRequestPaginado = {
          Operacion: 'sp_consultar_historial_licencia_paginado',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_id_licencia', valor: licenciaEncontrada.value.id_licencia, tipo: 'integer' },
            { nombre: 'limit_records', valor: limitePorPagina.value, tipo: 'integer' },
            { nombre: 'offset_records', valor: offset, tipo: 'integer' }
          ],
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequestPaginado)
        })

        const data = await response.json()

        if (data.eResponse.success) {
          const result = data.eResponse.data.result || []

          if (result.length > 0 && result[0].total_registros !== undefined) {
            totalRegistros.value = parseInt(result[0].total_registros)
            historialBloqueos.value = result
            return
          }
        }

        // Fallback a carga completa si no funciona la paginación
        await cargarHistorialCompleto()

      } catch (error) {
        console.error('Error cargando historial:', error)
        await cargarHistorialCompleto()
      } finally {
        cargandoHistorial.value = false
      }
    }

    const cargarHistorialCompleto = async () => {
      try {
        const eRequest = {
          Operacion: 'sp_consultar_historial_licencia',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_id_licencia', valor: licenciaEncontrada.value.id_licencia, tipo: 'integer' }
          ],
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest: eRequest })
        })

        const data = await response.json()

        if (data.eResponse.success) {
          const allRecords = data.eResponse.data.result || []
          totalRegistros.value = allRecords.length

          const start = (paginaActual.value - 1) * limitePorPagina.value
          const end = start + limitePorPagina.value
          historialBloqueos.value = allRecords.slice(start, end)
        }

      } catch (error) {
        console.error('Error cargando historial completo:', error)
        historialBloqueos.value = []
        totalRegistros.value = 0
      }
    }

    const cargarEstadisticas = async () => {
      cargandoEstadisticas.value = true

      try {
        const eRequest = {
          Operacion: 'sp_estadisticas_bloqueos',
          Base: 'padron_licencias',
          Parametros: [],
          Tenant: 'guadalajara'
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest: eRequest })
        })

        const data = await response.json()

        if (data.eResponse.success && data.eResponse.data.result.length > 0) {
          estadisticas.value = data.eResponse.data.result[0]
        }

      } catch (error) {
        console.error('Error cargando estadísticas:', error)
        mostrarMensaje('error', 'Error al cargar estadísticas')
      } finally {
        cargandoEstadisticas.value = false
      }
    }

    const cambiarPagina = (nuevaPagina) => {
      if (typeof nuevaPagina === 'number' && nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
        paginaActual.value = nuevaPagina
        cargarHistorial()
      }
    }

    const verDetalleMovimiento = (movimiento) => {
      movimientoSeleccionado.value = { ...movimiento }
    }

    // Optimización: Función auxiliar para reset de estado
    const resetearEstado = () => {
      licenciaEncontrada.value = null
      historialBloqueos.value = []
      observaciones.value = ''
      tipoBloqueoSeleccionado.value = ''
      validacionPasada.value = false
      paginaActual.value = 1
      totalRegistros.value = 0
      movimientoSeleccionado.value = null
      limpiarValidaciones()
    }

    const limpiarFormulario = () => {
      numeroLicencia.value = ''
      tiposBloqueo.value = []
      resetearEstado()
    }

    const mostrarEstadisticas = async () => {
      mostrandoEstadisticas.value = true
      await cargarEstadisticas()
    }

    // Optimización: Función auxiliar para limpiar formulario de acción
    const limpiarFormularioAccion = () => {
      observaciones.value = ''
      tipoBloqueoSeleccionado.value = ''
      validacionPasada.value = false
    }

    // Utility methods optimizados
    const formatearFecha = (fecha) => {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleDateString('es-MX')
    }

    const formatearHora = (fecha) => {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleTimeString('es-MX')
    }

    const formatearFechaCompleta = (fecha) => {
      if (!fecha) return 'N/A'
      return new Date(fecha).toLocaleString('es-MX', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      })
    }

    const formatearMoneda = (cantidad) => {
      if (!cantidad || cantidad === 0) return '$0.00'
      return new Intl.NumberFormat('es-MX', {
        style: 'currency',
        currency: 'MXN'
      }).format(cantidad)
    }

    const getEstadoLicencia = (bloqueado) => {
      return bloqueado === 0 ? 'ACTIVA' : `BLOQUEADA (TIPO ${bloqueado})`
    }

    const getEstadoBloqueo = (bloqueado) => {
      return bloqueado === 0 ? 'DESBLOQUEADO' : 'BLOQUEADO'
    }

    const getEstadoBadgeClass = (bloqueado) => {
      return bloqueado === 0 ? 'bg-success' : 'bg-danger'
    }

    const getEstadoIcon = (bloqueado) => {
      return bloqueado === 0 ? 'fa-unlock' : 'fa-lock'
    }

    const getVigenciaBadgeClass = (dias) => {
      if (dias > 30) return 'bg-success'
      if (dias > 0) return 'bg-warning'
      return 'bg-danger'
    }

    const getVigenciaTexto = (dias) => {
      if (dias > 30) return `${dias} días restantes`
      if (dias > 0) return `Vence en ${dias} días`
      return `Vencida hace ${Math.abs(dias)} días`
    }

    const getVigenciaClass = (fecha) => {
      if (!fecha) return 'text-muted'
      const dias = Math.ceil((new Date(fecha) - new Date()) / (1000 * 60 * 60 * 24))
      if (dias > 30) return 'text-success'
      if (dias > 0) return 'text-warning'
      return 'text-danger'
    }

    const getVigenciaProgress = (dias) => {
      const maxDias = 365
      if (dias <= 0) return 0
      if (dias > maxDias) return 100
      return (dias / maxDias) * 100
    }

    const getVigenciaProgressClass = (dias) => {
      if (dias > 30) return 'bg-success'
      if (dias > 0) return 'bg-warning'
      return 'bg-danger'
    }

    const getVigenciaDetalles = (dias) => {
      if (dias > 30) return 'Licencia vigente'
      if (dias > 0) return 'Próxima a vencer'
      return 'Licencia vencida'
    }

    const getTipoBloqueoNombre = (bloqueadoId) => {
      if (bloqueadoId === 0) return 'DESBLOQUEADO'
      const tipo = tiposBloqueo.value.find(t => t.id === bloqueadoId)
      return tipo ? tipo.descripcion : `Tipo ${bloqueadoId}`
    }

    const getTipoBloqueoInfo = (tipoId) => {
      const tipo = tiposBloqueo.value.find(t => t.id === parseInt(tipoId))
      if (!tipo) return ''

      let info = []
      if (tipo.requiere_apelacion === 'S') {
        info.push('Requiere proceso de apelación')
      }
      if (tipo.multa_base > 0) {
        info.push(`Multa base: ${formatearMoneda(tipo.multa_base)}`)
      }
      return info.join(' • ')
    }

    const mostrarMensaje = (tipo, texto) => {
      mensaje.value = { tipo, texto }
      // Optimización: Timeouts más cortos para mejor UX
      const timeout = tipo === 'success' ? 3000 : 5000
      setTimeout(() => {
        mensaje.value = null
      }, timeout)
    }

    const obtenerUsuario = () => {
      return (window.user && window.user.username) || 'admin'
    }

    // Watchers
    watch(() => limitePorPagina.value, () => {
      paginaActual.value = 1
    })

    // Lifecycle
    onMounted(() => {
      console.log('🚀 BloquearLicenciafrm (Vue 3 Composition API) cargado')
    })

    return {
      // Reactive data
      numeroLicencia,
      licenciaEncontrada,
      tiposBloqueo,
      tipoBloqueoSeleccionado,
      observaciones,
      historialBloqueos,
      buscando,
      procesando,
      cargandoHistorial,
      cargandoTipos,
      cargandoEstadisticas,
      mensaje,
      ultimaBusqueda,
      validacionPasada,
      mostrandoEstadisticas,
      estadisticas,
      validationErrors,
      paginaActual,
      limitePorPagina,
      totalRegistros,
      movimientoSeleccionado,

      // Computed
      totalPaginas,
      isValidLicenciaNumber,
      isFormValid,
      paginasVisibles,

      // Methods
      buscarLicencia,
      refrescarLicencia,
      cargarTiposBloqueo,
      validarAccion,
      procesarAccion,
      bloquearLicencia,
      desbloquearLicencia,
      cargarHistorial,
      cambiarPagina,
      verDetalleMovimiento,
      limpiarFormulario,
      resetearEstado,
      limpiarFormularioAccion,
      mostrarEstadisticas,
      formatearFecha,
      formatearHora,
      formatearFechaCompleta,
      formatearMoneda,
      getEstadoLicencia,
      getEstadoBloqueo,
      getEstadoBadgeClass,
      getEstadoIcon,
      getVigenciaBadgeClass,
      getVigenciaTexto,
      getVigenciaClass,
      getVigenciaProgress,
      getVigenciaProgressClass,
      getVigenciaDetalles,
      getTipoBloqueoNombre,
      getTipoBloqueoInfo,
      mostrarMensaje,
      obtenerUsuario
    }
  }
}
</script>

<style scoped>
/* Optimized Municipal Styles */
.municipal-app {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
  min-height: 100vh;
}

.municipal-header {
  background: linear-gradient(135deg, var(--municipal-primary, #ea8215) 0%, var(--municipal-secondary, #cc9f52) 100%);
  border-bottom: 3px solid rgba(255, 255, 255, 0.2);
}

.gradient-header {
  position: relative;
  overflow: hidden;
}

/* Optimización: Grid pattern simplificado */
.gradient-header::before {
  content: '';
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px);
  background-size: 20px 20px;
  opacity: 0.3;
}

.text-white-75 {
  color: rgba(255, 255, 255, 0.75) !important;
}

.icon-circle {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.municipal-gradient {
  background: linear-gradient(135deg, var(--municipal-primary, #ea8215) 0%, var(--municipal-secondary, #cc9f52) 100%);
}

.btn-municipal {
  background: linear-gradient(135deg, var(--municipal-primary, #ea8215) 0%, var(--municipal-secondary, #cc9f52) 100%);
  border: none;
  color: white;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn-municipal:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(234, 130, 21, 0.3);
  color: white;
}

.btn-municipal-outline {
  border: 2px solid var(--municipal-primary, #ea8215);
  color: var(--municipal-primary, #ea8215);
  background: white;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn-municipal-outline:hover {
  background: var(--municipal-primary, #ea8215);
  color: white;
  transform: translateY(-1px);
}

.btn-outline-municipal {
  border: 2px solid var(--municipal-primary, #ea8215);
  color: var(--municipal-primary, #ea8215);
  background: white;
  font-weight: 600;
}

.btn-outline-municipal:hover {
  background: var(--municipal-primary, #ea8215);
  color: white;
  border-color: var(--municipal-primary, #ea8215);
}

.text-municipal {
  color: var(--municipal-primary, #ea8215) !important;
}

.bg-municipal {
  background-color: var(--municipal-primary, #ea8215) !important;
}

.info-value {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 0.375rem;
  padding: 0.5rem 0.75rem;
  font-weight: 500;
  min-height: 38px;
  display: flex;
  align-items: center;
}

.info-group {
  background: white;
  border-radius: 0.75rem;
  padding: 1.5rem;
  border: 1px solid #e2e8f0;
  transition: all 0.3s ease;
}

.info-group:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.search-form .form-control:focus,
.block-form .form-control:focus,
.block-form .form-select:focus {
  border-color: var(--municipal-primary, #ea8215);
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
}

.toast {
  min-width: 350px;
  border-radius: 0.75rem;
  backdrop-filter: blur(10px);
}

.table-hover tbody tr:hover {
  background-color: rgba(234, 130, 21, 0.05);
}

.stat-card {
  transition: all 0.3s ease;
  border-radius: 1rem;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
}

.municipal-breadcrumb {
  backdrop-filter: blur(10px);
}

.license-status-indicators .badge {
  font-size: 0.875rem;
  padding: 0.5rem 1rem;
  border-radius: 2rem;
}

.search-stats {
  border: 2px dashed #e2e8f0;
  transition: all 0.3s ease;
}

.search-stats:hover {
  border-color: var(--municipal-primary, #ea8215);
  background-color: rgba(234, 130, 21, 0.05) !important;
}

.progress {
  border-radius: 1rem;
  overflow: hidden;
}

.progress-bar {
  transition: width 0.6s ease;
}

@media (max-width: 768px) {
  .municipal-header {
    padding: 1rem !important;
  }

  .municipal-header h1 {
    font-size: 1.5rem !important;
  }

  .header-actions {
    display: none;
  }

  .control-actions .btn-group {
    flex-wrap: wrap;
  }

  .status-indicators {
    flex-direction: column;
    align-items: flex-end;
  }

  .info-group {
    padding: 1rem;
  }
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
  .municipal-app {
    background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
  }

  .info-value {
    background: #334155;
    border-color: #475569;
    color: #e2e8f0;
  }

  .info-group {
    background: #1e293b;
    border-color: #475569;
  }
}

/* Optimized Loading animations */
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.fa-spin {
  animation: fa-spin 2s infinite linear;
}

@keyframes fa-spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(359deg); }
}

/* Accessibility improvements */
.btn:focus {
  outline: 2px solid var(--municipal-primary, #ea8215);
  outline-offset: 2px;
}

.form-control:focus,
.form-select:focus {
  outline: none;
}

/* Print styles */
@media print {
  .municipal-header,
  .municipal-controls,
  .btn,
  .modal {
    display: none !important;
  }

  .card {
    border: 1px solid #000 !important;
    box-shadow: none !important;
  }
}
</style>