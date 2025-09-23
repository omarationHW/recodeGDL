<template>
  <div class="dictamen-uso-module">
    <!-- Header del módulo -->
    <div class="module-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="module-title">
            <i class="fas fa-map-marked-alt"></i>
            Dictámenes de Uso de Suelo
          </h3>
          <p class="module-description mb-0">
            Gestión y emisión de constancias de uso de suelo
          </p>
        </div>
        <div class="col-auto">
          <button
            class="btn btn-light"
            @click="showCreateModal = true"
            :disabled="loading"
          >
            <i class="fas fa-plus"></i>
            Nueva Constancia
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row">
          <div class="col-md-2">
            <label class="form-label">Año</label>
            <input
              type="number"
              class="form-control"
              v-model="filters.axo"
              placeholder="2024"
            >
          </div>
          <div class="col-md-2">
            <label class="form-label">Folio</label>
            <input
              type="number"
              class="form-control"
              v-model="filters.folio"
              placeholder="123"
            >
          </div>
          <div class="col-md-3">
            <label class="form-label">Solicitante</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.solicita"
              placeholder="Nombre del solicitante"
            >
          </div>
          <div class="col-md-2">
            <label class="form-label">Licencia</label>
            <input
              type="number"
              class="form-control"
              v-model="filters.licencia"
              placeholder="Número"
            >
          </div>
          <div class="col-md-3">
            <label class="form-label">Estado</label>
            <select class="form-select" v-model="filters.vigente">
              <option value="">Todos</option>
              <option value="V">Vigente</option>
              <option value="C">Cancelado</option>
            </select>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-12">
            <button
              class="btn btn-outline-teal me-2"
              @click="searchDictamenes"
              :disabled="loading"
            >
              <i class="fas fa-search"></i>
              Buscar
            </button>
            <button
              class="btn btn-outline-secondary me-2"
              @click="clearFilters"
              :disabled="loading"
            >
              <i class="fas fa-times"></i>
              Limpiar
            </button>
            <button
              class="btn btn-outline-success"
              @click="loadDictamenes"
              :disabled="loading"
            >
              <i class="fas fa-sync-alt"></i>
              Actualizar
            </button>
          </div>
        </div>
      </div>
    </div>
    <!-- Tabla de resultados -->
    <div class="card">
      <div class="card-header">
        <h6 class="mb-0">
          <i class="fas fa-map-marked-alt"></i>
          Dictámenes de Uso de Suelo
          <span v-if="dictamenes.length > 0" class="badge bg-teal ms-2">
            {{ dictamenes.length }} registros
          </span>
        </h6>
      </div>
      <div class="card-body">
        <!-- Loading state -->
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-teal" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2 text-muted">Cargando dictámenes de uso de suelo...</p>
        </div>

        <!-- Error state -->
        <div v-else-if="error" class="alert alert-danger">
          <h6 class="alert-heading">Error al cargar datos</h6>
          <p class="mb-0">{{ error }}</p>
          <hr>
          <button class="btn btn-outline-danger btn-sm" @click="loadDictamenes">
            <i class="fas fa-retry"></i>
            Reintentar
          </button>
        </div>

        <!-- Empty state -->
        <div v-else-if="dictamenes.length === 0" class="text-center py-5">
          <i class="fas fa-map-marked-alt fa-3x text-muted mb-3"></i>
          <h5 class="text-muted">No se encontraron dictámenes</h5>
          <p class="text-muted">
            {{ hasActiveFilters ? 'No hay registros que coincidan con los filtros aplicados.' : 'No hay dictámenes registrados en el sistema.' }}
          </p>
          <button
            v-if="!hasActiveFilters"
            class="btn btn-teal"
            @click="showCreateModal = true"
          >
            <i class="fas fa-plus"></i>
            Crear primer dictamen
          </button>
        </div>

        <!-- Tabla con datos -->
        <div v-else class="table-responsive">
          <table class="table table-hover">
            <thead class="table-light">
              <tr>
                <th>Año-Folio</th>
                <th>Solicitante</th>
                <th>Licencia</th>
                <th>Tipo</th>
                <th>Domicilio</th>
                <th>Estado</th>
                <th>Fecha</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="dictamen in dictamenes" :key="dictamen.id">
                <td>
                  <strong class="text-teal">{{ dictamen.axo }}-{{ dictamen.folio }}</strong>
                </td>
                <td>{{ dictamen.solicita }}</td>
                <td>
                  <span v-if="dictamen.licencia" class="badge bg-info">{{ dictamen.licencia }}</span>
                  <span v-else class="text-muted">N/A</span>
                </td>
                <td>
                  <span class="badge" :class="getTipoBadgeClass(dictamen.tipo)">
                    {{ dictamen.tipo_texto }}
                  </span>
                </td>
                <td>{{ dictamen.domicilio || 'N/A' }}</td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(dictamen.vigente)">
                    {{ dictamen.vigente_texto }}
                  </span>
                </td>
                <td>{{ formatDate(dictamen.feccap) }}</td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <button
                      class="btn btn-outline-primary"
                      @click="viewDictamen(dictamen)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn btn-outline-warning"
                      @click="editDictamen(dictamen)"
                      title="Editar"
                      :disabled="dictamen.vigente === 'C'"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      class="btn btn-outline-success"
                      @click="printDictamen(dictamen)"
                      title="Generar PDF"
                    >
                      <i class="fas fa-file-pdf"></i>
                    </button>
                    <button
                      v-if="dictamen.vigente === 'V'"
                      class="btn btn-outline-danger"
                      @click="cancelDictamen(dictamen)"
                      title="Cancelar"
                    >
                      <i class="fas fa-ban"></i>
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
          <nav aria-label="Paginación de dictámenes">
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

    <!-- Modal para crear/editar dictamen -->
    <div class="modal fade" tabindex="-1" v-if="showCreateModal" style="display: block;" @click.self="showCreateModal = false">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-map-marked-alt"></i>
              {{ editingDictamen ? 'Editar Dictamen' : 'Nuevo Dictamen' }}
            </h5>
            <button type="button" class="btn-close" @click="showCreateModal = false"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveDictamen">
              <div class="row">
                <div class="col-md-6">
                  <label class="form-label">Solicitante <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDictamen.solicita"
                    placeholder="Nombre del solicitante"
                    required
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Número de Licencia</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="newDictamen.licencia"
                    placeholder="Número de licencia"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="form-label">Tipo de Dictamen</label>
                  <select class="form-select" v-model="newDictamen.tipo">
                    <option value="0">Licencia</option>
                    <option value="1">No Licencia</option>
                    <option value="2">No Licencia Propietario</option>
                    <option value="3">No Licencia Vigente</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Partida de Pago</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDictamen.partidapago"
                    placeholder="Número de partida"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="form-label">Capturista</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDictamen.capturista"
                    placeholder="Nombre del capturista"
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">ID Licencia</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="newDictamen.id_licencia"
                    placeholder="ID interno"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="form-label">Domicilio</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDictamen.domicilio"
                    placeholder="Dirección completa"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="form-label">Observaciones</label>
                  <textarea
                    class="form-control"
                    rows="3"
                    v-model="newDictamen.observacion"
                    placeholder="Observaciones o comentarios adicionales"
                  ></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showCreateModal = false">
              Cancelar
            </button>
            <button
              type="button"
              class="btn btn-teal"
              @click="saveDictamen"
              :disabled="creating || !newDictamen.solicita"
            >
              <span v-if="creating">
                <i class="fas fa-spinner fa-spin"></i>
                {{ editingDictamen ? 'Actualizando...' : 'Creando...' }}
              </span>
              <span v-else>
                <i class="fas fa-save"></i>
                {{ editingDictamen ? 'Actualizar Dictamen' : 'Crear Dictamen' }}
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showCreateModal" class="modal-backdrop fade show"></div>

    <!-- Modal de detalles del dictamen -->
    <div v-if="showDetailsModal" class="modal-overlay" @click.self="showDetailsModal = false">
      <div class="modal-content" style="max-width: 800px;">
        <div class="modal-header">
          <h2>
            <i class="fas fa-map-marked-alt"></i>
            Detalles del Dictamen
          </h2>
          <button class="close-btn" @click="showDetailsModal = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body" v-if="selectedDictamen">
          <div class="row">
            <div class="col-12 mb-4">
              <div class="alert alert-teal">
                <h5 class="alert-heading mb-2">
                  <i class="fas fa-map-marked-alt"></i>
                  Dictamen: {{ selectedDictamen.axo }}-{{ selectedDictamen.folio }}
                </h5>
                <p class="mb-0">{{ selectedDictamen.solicita }}</p>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-md-6">
              <div class="card h-100">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-user"></i>
                    Información del Solicitante
                  </h6>
                </div>
                <div class="card-body">
                  <div class="form-group mb-3">
                    <label class="form-label">Solicitante:</label>
                    <p class="form-control-plaintext">{{ selectedDictamen.solicita }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">Domicilio:</label>
                    <p class="form-control-plaintext">{{ selectedDictamen.domicilio || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-0">
                    <label class="form-label">Capturista:</label>
                    <p class="form-control-plaintext">{{ selectedDictamen.capturista || 'N/A' }}</p>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-md-6">
              <div class="card h-100">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-file-alt"></i>
                    Detalles del Dictamen
                  </h6>
                </div>
                <div class="card-body">
                  <div class="form-group mb-3">
                    <label class="form-label">Tipo:</label>
                    <span class="badge" :class="getTipoBadgeClass(selectedDictamen.tipo)">
                      {{ selectedDictamen.tipo_texto }}
                    </span>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">Estado:</label>
                    <span class="badge" :class="getEstadoBadgeClass(selectedDictamen.vigente)">
                      {{ selectedDictamen.vigente_texto }}
                    </span>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">Fecha de Captura:</label>
                    <p class="form-control-plaintext">{{ formatDate(selectedDictamen.feccap) }}</p>
                  </div>
                  <div class="form-group mb-0" v-if="selectedDictamen.licencia">
                    <label class="form-label">Licencia:</label>
                    <span class="badge bg-info">{{ selectedDictamen.licencia }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="row mt-4" v-if="selectedDictamen.observacion">
            <div class="col-12">
              <div class="card">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-comment"></i>
                    Observaciones
                  </h6>
                </div>
                <div class="card-body">
                  <p class="mb-0">{{ selectedDictamen.observacion }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-teal" @click="editDictamen(selectedDictamen)" :disabled="selectedDictamen.vigente === 'C'">
            <i class="fas fa-edit"></i>
            Editar Dictamen
          </button>
          <button class="btn btn-success" @click="printDictamenInfo(selectedDictamen)">
            <i class="fas fa-print"></i>
            Imprimir
          </button>
          <button class="btn btn-secondary" @click="showDetailsModal = false">
            <i class="fas fa-times"></i>
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
          <button class="btn btn-primary" @click="closeSweetAlert">
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
  name: 'DictamenUsoDeSuelo',
  data() {
    return {
      // Estado de carga
      loading: false,
      creating: false,
      error: null,

      // Datos
      dictamenes: [],
      totalRegistros: 0,

      // Paginación
      currentPage: 1,
      itemsPerPage: 10,
      totalPages: 0,

      // Filtros
      filters: {
        axo: '',
        folio: '',
        solicita: '',
        licencia: '',
        vigente: ''
      },

      // Modal
      showCreateModal: false,
      editingDictamen: null,

      // Modales
      showDetailsModal: false,
      selectedDictamen: null,

      // SweetAlert
      sweetAlert: {
        show: false,
        type: 'info',
        title: '',
        text: ''
      },

      // Toast notifications
      toasts: [],

      // Nuevo dictamen
      newDictamen: {
        solicita: '',
        partidapago: '',
        observacion: '',
        domicilio: '',
        licencia: '',
        id_licencia: null,
        tipo: 0,
        capturista: 'SISTEMA'
      }
    }
  },

  computed: {
    hasActiveFilters() {
      return Object.values(this.filters).some(value => value !== null && value !== '')
    }
  },
  methods: {
    async loadDictamenes() {
      this.loading = true
      this.error = null

      try {
        // Llamada real a la API usando SP_DICTAMENUSO_LIST
        const eRequest = {
          Operacion: 'sp_dictamenuso_list',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_axo', valor: this.filters.axo ? parseInt(this.filters.axo) : null },
            { nombre: 'p_folio', valor: this.filters.folio ? parseInt(this.filters.folio) : null },
            { nombre: 'p_solicita', valor: this.filters.solicita || null },
            { nombre: 'p_licencia', valor: this.filters.licencia ? parseInt(this.filters.licencia) : null },
            { nombre: 'p_vigente', valor: this.filters.vigente || null },
            { nombre: 'p_fecha_ini', valor: null },
            { nombre: 'p_fecha_fin', valor: null },
            { nombre: 'p_limite', valor: this.itemsPerPage },
            { nombre: 'p_offset', valor: (this.currentPage - 1) * this.itemsPerPage }
          ],
          Tenant: 'informix'
        }

        console.log('📨 Cargando dictámenes uso de suelo con SP_DICTAMENUSO_LIST:', eRequest)

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
          this.dictamenes = data.eResponse.data.result || []

          // Obtener el total de registros del primer elemento (si existe)
          if (this.dictamenes.length > 0) {
            this.totalRegistros = parseInt(this.dictamenes[0].total_registros) || 0
            this.totalPages = Math.ceil(this.totalRegistros / this.itemsPerPage)
          } else {
            this.totalRegistros = 0
            this.totalPages = 0
          }

          console.log(`✅ Cargados ${this.dictamenes.length} dictámenes de ${this.totalRegistros} totales (Página ${this.currentPage}/${this.totalPages})`)
        } else {
          throw new Error(data.eResponse.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.error = 'Error al cargar los dictámenes: ' + error.message
        console.error('❌ Error loading dictámenes:', error)
      } finally {
        this.loading = false
      }
    },
    async searchDictamenes() {
      console.log('🔍 Buscando dictámenes con filtros:', this.filters)
      this.currentPage = 1 // Reset to first page when searching
      this.loadDictamenes()
    },

    clearFilters() {
      this.filters = {
        axo: '',
        folio: '',
        solicita: '',
        licencia: '',
        vigente: ''
      }
      this.currentPage = 1 // Reset to first page
      this.loadDictamenes()
    },
    async guardar() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'create',
            data: this.form
          }
        })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        this.mensaje = 'Guardado correctamente';
        this.listar();
      } else {
        this.mensaje = json.eResponse.error;
      }
    },
    cancelar() {
      this.formVisible = false;
      this.listadoVisible = true;
      this.mensaje = '';
    },
    editar(item) {
      this.form = { ...item };
      this.formVisible = true;
      this.listadoVisible = false;
      this.mensaje = '';
    },
    async cancelarConstancia(item) {
      if (!confirm('¿Está seguro de cancelar la constancia?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'cancel',
            data: {
              axo: item.axo,
              folio: item.folio,
              motivo: 'Cancelada por usuario'
            }
          }
        })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        this.mensaje = 'Constancia cancelada';
        this.listar();
      } else {
        this.mensaje = json.eResponse.error;
      }
    },
    viewDictamen(dictamen) {
      console.log('View dictamen:', dictamen)
      this.showDictamenDetailsModal(dictamen)
    },

    printDictamen(dictamen) {
      console.log('Print dictamen:', dictamen)
      this.printDictamenInfo(dictamen)
    },

    getTipoBadgeClass(tipo) {
      const classes = {
        0: 'bg-primary',    // Licencia
        1: 'bg-warning',    // No Licencia
        2: 'bg-info',       // No Licencia Propietario
        3: 'bg-secondary'   // No Licencia Vigente
      }
      return classes[tipo] || 'bg-light'
    },

    getEstadoBadgeClass(vigente) {
      return vigente === 'V' ? 'bg-success' : 'bg-danger'
    },

    formatDate(date) {
      if (!date) return 'N/A'
      return new Date(date).toLocaleDateString('es-ES')
    },

    // Métodos de paginación
    goToPage(page) {
      if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
        this.currentPage = page
        this.loadDictamenes()
      }
    },

    previousPage() {
      if (this.currentPage > 1) {
        this.currentPage--
        this.loadDictamenes()
      }
    },

    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++
        this.loadDictamenes()
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
    },

    showConfirmSweetAlert(type, title, text) {
      return new Promise((resolve) => {
        // Implementación simple de confirmación
        const confirmed = confirm(`${title}\n\n${text}`)
        resolve(confirmed)
      })
    },

    closeSweetAlert() {
      this.sweetAlert.show = false

      // Auto cerrar después de 3 segundos para success e info, 5 segundos para error y warning
      const autoCloseTime = (this.sweetAlert.type === 'success' || this.sweetAlert.type === 'info') ? 3000 : 5000;
      setTimeout(() => {
        this.sweetAlert.show = false;
      }, autoCloseTime);
    },

    // Ver detalles del dictamen en modal
    showDictamenDetailsModal(dictamen) {
      this.selectedDictamen = dictamen
      this.showDetailsModal = true
    },

    // Imprimir información del dictamen
    printDictamenInfo(dictamen) {
      const printContent = `
        <div style="font-family: Arial, sans-serif; padding: 20px;">
          <h2>Dictamen de Uso de Suelo</h2>
          <div style="margin: 20px 0;">
            <strong>Folio:</strong> ${dictamen.axo}-${dictamen.folio}<br>
            <strong>Solicitante:</strong> ${dictamen.solicita}<br>
            <strong>Tipo:</strong> ${dictamen.tipo_texto}<br>
            <strong>Estado:</strong> ${dictamen.vigente_texto}<br>
            <strong>Domicilio:</strong> ${dictamen.domicilio || 'N/A'}<br>
            <strong>Licencia:</strong> ${dictamen.licencia || 'N/A'}<br>
            <strong>Partida de Pago:</strong> ${dictamen.partidapago || 'N/A'}<br>
            <strong>Fecha:</strong> ${this.formatDate(dictamen.feccap)}<br>
            <strong>Capturista:</strong> ${dictamen.capturista || 'N/A'}
          </div>
          ${dictamen.observacion ? `<div><strong>Observaciones:</strong><br>${dictamen.observacion}</div>` : ''}
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
    }
  },

  mounted() {
    console.log('DictamenUsoDeSuelo component mounted')
    this.loadDictamenes()
  }
};
</script>

<style scoped>
/* Estilos específicos del módulo de dictámenes uso de suelo */
.dictamen-uso-module {
  padding: 1rem;
}

.module-header {
  background: linear-gradient(135deg, #20c997 0%, #17a2b8 100%);
  color: white;
  padding: 1.5rem;
  border-radius: 0.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.module-title {
  margin: 0;
  font-weight: 600;
}

.module-description {
  opacity: 0.9;
  font-size: 0.95rem;
}

/* Hover específico para dictámenes uso de suelo */
.table-hover tbody tr:hover {
  background-color: rgba(32, 201, 151, 0.05);
}

/* Botón personalizado teal */
.btn-teal {
  background-color: #20c997;
  border-color: #20c997;
  color: white;
}

.btn-teal:hover {
  background-color: #1aa085;
  border-color: #1aa085;
  color: white;
}

.btn-outline-teal {
  color: #20c997;
  border-color: #20c997;
}

.btn-outline-teal:hover {
  background-color: #20c997;
  border-color: #20c997;
  color: white;
}

/* Badge personalizado teal */
.bg-teal {
  background-color: #20c997 !important;
}

/* Alert personalizado teal */
.alert-teal {
  background-color: #d4f4ed;
  border-color: #20c997;
  color: #155724;
}

/* Paginación con tema teal para dictámenes uso suelo */
.pagination .page-link {
  color: #20c997;
  border-color: #dee2e6;
  padding: 0.375rem 0.75rem;
}

.pagination .page-link:hover {
  color: #1aa085;
  background-color: #e9ecef;
  border-color: #adb5bd;
}

.pagination .page-item.active .page-link {
  background-color: #20c997;
  border-color: #20c997;
  color: white;
}

.pagination .page-link:focus {
  box-shadow: 0 0 0 0.2rem rgba(32, 201, 151, 0.25);
}

/* SweetAlert Modal */
.swal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
}

.swal-modal {
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  max-width: 450px;
  width: 90%;
  padding: 2rem;
  text-align: center;
}

.swal-icon {
  width: 70px;
  height: 70px;
  border-radius: 50%;
  margin: 0 auto 1.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  color: white;
}

.swal-icon.success { background: #28a745; }
.swal-icon.error { background: #dc3545; }
.swal-icon.warning { background: #ffc107; color: #333 !important; }
.swal-icon.info { background: #17a2b8; }

.swal-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: #333;
  margin-bottom: 1rem;
}

.swal-text {
  color: #666;
  font-size: 1rem;
  line-height: 1.5;
  margin-bottom: 2rem;
}

/* Modal overlay */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1050;
}

.modal-content {
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  max-width: 95%;
  max-height: 90%;
  overflow-y: auto;
}

.modal-header {
  padding: 1.5rem;
  border-bottom: 1px solid #dee2e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: linear-gradient(135deg, #20c997 0%, #17a2b8 100%);
  color: white;
  border-radius: 12px 12px 0 0;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
}

.close-btn {
  background: none;
  border: none;
  color: white;
  font-size: 1.5rem;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: background-color 0.2s;
}

.close-btn:hover {
  background-color: rgba(255, 255, 255, 0.2);
}

.modal-body {
  padding: 1.5rem;
}

.modal-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid #dee2e6;
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}

/* Toast Notifications */
.toast-notification {
  position: fixed;
  right: 20px;
  min-width: 300px;
  max-width: 400px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1500;
  animation: slideIn 0.3s ease-out;
  padding: 1rem;
  color: white;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.toast-notification.success {
  background: linear-gradient(135deg, #28a745, #20c997);
}

.toast-notification.error {
  background: linear-gradient(135deg, #dc3545, #c82333);
}

.toast-notification.warning {
  background: linear-gradient(135deg, #ffc107, #fd7e14);
  color: #212529;
}

.toast-notification.info {
  background: linear-gradient(135deg, #17a2b8, #20c997);
}

.toast-icon {
  font-size: 1.25rem;
  flex-shrink: 0;
}

.toast-message {
  flex: 1;
  font-weight: 500;
}

.toast-close {
  background: none;
  border: none;
  color: inherit;
  font-size: 1rem;
  cursor: pointer;
  padding: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: background-color 0.2s;
  opacity: 0.8;
}

.toast-close:hover {
  background-color: rgba(255, 255, 255, 0.2);
  opacity: 1;
}

/* Estilos específicos para detalles */
.form-control-plaintext {
  background-color: transparent;
  border: none;
  padding: 0;
  margin: 0;
  font-weight: 500;
  color: #495057;
}

.card.h-100 {
  height: 100% !important;
}

/* Badge personalizado */
.badge.bg-success { background-color: #28a745 !important; }
.badge.bg-danger { background-color: #dc3545 !important; }
.badge.bg-primary { background-color: #007bff !important; }
.badge.bg-warning { background-color: #ffc107 !important; color: #212529 !important; }
.badge.bg-info { background-color: #17a2b8 !important; }
.badge.bg-secondary { background-color: #6c757d !important; }

/* Color específico para spinner de loading */
.text-teal {
  color: #20c997 !important;
}

.spinner-border.text-teal {
  color: #20c997 !important;
}

/* Responsive */
@media (max-width: 768px) {
  .dictamen-uso-module {
    padding: 0.5rem;
  }

  .module-header {
    padding: 1rem;
  }

  .card-body .row {
    flex-direction: column;
  }

  .col-md-2, .col-md-3 {
    margin-bottom: 1rem;
  }

  .table-responsive {
    font-size: 0.875rem;
  }

  .toast-notification {
    right: 10px;
    left: 10px;
    min-width: auto;
  }
}
</style>
