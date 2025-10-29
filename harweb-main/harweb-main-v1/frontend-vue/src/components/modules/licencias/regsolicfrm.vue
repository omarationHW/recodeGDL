<template>
  <div class="regsolic-container">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/licencias">Licencias</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Registro de Solicitudes</li>
      </ol>
    </nav>

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h2 class="mb-0">Registro de Solicitudes</h2>
      <button
        class="btn btn-primary"
        @click="abrirModalCrear"
        :disabled="loading"
      >
        <i class="fas fa-plus"></i> Nueva Solicitud
      </button>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="card mb-4">
      <div class="card-header">
        <h5 class="mb-0">Filtros de Búsqueda</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="buscarSolicitudes">
          <div class="row">
            <div class="col-md-3 mb-3">
              <label class="form-label">Folio Solicitud</label>
              <input
                type="text"
                v-model="filtros.folio_solicitud"
                class="form-control"
                placeholder="Buscar por folio..."
              >
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Solicitante</label>
              <input
                type="text"
                v-model="filtros.solicitante"
                class="form-control"
                placeholder="Nombre del solicitante..."
              >
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">RFC</label>
              <input
                type="text"
                v-model="filtros.rfc"
                class="form-control"
                placeholder="RFC..."
              >
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Tipo Solicitud</label>
              <select v-model="filtros.tipo_solicitud" class="form-select">
                <option value="">Todos los tipos</option>
                <option value="LICENCIA_NUEVA">Licencia Nueva</option>
                <option value="RENOVACION">Renovación</option>
                <option value="MODIFICACION">Modificación</option>
                <option value="ANUNCIO_NUEVO">Anuncio Nuevo</option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Estado</label>
              <select v-model="filtros.estado" class="form-select">
                <option value="">Todos los estados</option>
                <option value="RECIBIDA">Recibida</option>
                <option value="EN_REVISION">En Revisión</option>
                <option value="OBSERVACIONES">Con Observaciones</option>
                <option value="APROBADA">Aprobada</option>
                <option value="RECHAZADA">Rechazada</option>
                <option value="CANCELADA">Cancelada</option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Giro</label>
              <input
                type="text"
                v-model="filtros.giro"
                class="form-control"
                placeholder="Giro solicitado..."
              >
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Fecha Desde</label>
              <input
                type="date"
                v-model="filtros.fecha_desde"
                class="form-control"
              >
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Fecha Hasta</label>
              <input
                type="date"
                v-model="filtros.fecha_hasta"
                class="form-control"
              >
            </div>
          </div>
          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary" :disabled="loading">
              <i class="fas fa-search"></i> Buscar
            </button>
            <button type="button" class="btn btn-secondary" @click="limpiarFiltros">
              <i class="fas fa-times"></i> Limpiar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-4">
      <div class="spinner-border" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div v-else class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          Solicitudes Registradas
          <span class="badge bg-secondary">{{ totalRegistros }}</span>
        </h5>
        <div class="d-flex gap-2">
          <!-- Estadísticas -->
          <button
            class="btn btn-info btn-sm"
            @click="mostrarEstadisticas"
          >
            <i class="fas fa-chart-bar"></i> Estadísticas
          </button>
        </div>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th>Folio</th>
                <th>Tipo</th>
                <th>Solicitante</th>
                <th>Giro</th>
                <th>Estado</th>
                <th>Fecha Solicitud</th>
                <th>Días</th>
                <th>Funcionario</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="solicitudes.length === 0">
                <td colspan="9" class="text-center py-4 text-muted">
                  No se encontraron solicitudes con los filtros aplicados
                </td>
              </tr>
              <tr v-for="solicitud in solicitudes" :key="solicitud.id">
                <td>
                  <strong>{{ solicitud.folio_solicitud }}</strong>
                  <br>
                  <small class="text-muted" v-if="solicitud.numero_tramite">
                    Trámite: {{ solicitud.numero_tramite }}
                  </small>
                </td>
                <td>
                  <span class="badge" :class="getBadgeClass(solicitud.tipo_solicitud)">
                    {{ formatTipoSolicitud(solicitud.tipo_solicitud) }}
                  </span>
                </td>
                <td>
                  <div>{{ solicitud.solicitante }}</div>
                  <small class="text-muted" v-if="solicitud.razon_social">
                    {{ solicitud.razon_social }}
                  </small>
                  <br>
                  <small class="text-muted" v-if="solicitud.rfc">
                    RFC: {{ solicitud.rfc }}
                  </small>
                </td>
                <td>
                  <small>{{ solicitud.giro_solicitado }}</small>
                </td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(solicitud.estado)">
                    {{ formatEstado(solicitud.estado) }}
                  </span>
                </td>
                <td>
                  {{ formatDate(solicitud.fecha_solicitud) }}
                  <br>
                  <small class="text-muted">
                    {{ formatDateTime(solicitud.fecha_recepcion) }}
                  </small>
                </td>
                <td>
                  <span
                    class="badge"
                    :class="solicitud.dias_transcurridos > 15 ? 'bg-danger' :
                           solicitud.dias_transcurridos > 10 ? 'bg-warning' : 'bg-success'"
                  >
                    {{ solicitud.dias_transcurridos }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    {{ solicitud.funcionario_revisor || 'Sin asignar' }}
                  </small>
                </td>
                <td>
                  <div class="btn-group" role="group">
                    <button
                      class="btn btn-sm btn-outline-primary"
                      @click="verDetalle(solicitud)"
                      title="Ver detalle"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn btn-sm btn-outline-warning"
                      @click="editarSolicitud(solicitud)"
                      title="Editar"
                      :disabled="solicitud.estado === 'APROBADA' || solicitud.estado === 'CANCELADA'"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      class="btn btn-sm btn-outline-info"
                      @click="cambiarEstado(solicitud)"
                      title="Cambiar estado"
                      :disabled="solicitud.estado === 'CANCELADA'"
                    >
                      <i class="fas fa-exchange-alt"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Paginación -->
      <div class="card-footer" v-if="totalRegistros > limite">
        <nav aria-label="Paginación de solicitudes">
          <ul class="pagination justify-content-center mb-0">
            <li class="page-item" :class="{ disabled: paginaActual === 1 }">
              <button
                class="page-link"
                @click="cambiarPagina(paginaActual - 1)"
                :disabled="paginaActual === 1"
              >
                Anterior
              </button>
            </li>
            <li
              v-for="pagina in paginasVisibles"
              :key="pagina"
              class="page-item"
              :class="{ active: pagina === paginaActual }"
            >
              <button class="page-link" @click="cambiarPagina(pagina)">
                {{ pagina }}
              </button>
            </li>
            <li class="page-item" :class="{ disabled: paginaActual === totalPaginas }">
              <button
                class="page-link"
                @click="cambiarPagina(paginaActual + 1)"
                :disabled="paginaActual === totalPaginas"
              >
                Siguiente
              </button>
            </li>
          </ul>
        </nav>
        <div class="text-center mt-2">
          <small class="text-muted">
            Mostrando {{ Math.min(limite, totalRegistros) }} de {{ totalRegistros }} registros
            (Página {{ paginaActual }} de {{ totalPaginas }})
          </small>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar Solicitud -->
    <div
      class="modal fade"
      tabindex="-1"
      v-if="showModalForm"
      :class="{ show: showModalForm }"
      style="display: block;"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              {{ modoEdicion ? 'Editar' : 'Nueva' }} Solicitud
            </h5>
            <button type="button" class="btn-close" @click="cerrarModalForm"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarSolicitud">
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label">Folio Solicitud *</label>
                  <input
                    type="text"
                    v-model="formData.folio_solicitud"
                    class="form-control"
                    :class="{ 'is-invalid': errors.folio_solicitud }"
                    required
                    :readonly="modoEdicion"
                  >
                  <div v-if="errors.folio_solicitud" class="invalid-feedback">
                    {{ errors.folio_solicitud }}
                  </div>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Tipo Solicitud *</label>
                  <select
                    v-model="formData.tipo_solicitud"
                    class="form-select"
                    :class="{ 'is-invalid': errors.tipo_solicitud }"
                    required
                  >
                    <option value="">Seleccionar tipo</option>
                    <option value="LICENCIA_NUEVA">Licencia Nueva</option>
                    <option value="RENOVACION">Renovación</option>
                    <option value="MODIFICACION">Modificación</option>
                    <option value="ANUNCIO_NUEVO">Anuncio Nuevo</option>
                  </select>
                  <div v-if="errors.tipo_solicitud" class="invalid-feedback">
                    {{ errors.tipo_solicitud }}
                  </div>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Solicitante *</label>
                  <input
                    type="text"
                    v-model="formData.solicitante"
                    class="form-control"
                    :class="{ 'is-invalid': errors.solicitante }"
                    required
                  >
                  <div v-if="errors.solicitante" class="invalid-feedback">
                    {{ errors.solicitante }}
                  </div>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Razón Social</label>
                  <input
                    type="text"
                    v-model="formData.razon_social"
                    class="form-control"
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">RFC</label>
                  <input
                    type="text"
                    v-model="formData.rfc"
                    class="form-control"
                    maxlength="20"
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">CURP</label>
                  <input
                    type="text"
                    v-model="formData.curp"
                    class="form-control"
                    maxlength="20"
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Teléfono</label>
                  <input
                    type="text"
                    v-model="formData.telefono"
                    class="form-control"
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Email</label>
                  <input
                    type="email"
                    v-model="formData.email"
                    class="form-control"
                  >
                </div>
                <div class="col-md-8 mb-3">
                  <label class="form-label">Dirección del Negocio *</label>
                  <textarea
                    v-model="formData.direccion_negocio"
                    class="form-control"
                    :class="{ 'is-invalid': errors.direccion_negocio }"
                    rows="3"
                    required
                  ></textarea>
                  <div v-if="errors.direccion_negocio" class="invalid-feedback">
                    {{ errors.direccion_negocio }}
                  </div>
                </div>
                <div class="col-md-4 mb-3">
                  <label class="form-label">Colonia</label>
                  <input
                    type="text"
                    v-model="formData.colonia"
                    class="form-control"
                  >
                </div>
                <div class="col-md-12 mb-3">
                  <label class="form-label">Giro Solicitado *</label>
                  <input
                    type="text"
                    v-model="formData.giro_solicitado"
                    class="form-control"
                    :class="{ 'is-invalid': errors.giro_solicitado }"
                    required
                  >
                  <div v-if="errors.giro_solicitado" class="invalid-feedback">
                    {{ errors.giro_solicitado }}
                  </div>
                </div>
                <div class="col-md-12 mb-3">
                  <label class="form-label">Actividad Específica</label>
                  <textarea
                    v-model="formData.actividad_especifica"
                    class="form-control"
                    rows="2"
                  ></textarea>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Superficie Solicitada (m²)</label>
                  <input
                    type="number"
                    v-model="formData.superficie_solicitada"
                    class="form-control"
                    step="0.01"
                    min="0"
                  >
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label">Inversión Estimada ($)</label>
                  <input
                    type="number"
                    v-model="formData.inversion_estimada"
                    class="form-control"
                    step="0.01"
                    min="0"
                  >
                </div>
                <div class="col-md-12 mb-3" v-if="modoEdicion">
                  <label class="form-label">Observaciones</label>
                  <textarea
                    v-model="formData.observaciones"
                    class="form-control"
                    rows="3"
                  ></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModalForm">
              Cancelar
            </button>
            <button
              type="button"
              class="btn btn-primary"
              @click="guardarSolicitud"
              :disabled="guardando"
            >
              <span v-if="guardando" class="spinner-border spinner-border-sm me-2"></span>
              {{ modoEdicion ? 'Actualizar' : 'Crear' }} Solicitud
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <div
      class="modal fade"
      tabindex="-1"
      v-if="showModalDetalle"
      :class="{ show: showModalDetalle }"
      style="display: block;"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              Detalle de Solicitud: {{ solicitudDetalle?.folio_solicitud }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModalDetalle"></button>
          </div>
          <div class="modal-body" v-if="solicitudDetalle">
            <div class="row">
              <div class="col-md-6">
                <strong>Tipo:</strong> {{ formatTipoSolicitud(solicitudDetalle.tipo_solicitud) }}
              </div>
              <div class="col-md-6">
                <strong>Estado:</strong>
                <span class="badge" :class="getEstadoBadgeClass(solicitudDetalle.estado)">
                  {{ formatEstado(solicitudDetalle.estado) }}
                </span>
              </div>
              <div class="col-md-6 mt-2">
                <strong>Solicitante:</strong> {{ solicitudDetalle.solicitante }}
              </div>
              <div class="col-md-6 mt-2">
                <strong>RFC:</strong> {{ solicitudDetalle.rfc || 'No especificado' }}
              </div>
              <div class="col-md-12 mt-2">
                <strong>Giro:</strong> {{ solicitudDetalle.giro_solicitado }}
              </div>
              <div class="col-md-12 mt-2">
                <strong>Dirección:</strong> {{ solicitudDetalle.direccion_negocio }}
              </div>
              <div class="col-md-6 mt-2">
                <strong>Fecha Solicitud:</strong> {{ formatDate(solicitudDetalle.fecha_solicitud) }}
              </div>
              <div class="col-md-6 mt-2">
                <strong>Días Transcurridos:</strong> {{ solicitudDetalle.dias_transcurridos }}
              </div>
              <div class="col-md-12 mt-2" v-if="solicitudDetalle.observaciones">
                <strong>Observaciones:</strong>
                <p class="mt-1">{{ solicitudDetalle.observaciones }}</p>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModalDetalle">
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Cambiar Estado -->
    <div
      class="modal fade"
      tabindex="-1"
      v-if="showModalEstado"
      :class="{ show: showModalEstado }"
      style="display: block;"
    >
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              Cambiar Estado: {{ solicitudEstado?.folio_solicitud }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModalEstado"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="actualizarEstado">
              <div class="mb-3">
                <label class="form-label">Nuevo Estado</label>
                <select v-model="nuevoEstado" class="form-select" required>
                  <option value="">Seleccionar estado</option>
                  <option value="EN_REVISION">En Revisión</option>
                  <option value="OBSERVACIONES">Con Observaciones</option>
                  <option value="APROBADA">Aprobada</option>
                  <option value="RECHAZADA">Rechazada</option>
                  <option value="CANCELADA">Cancelada</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Funcionario Revisor</label>
                <input
                  type="text"
                  v-model="funcionarioRevisor"
                  class="form-control"
                  placeholder="Nombre del funcionario"
                >
              </div>
              <div class="mb-3">
                <label class="form-label">Observaciones/Dictamen</label>
                <textarea
                  v-model="observacionesEstado"
                  class="form-control"
                  rows="4"
                  placeholder="Ingrese observaciones o dictamen..."
                ></textarea>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModalEstado">
              Cancelar
            </button>
            <button
              type="button"
              class="btn btn-primary"
              @click="actualizarEstado"
              :disabled="!nuevoEstado"
            >
              Actualizar Estado
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Estadísticas -->
    <div
      class="modal fade"
      tabindex="-1"
      v-if="showModalEstadisticas"
      :class="{ show: showModalEstadisticas }"
      style="display: block;"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Estadísticas de Solicitudes</h5>
            <button type="button" class="btn-close" @click="cerrarModalEstadisticas"></button>
          </div>
          <div class="modal-body" v-if="estadisticas">
            <div class="row">
              <div class="col-md-4 mb-3">
                <div class="card bg-primary text-white">
                  <div class="card-body text-center">
                    <h3>{{ estadisticas.total_solicitudes }}</h3>
                    <p class="mb-0">Total Solicitudes</p>
                  </div>
                </div>
              </div>
              <div class="col-md-4 mb-3">
                <div class="card bg-success text-white">
                  <div class="card-body text-center">
                    <h3>{{ estadisticas.solicitudes_aprobadas }}</h3>
                    <p class="mb-0">Aprobadas</p>
                  </div>
                </div>
              </div>
              <div class="col-md-4 mb-3">
                <div class="card bg-warning text-white">
                  <div class="card-body text-center">
                    <h3>{{ estadisticas.solicitudes_pendientes }}</h3>
                    <p class="mb-0">Pendientes</p>
                  </div>
                </div>
              </div>
              <div class="col-md-3 mb-3">
                <div class="card bg-info text-white">
                  <div class="card-body text-center">
                    <h4>{{ estadisticas.solicitudes_recibidas }}</h4>
                    <p class="mb-0">Recibidas</p>
                  </div>
                </div>
              </div>
              <div class="col-md-3 mb-3">
                <div class="card bg-secondary text-white">
                  <div class="card-body text-center">
                    <h4>{{ estadisticas.solicitudes_en_revision }}</h4>
                    <p class="mb-0">En Revisión</p>
                  </div>
                </div>
              </div>
              <div class="col-md-3 mb-3">
                <div class="card bg-warning">
                  <div class="card-body text-center">
                    <h4>{{ estadisticas.solicitudes_con_observaciones }}</h4>
                    <p class="mb-0">Con Observaciones</p>
                  </div>
                </div>
              </div>
              <div class="col-md-3 mb-3">
                <div class="card bg-danger text-white">
                  <div class="card-body text-center">
                    <h4>{{ estadisticas.solicitudes_rechazadas }}</h4>
                    <p class="mb-0">Rechazadas</p>
                  </div>
                </div>
              </div>
              <div class="col-md-12">
                <div class="card">
                  <div class="card-body text-center">
                    <h4>{{ Math.round(estadisticas.tiempo_promedio_revision || 0) }} días</h4>
                    <p class="mb-0">Tiempo Promedio de Revisión</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModalEstadisticas">
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Backdrop para modales -->
    <div
      v-if="showModalForm || showModalDetalle || showModalEstado || showModalEstadisticas"
      class="modal-backdrop fade show"
    ></div>

    <!-- Alertas -->
    <div
      v-if="mensaje"
      class="alert alert-dismissible fade show fixed-top mx-3"
      :class="tipoMensaje === 'success' ? 'alert-success' : 'alert-danger'"
      style="top: 20px; z-index: 1060;"
    >
      {{ mensaje }}
      <button type="button" class="btn-close" @click="cerrarMensaje"></button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'regsolicfrm',
  data() {
    return {
      // Estados de UI
      loading: false,
      guardando: false,
      showModalForm: false,
      showModalDetalle: false,
      showModalEstado: false,
      showModalEstadisticas: false,
      modoEdicion: false,

      // Datos principales
      solicitudes: [],
      totalRegistros: 0,
      estadisticas: null,

      // Paginación
      paginaActual: 1,
      limite: 20,

      // Filtros
      filtros: {
        folio_solicitud: '',
        solicitante: '',
        rfc: '',
        tipo_solicitud: '',
        estado: '',
        giro: '',
        fecha_desde: '',
        fecha_hasta: '',
        funcionario_revisor: ''
      },

      // Formulario
      formData: {
        folio_solicitud: '',
        tipo_solicitud: '',
        solicitante: '',
        razon_social: '',
        rfc: '',
        curp: '',
        telefono: '',
        email: '',
        direccion_negocio: '',
        colonia: '',
        giro_solicitado: '',
        actividad_especifica: '',
        superficie_solicitada: null,
        inversion_estimada: null,
        observaciones: ''
      },

      // Estados de modales
      solicitudDetalle: null,
      solicitudEstado: null,
      nuevoEstado: '',
      funcionarioRevisor: '',
      observacionesEstado: '',

      // Validación y mensajes
      errors: {},
      mensaje: '',
      tipoMensaje: 'success'
    };
  },

  computed: {
    totalPaginas() {
      return Math.ceil(this.totalRegistros / this.limite);
    },

    paginasVisibles() {
      const paginas = [];
      const inicio = Math.max(1, this.paginaActual - 2);
      const fin = Math.min(this.totalPaginas, inicio + 4);

      for (let i = inicio; i <= fin; i++) {
        paginas.push(i);
      }
      return paginas;
    }
  },

  mounted() {
    this.buscarSolicitudes();
  },

  methods: {
    // Búsqueda y paginación
    async buscarSolicitudes() {
      this.loading = true;
      try {
        const offset = (this.paginaActual - 1) * this.limite;
        const eRequest = {
          action: 'informix.SP_REGSOLIC_LIST',
          payload: {
            ...this.filtros,
            p_limite: this.limite,
            p_offset: offset
          }
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.status === 'success') {
          this.solicitudes = data.eResponse.data.result || [];
          this.totalRegistros = this.solicitudes.length > 0 ? this.solicitudes[0].total_registros : 0;
        } else {
          this.mostrarMensaje('Error al cargar solicitudes: ' + data.message, 'error');
          this.solicitudes = [];
          this.totalRegistros = 0;
        }
      } catch (error) {
        console.error('Error:', error);
        this.mostrarMensaje('Error de conexión al cargar solicitudes', 'error');
        this.solicitudes = [];
        this.totalRegistros = 0;
      } finally {
        this.loading = false;
      }
    },

    cambiarPagina(pagina) {
      if (pagina >= 1 && pagina <= this.totalPaginas) {
        this.paginaActual = pagina;
        this.buscarSolicitudes();
      }
    },

    limpiarFiltros() {
      this.filtros = {
        folio_solicitud: '',
        solicitante: '',
        rfc: '',
        tipo_solicitud: '',
        estado: '',
        giro: '',
        fecha_desde: '',
        fecha_hasta: '',
        funcionario_revisor: ''
      };
      this.paginaActual = 1;
      this.buscarSolicitudes();
    },

    // Modales
    abrirModalCrear() {
      this.modoEdicion = false;
      this.formData = {
        folio_solicitud: '',
        tipo_solicitud: '',
        solicitante: '',
        razon_social: '',
        rfc: '',
        curp: '',
        telefono: '',
        email: '',
        direccion_negocio: '',
        colonia: '',
        giro_solicitado: '',
        actividad_especifica: '',
        superficie_solicitada: null,
        inversion_estimada: null,
        observaciones: ''
      };
      this.errors = {};
      this.showModalForm = true;
    },

    async editarSolicitud(solicitud) {
      this.modoEdicion = true;

      try {
        const eRequest = {
          action: 'informix.SP_REGSOLIC_DETAIL',
          payload: { p_folio_solicitud: solicitud.folio_solicitud }
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.status === 'success' && data.eResponse.data.result.length > 0) {
          const detalle = data.eResponse.data.result[0];
          this.formData = {
            id: detalle.id,
            folio_solicitud: detalle.folio_solicitud,
            tipo_solicitud: detalle.tipo_solicitud,
            solicitante: detalle.solicitante,
            razon_social: detalle.razon_social,
            rfc: detalle.rfc,
            curp: detalle.curp,
            telefono: detalle.telefono,
            email: detalle.email,
            direccion_negocio: detalle.direccion_negocio,
            colonia: detalle.colonia,
            giro_solicitado: detalle.giro_solicitado,
            actividad_especifica: detalle.actividad_especifica,
            superficie_solicitada: detalle.superficie_solicitada,
            inversion_estimada: detalle.inversion_estimada,
            observaciones: detalle.observaciones
          };
          this.errors = {};
          this.showModalForm = true;
        }
      } catch (error) {
        this.mostrarMensaje('Error al cargar los datos de la solicitud', 'error');
      }
    },

    cerrarModalForm() {
      this.showModalForm = false;
      this.formData = {};
      this.errors = {};
    },

    async verDetalle(solicitud) {
      try {
        const eRequest = {
          action: 'informix.SP_REGSOLIC_DETAIL',
          payload: { p_folio_solicitud: solicitud.folio_solicitud }
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.status === 'success' && data.eResponse.data.result.length > 0) {
          this.solicitudDetalle = data.eResponse.data.result[0];
          this.showModalDetalle = true;
        }
      } catch (error) {
        this.mostrarMensaje('Error al cargar el detalle de la solicitud', 'error');
      }
    },

    cerrarModalDetalle() {
      this.showModalDetalle = false;
      this.solicitudDetalle = null;
    },

    cambiarEstado(solicitud) {
      this.solicitudEstado = solicitud;
      this.nuevoEstado = '';
      this.funcionarioRevisor = '';
      this.observacionesEstado = '';
      this.showModalEstado = true;
    },

    cerrarModalEstado() {
      this.showModalEstado = false;
      this.solicitudEstado = null;
      this.nuevoEstado = '';
      this.funcionarioRevisor = '';
      this.observacionesEstado = '';
    },

    async mostrarEstadisticas() {
      try {
        const eRequest = {
          action: 'informix.SP_REGSOLIC_ESTADISTICAS',
          payload: {
            p_fecha_desde: this.filtros.fecha_desde || null,
            p_fecha_hasta: this.filtros.fecha_hasta || null
          }
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.status === 'success' && data.eResponse.data.result.length > 0) {
          this.estadisticas = data.eResponse.data.result[0];
          this.showModalEstadisticas = true;
        }
      } catch (error) {
        this.mostrarMensaje('Error al cargar estadísticas', 'error');
      }
    },

    cerrarModalEstadisticas() {
      this.showModalEstadisticas = false;
      this.estadisticas = null;
    },

    // CRUD Operations
    async guardarSolicitud() {
      this.errors = {};

      // Validaciones básicas
      if (!this.formData.folio_solicitud?.trim()) {
        this.errors.folio_solicitud = 'El folio es requerido';
      }
      if (!this.formData.tipo_solicitud) {
        this.errors.tipo_solicitud = 'El tipo de solicitud es requerido';
      }
      if (!this.formData.solicitante?.trim()) {
        this.errors.solicitante = 'El solicitante es requerido';
      }
      if (!this.formData.direccion_negocio?.trim()) {
        this.errors.direccion_negocio = 'La dirección del negocio es requerida';
      }
      if (!this.formData.giro_solicitado?.trim()) {
        this.errors.giro_solicitado = 'El giro solicitado es requerido';
      }

      if (Object.keys(this.errors).length > 0) {
        return;
      }

      this.guardando = true;

      try {
        const action = this.modoEdicion ? 'informix.SP_REGSOLIC_UPDATE' : 'informix.SP_REGSOLIC_CREATE';
        const payload = this.modoEdicion ? {
          p_id: this.formData.id,
          p_solicitante: this.formData.solicitante,
          p_direccion_negocio: this.formData.direccion_negocio,
          p_giro_solicitado: this.formData.giro_solicitado,
          p_razon_social: this.formData.razon_social,
          p_rfc: this.formData.rfc,
          p_curp: this.formData.curp,
          p_telefono: this.formData.telefono,
          p_email: this.formData.email,
          p_colonia: this.formData.colonia,
          p_actividad_especifica: this.formData.actividad_especifica,
          p_superficie_solicitada: this.formData.superficie_solicitada,
          p_inversion_estimada: this.formData.inversion_estimada,
          p_observaciones: this.formData.observaciones
        } : {
          p_folio_solicitud: this.formData.folio_solicitud,
          p_tipo_solicitud: this.formData.tipo_solicitud,
          p_solicitante: this.formData.solicitante,
          p_direccion_negocio: this.formData.direccion_negocio,
          p_giro_solicitado: this.formData.giro_solicitado,
          p_razon_social: this.formData.razon_social,
          p_rfc: this.formData.rfc,
          p_curp: this.formData.curp,
          p_telefono: this.formData.telefono,
          p_email: this.formData.email,
          p_colonia: this.formData.colonia,
          p_actividad_especifica: this.formData.actividad_especifica,
          p_superficie_solicitada: this.formData.superficie_solicitada,
          p_inversion_estimada: this.formData.inversion_estimada,
          p_usuario_registro: 'USUARIO_ACTUAL' // TODO: obtener del contexto
        };

        const eRequest = {
          action,
          payload
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.status === 'success') {
          const resultado = data.eResponse.data.result[0];
          if (resultado.success) {
            this.mostrarMensaje(resultado.message, 'success');
            this.cerrarModalForm();
            this.buscarSolicitudes();
          } else {
            this.mostrarMensaje(resultado.message, 'error');
          }
        } else {
          this.mostrarMensaje('Error al guardar: ' + data.message, 'error');
        }
      } catch (error) {
        console.error('Error:', error);
        this.mostrarMensaje('Error de conexión al guardar la solicitud', 'error');
      } finally {
        this.guardando = false;
      }
    },

    async actualizarEstado() {
      if (!this.nuevoEstado) return;

      try {
        const eRequest = {
          action: 'informix.SP_REGSOLIC_UPDATE_STATUS',
          payload: {
            p_folio_solicitud: this.solicitudEstado.folio_solicitud,
            p_estado: this.nuevoEstado,
            p_dictamen: this.observacionesEstado,
            p_observaciones: this.observacionesEstado,
            p_funcionario_revisor: this.funcionarioRevisor
          }
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.status === 'success') {
          const resultado = data.eResponse.data.result[0];
          if (resultado.success) {
            this.mostrarMensaje(resultado.message, 'success');
            this.cerrarModalEstado();
            this.buscarSolicitudes();
          } else {
            this.mostrarMensaje(resultado.message, 'error');
          }
        }
      } catch (error) {
        this.mostrarMensaje('Error al actualizar el estado', 'error');
      }
    },

    // Utilidades de formato
    formatDate(date) {
      if (!date) return '';
      return new Date(date).toLocaleDateString('es-MX');
    },

    formatDateTime(datetime) {
      if (!datetime) return '';
      return new Date(datetime).toLocaleString('es-MX');
    },

    formatTipoSolicitud(tipo) {
      const tipos = {
        'LICENCIA_NUEVA': 'Licencia Nueva',
        'RENOVACION': 'Renovación',
        'MODIFICACION': 'Modificación',
        'ANUNCIO_NUEVO': 'Anuncio Nuevo'
      };
      return tipos[tipo] || tipo;
    },

    formatEstado(estado) {
      const estados = {
        'RECIBIDA': 'Recibida',
        'EN_REVISION': 'En Revisión',
        'OBSERVACIONES': 'Con Observaciones',
        'APROBADA': 'Aprobada',
        'RECHAZADA': 'Rechazada',
        'CANCELADA': 'Cancelada'
      };
      return estados[estado] || estado;
    },

    getBadgeClass(tipo) {
      const clases = {
        'LICENCIA_NUEVA': 'bg-primary',
        'RENOVACION': 'bg-success',
        'MODIFICACION': 'bg-warning',
        'ANUNCIO_NUEVO': 'bg-info'
      };
      return clases[tipo] || 'bg-secondary';
    },

    getEstadoBadgeClass(estado) {
      const clases = {
        'RECIBIDA': 'bg-info',
        'EN_REVISION': 'bg-warning',
        'OBSERVACIONES': 'bg-warning',
        'APROBADA': 'bg-success',
        'RECHAZADA': 'bg-danger',
        'CANCELADA': 'bg-secondary'
      };
      return clases[estado] || 'bg-secondary';
    },

    // Mensajes
    mostrarMensaje(texto, tipo = 'success') {
      this.mensaje = texto;
      this.tipoMensaje = tipo;
      setTimeout(() => {
        this.mensaje = '';
      }, 5000);
    },

    cerrarMensaje() {
      this.mensaje = '';
    }
  }
};
</script>

<style scoped>
.regsolic-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.modal {
  display: block;
  background: rgba(0,0,0,0.5);
}

.modal-dialog {
  margin-top: 3vh;
}

.table th {
  background-color: #f8f9fa;
  border-bottom: 2px solid #dee2e6;
  font-weight: 600;
}

.table td {
  vertical-align: middle;
}

.btn-group .btn {
  border-radius: 0.25rem;
  margin-right: 2px;
}

.badge {
  font-size: 0.75em;
}

.form-label {
  font-weight: 500;
  margin-bottom: 0.5rem;
}

.card {
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
}

.spinner-border-sm {
  width: 1rem;
  height: 1rem;
}

.fixed-top {
  position: fixed;
  top: 0;
  right: 0;
  left: 0;
}

@media (max-width: 768px) {
  .regsolic-container {
    padding: 10px;
  }

  .table-responsive {
    font-size: 0.875rem;
  }

  .btn-group .btn {
    padding: 0.25rem 0.5rem;
  }
}
</style>