<template>
  <div class="municipal-form-page">
    <!-- Header del módulo -->
    <div class="municipal-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="mb-1">
            <i class="fas fa-file-alt me-2"></i>
            Consulta de Trámites
          </h3>
          <p class="mb-0 opacity-90">
            Consulta y gestión de trámites de licencias municipales
          </p>
        </div>
        <div class="col-auto">
          <button
            class="btn-municipal-primary"
            @click="showCreateModal = true"
            :disabled="loading"
          >
            <i class="fas fa-plus me-1"></i>
            Nuevo Trámite
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card mb-4">
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">ID Trámite</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.id_tramite"
              placeholder="Ej: 12345"
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Propietario</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.propietario"
              placeholder="Nombre del propietario"
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">RFC</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.rfc"
              placeholder="RFC del propietario"
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Actividad</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.actividad"
              placeholder="Actividad comercial"
            >
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-12">
            <div class="municipal-group-btn">
              <button
                class="btn-municipal-primary me-2"
                @click="searchTramites"
                :disabled="loading"
              >
                <i class="fas fa-search me-1"></i>
                Buscar
              </button>
              <button
                class="btn-municipal-secondary me-2"
                @click="clearFilters"
                :disabled="loading"
              >
                <i class="fas fa-times me-1"></i>
                Limpiar
              </button>
              <button
                class="btn-municipal-secondary me-2"
                @click="loadTramites"
                :disabled="loading"
              >
                <i class="fas fa-sync-alt me-1"></i>
                Actualizar
              </button>
              <button
                class="btn-municipal-warning"
                @click="generarDatosSimulados"
                :disabled="loading"
                title="Generar datos simulados para desarrollo"
              >
                <i class="fas fa-flask me-1"></i>
                Datos Simulados
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h6 class="mb-0">
          <i class="fas fa-list me-2"></i>
          Trámites Registrados
          <span v-if="tramites.length > 0" class="municipal-badge municipal-badge-primary ms-2">
            {{ tramites.length }} registros
          </span>
        </h6>
      </div>
      <div class="municipal-card-body">
        <!-- Loading state -->
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2 text-muted">Cargando trámites...</p>
        </div>

        <!-- Error state -->
        <div v-else-if="error" class="municipal-alert-danger">
          <h6 class="mb-2"><i class="fas fa-exclamation-triangle me-2"></i>Error al cargar datos</h6>
          <p class="mb-3">{{ error }}</p>
          <button class="btn-municipal-secondary btn-sm" @click="loadTramites">
            <i class="fas fa-retry me-1"></i>
            Reintentar
          </button>
        </div>

        <!-- Empty state -->
        <div v-else-if="tramites.length === 0" class="text-center py-5">
          <i class="fas fa-file-alt fa-3x text-muted mb-3"></i>
          <h5 class="text-muted">No se encontraron trámites</h5>
          <p class="text-muted">
            {{ hasActiveFilters ? 'No hay registros que coincidan con los filtros aplicados.' : 'No hay trámites registrados en el sistema.' }}
          </p>
          <button
            v-if="!hasActiveFilters"
            class="btn-municipal-primary"
            @click="showCreateModal = true"
          >
            <i class="fas fa-plus me-1"></i>
            Registrar primer trámite
          </button>
        </div>

        <!-- Tabla con datos -->
        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID Trámite</th>
                <th>Folio</th>
                <th>Propietario</th>
                <th>RFC</th>
                <th>Actividad</th>
                <th>Ubicación</th>
                <th>Estatus</th>
                <th>Fecha</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="tramite in tramites" :key="tramite.id_tramite">
                <td>
                  <strong class="text-primary">{{ tramite.id_tramite }}</strong>
                </td>
                <td>{{ tramite.folio || 'N/A' }}</td>
                <td>{{ tramite.propietario || 'N/A' }}</td>
                <td>{{ tramite.rfc || 'N/A' }}</td>
                <td>
                  <span class="municipal-badge municipal-badge-info text-wrap" style="max-width: 200px;">
                    {{ (tramite.actividad || 'N/A').substring(0, 50) }}{{ (tramite.actividad || '').length > 50 ? '...' : '' }}
                  </span>
                </td>
                <td>{{ tramite.ubicacion || 'N/A' }}</td>
                <td>
                  <span class="municipal-badge" :class="getMunicipalEstatusBadgeClass(tramite.estatus)">
                    {{ getEstatusText(tramite.estatus) }}
                  </span>
                </td>
                <td>{{ formatDate(tramite.feccap) }}</td>
                <td>
                  <div class="municipal-group-btn btn-group-sm">
                    <button
                      class="btn-municipal-secondary btn-sm"
                      @click="viewTramite(tramite)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editTramite(tramite)"
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      class="btn-municipal-secondary btn-sm"
                      @click="printTramite(tramite)"
                      title="Imprimir"
                    >
                      <i class="fas fa-print"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Paginación -->
        <div v-if="totalPages > 1" class="d-flex justify-content-between align-items-center mt-4">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} a
              {{ Math.min(currentPage * itemsPerPage, totalRegistros) }} de
              {{ totalRegistros }} registros
            </span>
          </div>
          <nav aria-label="Paginación de trámites">
            <ul class="pagination pagination-sm mb-0">
              <li class="page-item" :class="{ disabled: currentPage === 1 }">
                <button
                  class="page-link"
                  @click="previousPage"
                  :disabled="currentPage === 1"
                  aria-label="Página anterior"
                >
                  <i class="fas fa-chevron-left"></i>
                </button>
              </li>

              <li
                v-for="page in getVisiblePages()"
                :key="page"
                class="page-item"
                :class="{ active: page === currentPage }"
              >
                <button
                  class="page-link"
                  @click="goToPage(page)"
                  :aria-label="`Página ${page}`"
                >
                  {{ page }}
                </button>
              </li>

              <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                <button
                  class="page-link"
                  @click="nextPage"
                  :disabled="currentPage === totalPages"
                  aria-label="Página siguiente"
                >
                  <i class="fas fa-chevron-right"></i>
                </button>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </div>

    <!-- Modal para crear/editar trámite -->
    <div class="modal fade" tabindex="-1" v-if="showCreateModal" style="display: block;" @click.self="showCreateModal = false">
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-plus"></i>
              {{ editingTramite ? 'Editar Trámite' : 'Nuevo Trámite' }}
            </h5>
            <button type="button" class="btn-close" @click="showCreateModal = false"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveTramite">
              <div class="row">
                <div class="col-md-6">
                  <label class="municipal-form-label">Propietario <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newTramite.propietario"
                    placeholder="Nombre completo del propietario"
                    required
                    maxlength="80"
                  >
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">RFC</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newTramite.rfc"
                    placeholder="RFC del propietario"
                    maxlength="13"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="municipal-form-label">Cuenta Predial</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model="newTramite.cvecuenta"
                    placeholder="Número de cuenta predial"
                  >
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Ubicación <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newTramite.ubicacion"
                    placeholder="Dirección o ubicación del negocio"
                    required
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="municipal-form-label">Actividad <span class="text-danger">*</span></label>
                  <textarea
                    class="municipal-form-control"
                    rows="3"
                    v-model="newTramite.actividad"
                    placeholder="Descripción de la actividad comercial o giro"
                    required
                  ></textarea>
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="municipal-form-label">Estatus</label>
                  <select class="municipal-form-control" v-model="newTramite.estatus">
                    <option value="A">Activo</option>
                    <option value="C">Cancelado</option>
                    <option value="T">Temporal</option>
                    <option value="R">Rechazado</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Observaciones</label>
                  <textarea
                    class="municipal-form-control"
                    rows="2"
                    v-model="newTramite.observaciones"
                    placeholder="Observaciones adicionales"
                  ></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="showCreateModal = false">
              <i class="fas fa-times me-1"></i>
              Cancelar
            </button>
            <button
              type="button"
              class="btn-municipal-primary"
              @click="saveTramite"
              :disabled="creating || !newTramite.propietario || !newTramite.ubicacion || !newTramite.actividad"
            >
              <span v-if="creating">
                <i class="fas fa-spinner fa-spin me-1"></i>
                {{ editingTramite ? 'Actualizando...' : 'Creando...' }}
              </span>
              <span v-else>
                <i class="fas fa-save me-1"></i>
                {{ editingTramite ? 'Actualizar Trámite' : 'Crear Trámite' }}
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showCreateModal" class="modal-backdrop fade show"></div>

    <!-- Modal de detalles del trámite -->
    <div v-if="showDetailsModal" class="modal-overlay" @click.self="showDetailsModal = false">
      <div class="modal-content" style="max-width: 800px;">
        <div class="modal-header">
          <h2>
            <i class="fas fa-file-alt"></i>
            Detalles del Trámite
          </h2>
          <button class="close-btn" @click="showDetailsModal = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body" v-if="selectedTramite">
          <div class="row">
            <div class="col-12 mb-4">
              <div class="alert alert-info">
                <h5 class="alert-heading mb-2">
                  <i class="fas fa-info-circle"></i>
                  Trámite ID: {{ selectedTramite.id_tramite }}
                  <span v-if="selectedTramite.folio"> - Folio: {{ selectedTramite.folio }}</span>
                </h5>
                <p class="mb-0">{{ selectedTramite.propietario }}</p>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-md-6">
              <div class="card h-100">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-user"></i>
                    Información del Propietario
                  </h6>
                </div>
                <div class="card-body">
                  <div class="form-group mb-3">
                    <label class="form-label">Nombre:</label>
                    <p class="form-control-plaintext">{{ selectedTramite.propietario }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">RFC:</label>
                    <p class="form-control-plaintext">{{ selectedTramite.rfc || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">Cuenta Predial:</label>
                    <p class="form-control-plaintext">{{ selectedTramite.cvecuenta || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-0">
                    <label class="form-label">Estatus:</label>
                    <span class="municipal-badge" :class="getMunicipalEstatusBadgeClass(selectedTramite.estatus)">
                      {{ getEstatusText(selectedTramite.estatus) }}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-md-6">
              <div class="card h-100">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-map-marker-alt"></i>
                    Ubicación y Actividad
                  </h6>
                </div>
                <div class="card-body">
                  <div class="form-group mb-3">
                    <label class="form-label">Ubicación:</label>
                    <p class="form-control-plaintext">{{ selectedTramite.ubicacion }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">Colonia:</label>
                    <p class="form-control-plaintext">{{ selectedTramite.colonia_ubic || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">Número Exterior:</label>
                    <p class="form-control-plaintext">{{ selectedTramite.numext_ubic || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-0">
                    <label class="form-label">Fecha de Registro:</label>
                    <p class="form-control-plaintext">{{ formatDate(selectedTramite.feccap) }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="row mt-4">
            <div class="col-12">
              <div class="card">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-briefcase"></i>
                    Actividad Comercial
                  </h6>
                </div>
                <div class="card-body">
                  <p class="mb-0">{{ selectedTramite.actividad || 'Sin actividad registrada' }}</p>
                </div>
              </div>
            </div>
          </div>

          <div class="row mt-4" v-if="selectedTramite.observaciones">
            <div class="col-12">
              <div class="card">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-comment"></i>
                    Observaciones
                  </h6>
                </div>
                <div class="card-body">
                  <p class="mb-0">{{ selectedTramite.observaciones }}</p>
                </div>
              </div>
            </div>
          </div>

          <div class="row mt-4" v-if="selectedTramite.inversion || selectedTramite.num_empleados || selectedTramite.sup_autorizada">
            <div class="col-12">
              <div class="card">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-chart-bar"></i>
                    Información Adicional
                  </h6>
                </div>
                <div class="card-body">
                  <div class="row">
                    <div class="col-md-4" v-if="selectedTramite.inversion">
                      <label class="form-label">Inversión:</label>
                      <p class="form-control-plaintext text-success fw-bold">{{ selectedTramite.inversion }}</p>
                    </div>
                    <div class="col-md-4" v-if="selectedTramite.num_empleados">
                      <label class="form-label">Número de Empleados:</label>
                      <p class="form-control-plaintext">{{ selectedTramite.num_empleados }}</p>
                    </div>
                    <div class="col-md-4" v-if="selectedTramite.sup_autorizada">
                      <label class="form-label">Superficie Autorizada:</label>
                      <p class="form-control-plaintext">{{ selectedTramite.sup_autorizada }} m²</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-primary" @click="editTramite(selectedTramite)">
            <i class="fas fa-edit me-1"></i>
            Editar Trámite
          </button>
          <button class="btn-municipal-primary" @click="printTramiteInfo(selectedTramite)">
            <i class="fas fa-print me-1"></i>
            Imprimir
          </button>
          <button class="btn-municipal-secondary" @click="showDetailsModal = false">
            <i class="fas fa-times me-1"></i>
            Cerrar
          </button>
        </div>
      </div>
    </div>

    <!-- SweetAlert Modal -->
    <div v-if="sweetAlert.show" class="swal-overlay" @click.self="closeSweetAlert">
      <div class="swal-modal">
        <div class="swal-icon" :class="sweetAlert.type">
          <i v-if="sweetAlert.type === 'success'" class="fas fa-check-circle"></i>
          <i v-else-if="sweetAlert.type === 'error'" class="fas fa-times-circle"></i>
          <i v-else-if="sweetAlert.type === 'warning'" class="fas fa-exclamation-triangle"></i>
          <i v-else-if="sweetAlert.type === 'info'" class="fas fa-info-circle"></i>
          <i v-else class="fas fa-question-circle"></i>
        </div>
        <h3 class="swal-title">{{ sweetAlert.title }}</h3>
        <p class="swal-text">{{ sweetAlert.text }}</p>
        <div class="swal-footer">
          <button class="btn-municipal-primary" @click="closeSweetAlert">
            <i class="fas fa-check me-1"></i>
            Aceptar
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-for="toast in toasts" :key="toast.id"
         class="toast-notification"
         :class="toast.type"
         :style="{ top: (20 + (toasts.indexOf(toast) * 80)) + 'px' }">
      <div class="toast-icon">
        <i v-if="toast.type === 'success'" class="fas fa-check-circle"></i>
        <i v-else-if="toast.type === 'error'" class="fas fa-times-circle"></i>
        <i v-else-if="toast.type === 'warning'" class="fas fa-exclamation-triangle"></i>
        <i v-else-if="toast.type === 'info'" class="fas fa-info-circle"></i>
      </div>
      <div class="toast-message">{{ toast.message }}</div>
      <button class="toast-close" @click="removeToast(toast.id)">
        <i class="fas fa-times"></i>
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaTramitefrm',
  data() {
    return {
      // Estado de carga
      loading: false,
      creating: false,
      error: null,

      // Datos
      tramites: [],
      totalRegistros: 0,

      // Paginación
      currentPage: 1,
      itemsPerPage: 10,
      totalPages: 0,

      // Filtros
      filters: {
        id_tramite: '',
        propietario: '',
        rfc: '',
        actividad: ''
      },

      // Modal
      showCreateModal: false,
      editingTramite: null,

      // Modales
      showDetailsModal: false,
      selectedTramite: null,

      // SweetAlert
      sweetAlert: {
        show: false,
        type: 'info',
        title: '',
        text: ''
      },

      // Toast notifications
      toasts: [],

      // Nuevo trámite
      newTramite: {
        propietario: '',
        rfc: '',
        cvecuenta: null,
        ubicacion: '',
        actividad: '',
        estatus: 'A',
        observaciones: ''
      }
    }
  },

  computed: {
    hasActiveFilters() {
      return Object.values(this.filters).some(value => value !== null && value !== '')
    }
  },

  methods: {
    async loadTramites() {
      this.loading = true
      this.error = null

      try {
        // Construir término de búsqueda basado en filtros
        let searchTerm = ''
        if (this.filters.id_tramite) {
          searchTerm = this.filters.id_tramite
        } else if (this.filters.propietario) {
          searchTerm = this.filters.propietario
        } else if (this.filters.rfc) {
          searchTerm = this.filters.rfc
        } else if (this.filters.actividad) {
          searchTerm = this.filters.actividad
        }

        // Llamada real a la API usando sp_consulta_tramite_list
        const eRequest = {
          Operacion: 'sp_consulta_tramite_list',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_page', valor: this.currentPage },
            { nombre: 'p_limit', valor: this.itemsPerPage },
            { nombre: 'p_search', valor: searchTerm || '' },
            { nombre: 'p_estatus', valor: '' },
            { nombre: 'p_fecha_inicio', valor: null },
            { nombre: 'p_fecha_fin', valor: null }
          ],
          Tenant: 'guadalajara'
        }

        console.log('📨 Cargando trámites con sp_consulta_tramite_list:', eRequest)

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        console.log('📥 Respuesta del servidor:', data)

        if (data.eResponse.success && data.eResponse.data.result) {
          this.tramites = data.eResponse.data.result || []

          // Obtener el total de registros del primer elemento (si existe)
          if (this.tramites.length > 0) {
            this.totalRegistros = parseInt(this.tramites[0].total_registros) || 0
            this.totalPages = Math.ceil(this.totalRegistros / this.itemsPerPage)
          } else {
            this.totalRegistros = 0
            this.totalPages = 0
          }

          console.log(`✅ Cargados ${this.tramites.length} trámites de ${this.totalRegistros} totales (Página ${this.currentPage}/${this.totalPages})`)
        } else {
          throw new Error(data.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        console.error('❌ Error loading tramites:', error)
        this.error = 'Error al cargar los trámites: ' + error.message

        // Fallback a datos simulados en caso de error de conexión
        if (error.message.includes('Failed to fetch') || error.message.includes('NetworkError') || error.message.includes('Connection refused')) {
          console.log('🎭 API no disponible, usando datos simulados como fallback...')
          await this.generarDatosSimulados()
          this.error = null // Limpiar error ya que usamos fallback
          this.showToast('warning', 'API no disponible - Usando datos simulados')
        }
      } finally {
        this.loading = false
      }
    },

    async searchTramites() {
      console.log('🔍 Buscando trámites con filtros:', this.filters)
      this.currentPage = 1 // Reset to first page when searching
      this.loadTramites()
    },

    clearFilters() {
      this.filters = {
        id_tramite: '',
        propietario: '',
        rfc: '',
        actividad: ''
      }
      this.currentPage = 1 // Reset to first page
      this.loadTramites()
    },

    async saveTramite() {
      if (!this.newTramite.propietario || !this.newTramite.ubicacion || !this.newTramite.actividad) {
        this.showSweetAlert('warning', 'Campos Requeridos', 'Por favor complete los campos requeridos (Propietario, Ubicación y Actividad)')
        return
      }

      this.creating = true

      try {
        let eRequest

        if (this.editingTramite) {
          // Actualizar trámite existente
          eRequest = {
            Operacion: 'sp_consulta_tramite_update',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_id_tramite', valor: this.editingTramite.id_tramite },
              { nombre: 'p_propietario', valor: this.newTramite.propietario },
              { nombre: 'p_rfc', valor: this.newTramite.rfc || null },
              { nombre: 'p_cvecuenta', valor: this.newTramite.cvecuenta || null },
              { nombre: 'p_ubicacion', valor: this.newTramite.ubicacion },
              { nombre: 'p_actividad', valor: this.newTramite.actividad },
              { nombre: 'p_estatus', valor: this.newTramite.estatus },
              { nombre: 'p_observaciones', valor: this.newTramite.observaciones || null }
            ],
            Tenant: 'guadalajara'
          }
        } else {
          // Crear nuevo trámite
          eRequest = {
            Operacion: 'sp_consulta_tramite_create',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_tipo_tramite', valor: 1 }, // Default tipo de tramite
              { nombre: 'p_propietario', valor: this.newTramite.propietario },
              { nombre: 'p_rfc', valor: this.newTramite.rfc || null },
              { nombre: 'p_cvecuenta', valor: this.newTramite.cvecuenta || null },
              { nombre: 'p_ubicacion', valor: this.newTramite.ubicacion },
              { nombre: 'p_colonia_ubic', valor: null },
              { nombre: 'p_numext_ubic', valor: null },
              { nombre: 'p_actividad', valor: this.newTramite.actividad },
              { nombre: 'p_estatus', valor: this.newTramite.estatus },
              { nombre: 'p_capturista', valor: 'webuser' },
              { nombre: 'p_observaciones', valor: this.newTramite.observaciones || null },
              { nombre: 'p_inversion', valor: 0.0 },
              { nombre: 'p_num_empleados', valor: 0 },
              { nombre: 'p_sup_autorizada', valor: 0.0 },
              { nombre: 'p_computer', valor: 'web-app' }
            ],
            Tenant: 'guadalajara'
          }
        }

        console.log(`📨 ${this.editingTramite ? 'Actualizando' : 'Creando'} trámite:`, eRequest)

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        console.log('📥 Respuesta del servidor:', data)

        if (data.eResponse.success && data.eResponse.data.result) {
          const result = data.eResponse.data.result[0]
          if (result.success) {
            this.showSweetAlert(
              'success',
              this.editingTramite ? 'Trámite Actualizado' : 'Trámite Creado',
              result.message || (this.editingTramite ? 'Trámite actualizado exitosamente' : 'Trámite creado exitosamente')
            )
            this.resetCreateForm()
            this.showCreateModal = false
            this.loadTramites()
          } else {
            this.showSweetAlert('error', 'Error', result.message || 'Error en la operación')
            return
          }
        } else {
          throw new Error(data.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Guardar', 'Error al guardar el trámite: ' + error.message)
        console.error('❌ Error saving tramite:', error)
      } finally {
        this.creating = false
      }
    },

    editTramite(tramite) {
      this.editingTramite = tramite
      this.newTramite = {
        propietario: tramite.propietario || '',
        rfc: tramite.rfc || '',
        cvecuenta: tramite.cvecuenta,
        ubicacion: tramite.ubicacion || '',
        actividad: tramite.actividad || '',
        estatus: tramite.estatus || 'A',
        observaciones: tramite.observaciones || ''
      }
      this.showCreateModal = true
      this.showDetailsModal = false
    },

    resetCreateForm() {
      this.editingTramite = null
      this.newTramite = {
        propietario: '',
        rfc: '',
        cvecuenta: null,
        ubicacion: '',
        actividad: '',
        estatus: 'A',
        observaciones: ''
      }
    },

    viewTramite(tramite) {
      console.log('View tramite:', tramite)
      this.showTramiteDetailsModal(tramite)
    },

    printTramite(tramite) {
      console.log('Print tramite:', tramite)
      this.printTramiteInfo(tramite)
    },

    getEstatusBadgeClass(estatus) {
      const classes = {
        'A': 'bg-success',
        'C': 'bg-danger',
        'T': 'bg-warning',
        'R': 'bg-secondary'
      }
      return classes[estatus] || 'bg-light'
    },

    getMunicipalEstatusBadgeClass(estatus) {
      const classes = {
        'A': 'municipal-badge-success',
        'C': 'municipal-badge-danger',
        'T': 'municipal-badge-warning',
        'R': 'municipal-badge-secondary'
      }
      return classes[estatus] || 'municipal-badge-light'
    },

    getEstatusText(estatus) {
      const texts = {
        'A': 'Activo',
        'C': 'Cancelado',
        'T': 'Temporal',
        'R': 'Rechazado'
      }
      return texts[estatus] || estatus || 'N/A'
    },

    formatDate(dateString) {
      if (!dateString) return 'N/A'
      try {
        const date = new Date(dateString)
        return date.toLocaleDateString('es-ES') + ' ' + date.toLocaleTimeString('es-ES', {
          hour: '2-digit',
          minute: '2-digit'
        })
      } catch (error) {
        return 'Fecha inválida'
      }
    },

    // Métodos de paginación
    goToPage(page) {
      if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
        this.currentPage = page
        this.loadTramites()
      }
    },

    previousPage() {
      if (this.currentPage > 1) {
        this.currentPage--
        this.loadTramites()
      }
    },

    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++
        this.loadTramites()
      }
    },

    getVisiblePages() {
      const pages = []
      const maxVisible = 5
      let start = Math.max(1, this.currentPage - Math.floor(maxVisible / 2))
      let end = Math.min(this.totalPages, start + maxVisible - 1)

      if (end - start + 1 < maxVisible) {
        start = Math.max(1, end - maxVisible + 1)
      }

      for (let i = start; i <= end; i++) {
        pages.push(i)
      }

      return pages
    },

    // SweetAlert personalizado
    showSweetAlert(type, title, text) {
      this.sweetAlert = {
        show: true,
        type: type,
        title: title,
        text: text
      }

      // Auto cerrar después de 3 segundos para success e info, 5 segundos para error y warning
      const autoCloseTime = (this.sweetAlert.type === 'success' || this.sweetAlert.type === 'info') ? 3000 : 5000;
      setTimeout(() => {
        this.sweetAlert.show = false;
      }, autoCloseTime);
    },

    closeSweetAlert() {
      this.sweetAlert.show = false
    },

    // Ver detalles del trámite en modal
    showTramiteDetailsModal(tramite) {
      this.selectedTramite = tramite
      this.showDetailsModal = true
    },

    // Imprimir información del trámite
    printTramiteInfo(tramite) {
      const printContent = `
        <div style="font-family: Arial, sans-serif; padding: 20px;">
          <h2>Información del Trámite</h2>
          <div style="margin: 20px 0;">
            <strong>ID Trámite:</strong> ${tramite.id_tramite}<br>
            <strong>Folio:</strong> ${tramite.folio || 'N/A'}<br>
            <strong>Propietario:</strong> ${tramite.propietario}<br>
            <strong>RFC:</strong> ${tramite.rfc || 'N/A'}<br>
            <strong>Ubicación:</strong> ${tramite.ubicacion}<br>
            <strong>Actividad:</strong> ${tramite.actividad || 'N/A'}<br>
            <strong>Estatus:</strong> ${this.getEstatusText(tramite.estatus)}<br>
            <strong>Cuenta Predial:</strong> ${tramite.cvecuenta || 'N/A'}<br>
            <strong>Fecha de Registro:</strong> ${this.formatDate(tramite.feccap)}
          </div>
        </div>
      `

      const printWindow = window.open('', '_blank')
      printWindow.document.write(printContent)
      printWindow.document.close()
      printWindow.print()

      this.showToast('info', 'Enviando a impresora...')
    },

    // Sistema de Toast
    showToast(type, message) {
      const toast = {
        id: Date.now(),
        type: type,
        message: message
      }

      this.toasts.push(toast)

      // Auto remover después de 4 segundos
      setTimeout(() => {
        this.removeToast(toast.id)
      }, 4000)
    },

    removeToast(toastId) {
      const index = this.toasts.findIndex(toast => toast.id === toastId)
      if (index > -1) {
        this.toasts.splice(index, 1)
      }
    },

    // Método para generar datos simulados durante desarrollo
    async generarDatosSimulados() {
      console.log('🎭 Generando datos simulados para desarrollo...')

      const datosSimulados = [
        {
          id_tramite: 12345,
          folio: 'TR-2024-000001',
          propietario: 'Juan Pérez García',
          rfc: 'PEGJ850315ABC',
          cvecuenta: 150234,
          actividad: 'Venta de productos de abarrotes y comestibles en general',
          ubicacion: 'Av. Juárez #123, Col. Centro',
          colonia_ubic: 'Centro',
          numext_ubic: '123',
          estatus: 'A',
          feccap: new Date().toISOString(),
          capturista: 'admin',
          observaciones: 'Trámite procesado correctamente',
          inversion: 50000.00,
          num_empleados: 3,
          sup_autorizada: 120.50,
          total_registros: 8
        },
        {
          id_tramite: 12346,
          folio: 'TR-2024-000002',
          propietario: 'María Elena Rodríguez López',
          rfc: 'ROLM901225XYZ',
          cvecuenta: 150235,
          actividad: 'Restaurante de comida mexicana',
          ubicacion: 'Calle Morelos #456, Col. Americana',
          colonia_ubic: 'Americana',
          numext_ubic: '456',
          estatus: 'A',
          feccap: new Date(Date.now() - 86400000).toISOString(),
          capturista: 'operador1',
          observaciones: null,
          inversion: 120000.00,
          num_empleados: 8,
          sup_autorizada: 200.00,
          total_registros: 8
        },
        {
          id_tramite: 12347,
          folio: 'TR-2024-000003',
          propietario: 'Carlos Alberto Mendoza Silva',
          rfc: 'MESC750620DEF',
          cvecuenta: null,
          actividad: 'Taller mecánico automotriz',
          ubicacion: 'Av. Vallarta #789, Col. Providencia',
          colonia_ubic: 'Providencia',
          numext_ubic: '789',
          estatus: 'T',
          feccap: new Date(Date.now() - 172800000).toISOString(),
          capturista: 'operador2',
          observaciones: 'Pendiente de documentación adicional',
          inversion: 80000.00,
          num_empleados: 5,
          sup_autorizada: 150.00,
          total_registros: 8
        },
        {
          id_tramite: 12348,
          folio: 'TR-2024-000004',
          propietario: 'Ana Lucia Fernández Torres',
          rfc: 'FETA800910GHI',
          cvecuenta: 150236,
          actividad: 'Boutique de ropa y accesorios',
          ubicacion: 'Plaza del Sol, Local 45',
          colonia_ubic: 'Del Sol',
          numext_ubic: '45',
          estatus: 'A',
          feccap: new Date(Date.now() - 259200000).toISOString(),
          capturista: 'admin',
          observaciones: 'Licencia renovada',
          inversion: 35000.00,
          num_empleados: 2,
          sup_autorizada: 85.00,
          total_registros: 8
        },
        {
          id_tramite: 12349,
          folio: 'TR-2024-000005',
          propietario: 'Roberto Sánchez Morales',
          rfc: 'SAMR690515JKL',
          cvecuenta: 150237,
          actividad: 'Farmacia y productos de salud',
          ubicacion: 'Av. Patria #321, Col. Jardines del Bosque',
          colonia_ubic: 'Jardines del Bosque',
          numext_ubic: '321',
          estatus: 'C',
          feccap: new Date(Date.now() - 345600000).toISOString(),
          capturista: 'operador1',
          observaciones: 'Cancelado por solicitud del propietario',
          inversion: 90000.00,
          num_empleados: 4,
          sup_autorizada: 110.00,
          total_registros: 8
        },
        {
          id_tramite: 12350,
          folio: 'TR-2024-000006',
          propietario: 'Patricia Jiménez Herrera',
          rfc: 'JIHP920815MNO',
          cvecuenta: 150238,
          actividad: 'Peluquería y estética',
          ubicacion: 'Calle Chapultepec #654, Col. Santa Teresita',
          colonia_ubic: 'Santa Teresita',
          numext_ubic: '654',
          estatus: 'A',
          feccap: new Date(Date.now() - 432000000).toISOString(),
          capturista: 'operador2',
          observaciones: null,
          inversion: 25000.00,
          num_empleados: 3,
          sup_autorizada: 75.00,
          total_registros: 8
        },
        {
          id_tramite: 12351,
          folio: 'TR-2024-000007',
          propietario: 'Miguel Ángel Ruiz Castro',
          rfc: 'RUCM880405PQR',
          cvecuenta: 150239,
          actividad: 'Papelería y artículos de oficina',
          ubicacion: 'Av. López Mateos #987, Col. Chapalita',
          colonia_ubic: 'Chapalita',
          numext_ubic: '987',
          estatus: 'R',
          feccap: new Date(Date.now() - 518400000).toISOString(),
          capturista: 'admin',
          observaciones: 'Rechazado por documentación incompleta',
          inversion: 15000.00,
          num_empleados: 1,
          sup_autorizada: 45.00,
          total_registros: 8
        },
        {
          id_tramite: 12352,
          folio: 'TR-2024-000008',
          propietario: 'Sandra Leticia González Vega',
          rfc: 'GOVS950128STU',
          cvecuenta: 150240,
          actividad: 'Panadería y repostería artesanal',
          ubicacion: 'Calle Independencia #159, Col. Tlaquepaque Centro',
          colonia_ubic: 'Tlaquepaque Centro',
          numext_ubic: '159',
          estatus: 'A',
          feccap: new Date(Date.now() - 604800000).toISOString(),
          capturista: 'operador1',
          observaciones: 'Negocio familiar establecido',
          inversion: 40000.00,
          num_empleados: 6,
          sup_autorizada: 95.00,
          total_registros: 8
        }
      ]

      // Simular carga de datos
      this.loading = true
      await new Promise(resolve => setTimeout(resolve, 500))

      this.tramites = datosSimulados
      this.totalRegistros = 8
      this.totalPages = Math.ceil(this.totalRegistros / this.itemsPerPage)
      this.loading = false

      console.log(`✅ Generados ${datosSimulados.length} trámites simulados para desarrollo`)
      this.showToast('info', 'Datos simulados cargados para desarrollo')
    }
  },

  mounted() {
    console.log('ConsultaTramitefrm component mounted')
    this.loadTramites()
  }
}
</script>

