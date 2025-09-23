<template>
  <div class="dictamen-module">
    <!-- Header del módulo -->
    <div class="module-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="module-title">
            <i class="fas fa-file-signature"></i>
            Dictámenes de Anuncios
          </h3>
          <p class="module-description mb-0">
            Gestión y emisión de dictámenes para anuncios publicitarios
          </p>
        </div>
        <div class="col-auto">
          <button
            class="btn btn-light"
            @click="showCreateModal = true"
            :disabled="loading"
          >
            <i class="fas fa-plus"></i>
            Nuevo Dictamen
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="form-label">Número de Anuncio</label>
            <input
              type="number"
              class="form-control"
              v-model="filters.anuncio"
              placeholder="Ej: 12345"
            >
          </div>
          <div class="col-md-3">
            <label class="form-label">Propietario</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.propietario"
              placeholder="Nombre del propietario"
            >
          </div>
          <div class="col-md-3">
            <label class="form-label">Clasificación</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.clasificacion"
              placeholder="Tipo de anuncio"
            >
          </div>
          <div class="col-md-3">
            <label class="form-label">Ubicación</label>
            <input
              type="text"
              class="form-control"
              v-model="filters.ubicacion"
              placeholder="Dirección del anuncio"
            >
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-12">
            <button
              class="btn btn-outline-danger me-2"
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
          <i class="fas fa-file-signature"></i>
          Dictámenes de Anuncios
          <span v-if="dictamenes.length > 0" class="badge bg-danger ms-2">
            {{ dictamenes.length }} registros
          </span>
        </h6>
      </div>
      <div class="card-body">
        <!-- Loading state -->
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-danger" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2 text-muted">Cargando dictámenes de anuncios...</p>
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
          <i class="fas fa-file-signature fa-3x text-muted mb-3"></i>
          <h5 class="text-muted">No se encontraron dictámenes</h5>
          <p class="text-muted">
            {{ hasActiveFilters ? 'No hay registros que coincidan con los filtros aplicados.' : 'No hay dictámenes registrados en el sistema.' }}
          </p>
          <button
            v-if="!hasActiveFilters"
            class="btn btn-danger"
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
                <th>No. Anuncio</th>
                <th>Propietario</th>
                <th>Clasificación</th>
                <th>Ubicación</th>
                <th>Medidas</th>
                <th>Área</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="dictamen in dictamenes" :key="dictamen.id">
                <td>
                  <strong class="text-danger">{{ dictamen.anuncio }}</strong>
                </td>
                <td>{{ dictamen.propietarionvo }}</td>
                <td>
                  <span class="badge bg-secondary">{{ dictamen.clasificacion || 'N/A' }}</span>
                </td>
                <td>{{ formatDireccion(dictamen) }}</td>
                <td>{{ dictamen.medidas1 || 0 }} x {{ dictamen.medidas2 || 0 }} m</td>
                <td>
                  <span class="badge bg-info">{{ dictamen.area_anuncio || 0 }} m²</span>
                </td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(dictamen.vigente)">
                    {{ dictamen.vigente === 'V' ? 'Vigente' : 'Inactivo' }}
                  </span>
                </td>
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
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-file-signature"></i>
              {{ editingDictamen ? 'Editar Dictamen' : 'Nuevo Dictamen' }}
            </h5>
            <button type="button" class="btn-close" @click="showCreateModal = false"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveDictamen">
              <div class="row">
                <div class="col-md-6">
                  <label class="form-label">Número de Anuncio <span class="text-danger">*</span></label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="newDictamen.anuncio"
                    placeholder="Ej: 12345"
                    required
                    :disabled="editingDictamen"
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">ID Licencia</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="newDictamen.id_licencia"
                    placeholder="ID de licencia relacionada"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-8">
                  <label class="form-label">Ubicación <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDictamen.ubicacion"
                    placeholder="Dirección completa del anuncio"
                    required
                  >
                </div>
                <div class="col-md-4">
                  <label class="form-label">Número Exterior</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="newDictamen.numext_ubic"
                    placeholder="123"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-3">
                  <label class="form-label">Letra Exterior</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDictamen.letraext_ubic"
                    placeholder="A"
                    maxlength="5"
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Colonia</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="newDictamen.colonia_ubic"
                    placeholder="Nombre de la colonia"
                    maxlength="100"
                  >
                </div>
                <div class="col-md-3">
                  <label class="form-label">Código Postal</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="newDictamen.cp"
                    placeholder="44100"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-3">
                  <label class="form-label">Medida 1 (m)</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="newDictamen.medidas1"
                    placeholder="0.00"
                    step="0.01"
                  >
                </div>
                <div class="col-md-3">
                  <label class="form-label">Medida 2 (m)</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="newDictamen.medidas2"
                    placeholder="0.00"
                    step="0.01"
                  >
                </div>
                <div class="col-md-3">
                  <label class="form-label">Número de Caras</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="newDictamen.num_caras"
                    placeholder="1"
                    min="1"
                  >
                </div>
                <div class="col-md-3">
                  <label class="form-label">ID Giro</label>
                  <input
                    type="number"
                    class="form-control"
                    v-model="newDictamen.id_giro"
                    placeholder="ID del giro"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="form-label">Texto del Anuncio</label>
                  <textarea
                    class="form-control"
                    rows="3"
                    v-model="newDictamen.texto_anuncio"
                    placeholder="Descripción del contenido del anuncio"
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
              class="btn btn-danger"
              @click="saveDictamen"
              :disabled="creating || !newDictamen.anuncio || !newDictamen.ubicacion"
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
            <i class="fas fa-file-signature"></i>
            Detalles del Dictamen
          </h2>
          <button class="close-btn" @click="showDetailsModal = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body" v-if="selectedDictamen">
          <div class="row">
            <div class="col-12 mb-4">
              <div class="alert alert-danger">
                <h5 class="alert-heading mb-2">
                  <i class="fas fa-file-signature"></i>
                  Anuncio Número: {{ selectedDictamen.anuncio }}
                </h5>
                <p class="mb-0">{{ selectedDictamen.propietarionvo }}</p>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-md-6">
              <div class="card h-100">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-map-marker-alt"></i>
                    Ubicación
                  </h6>
                </div>
                <div class="card-body">
                  <div class="form-group mb-3">
                    <label class="form-label">Dirección:</label>
                    <p class="form-control-plaintext">{{ formatDireccion(selectedDictamen) }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">Clasificación:</label>
                    <span class="badge bg-secondary">{{ selectedDictamen.clasificacion || 'N/A' }}</span>
                  </div>
                  <div class="form-group mb-0">
                    <label class="form-label">Estado:</label>
                    <span class="badge" :class="getEstadoBadgeClass(selectedDictamen.vigente)">
                      {{ selectedDictamen.vigente === 'V' ? 'Vigente' : 'Inactivo' }}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-md-6">
              <div class="card h-100">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-ruler"></i>
                    Dimensiones
                  </h6>
                </div>
                <div class="card-body">
                  <div class="form-group mb-3">
                    <label class="form-label">Medidas:</label>
                    <p class="form-control-plaintext">
                      {{ selectedDictamen.medidas1 || 0 }} x {{ selectedDictamen.medidas2 || 0 }} metros
                    </p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="form-label">Área Total:</label>
                    <p class="form-control-plaintext text-info fw-bold">
                      {{ selectedDictamen.area_anuncio || 0 }} m²
                    </p>
                  </div>
                  <div class="form-group mb-0">
                    <label class="form-label">Número de Caras:</label>
                    <span class="badge bg-info">{{ selectedDictamen.num_caras || 1 }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="row mt-4" v-if="selectedDictamen.descripcion">
            <div class="col-12">
              <div class="card">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-comment"></i>
                    Descripción
                  </h6>
                </div>
                <div class="card-body">
                  <p class="mb-0">{{ selectedDictamen.descripcion }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-danger" @click="editDictamen(selectedDictamen)">
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
  name: 'DictamenFrm',
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
        anuncio: '',
        propietario: '',
        clasificacion: '',
        ubicacion: ''
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
        anuncio: '',
        id_licencia: null,
        id_giro: 1,
        ubicacion: '',
        numext_ubic: null,
        letraext_ubic: '',
        colonia_ubic: '',
        medidas1: null,
        medidas2: null,
        num_caras: 1,
        texto_anuncio: '',
        cp: null
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
        // Llamada real a la API usando SP_DICTAMEN_LIST
        const eRequest = {
          Operacion: 'sp_dictamen_list',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_anuncio', valor: this.filters.anuncio ? parseInt(this.filters.anuncio) : null },
            { nombre: 'p_propietario', valor: this.filters.propietario || null },
            { nombre: 'p_clasificacion', valor: this.filters.clasificacion || null },
            { nombre: 'p_ubicacion', valor: this.filters.ubicacion || null },
            { nombre: 'p_vigente', valor: 'V' },
            { nombre: 'p_limite', valor: this.itemsPerPage },
            { nombre: 'p_offset', valor: (this.currentPage - 1) * this.itemsPerPage }
          ],
          Tenant: 'informix'
        }

        console.log('📨 Cargando dictámenes con SP_DICTAMEN_LIST:', eRequest)

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
        anuncio: '',
        propietario: '',
        clasificacion: '',
        ubicacion: ''
      }
      this.currentPage = 1 // Reset to first page
      this.loadDictamenes()
    },
    async saveDictamen() {
      if (!this.newDictamen.anuncio || !this.newDictamen.ubicacion) {
        this.showSweetAlert('warning', 'Campos Requeridos', 'Por favor complete los campos requeridos (Número de Anuncio y Ubicación)')
        return
      }

      this.creating = true

      try {
        let eRequest

        if (this.editingDictamen) {
          // Actualizar dictamen existente
          eRequest = {
            Operacion: 'SP_DICTAMEN_UPDATE',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_id_anuncio', valor: this.editingDictamen.id },
              { nombre: 'p_ubicacion', valor: this.newDictamen.ubicacion },
              { nombre: 'p_numext_ubic', valor: this.newDictamen.numext_ubic || null },
              { nombre: 'p_letraext_ubic', valor: this.newDictamen.letraext_ubic || null },
              { nombre: 'p_colonia_ubic', valor: this.newDictamen.colonia_ubic || null },
              { nombre: 'p_medidas1', valor: this.newDictamen.medidas1 || null },
              { nombre: 'p_medidas2', valor: this.newDictamen.medidas2 || null },
              { nombre: 'p_num_caras', valor: this.newDictamen.num_caras || null },
              { nombre: 'p_texto_anuncio', valor: this.newDictamen.texto_anuncio || null },
              { nombre: 'p_cp', valor: this.newDictamen.cp || null }
            ],
            Tenant: 'informix'
          }
        } else {
          // Crear nuevo dictamen
          eRequest = {
            Operacion: 'SP_DICTAMEN_CREATE',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_anuncio', valor: parseInt(this.newDictamen.anuncio) },
              { nombre: 'p_id_licencia', valor: this.newDictamen.id_licencia || null },
              { nombre: 'p_id_giro', valor: this.newDictamen.id_giro || 1 },
              { nombre: 'p_ubicacion', valor: this.newDictamen.ubicacion },
              { nombre: 'p_numext_ubic', valor: this.newDictamen.numext_ubic || null },
              { nombre: 'p_letraext_ubic', valor: this.newDictamen.letraext_ubic || null },
              { nombre: 'p_colonia_ubic', valor: this.newDictamen.colonia_ubic || null },
              { nombre: 'p_medidas1', valor: this.newDictamen.medidas1 || null },
              { nombre: 'p_medidas2', valor: this.newDictamen.medidas2 || null },
              { nombre: 'p_num_caras', valor: this.newDictamen.num_caras || 1 },
              { nombre: 'p_texto_anuncio', valor: this.newDictamen.texto_anuncio || null },
              { nombre: 'p_cp', valor: this.newDictamen.cp || null }
            ],
            Tenant: 'informix'
          }
        }

        console.log(`📨 ${this.editingDictamen ? 'Actualizando' : 'Creando'} dictamen:`, eRequest)

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
              this.editingDictamen ? 'Dictamen Actualizado' : 'Dictamen Creado',
              result.message || (this.editingDictamen ? 'Dictamen actualizado exitosamente' : 'Dictamen creado exitosamente')
            )
            this.resetCreateForm()
            this.showCreateModal = false
            this.loadDictamenes()
          } else {
            this.showSweetAlert('error', 'Error', result.message || 'Error en la operación')
            return
          }
        } else {
          throw new Error(data.eResponse.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Guardar', 'Error al guardar el dictamen: ' + error.message)
        console.error('❌ Error saving dictamen:', error)
      } finally {
        this.creating = false
      }
    },

    editDictamen(dictamen) {
      this.editingDictamen = dictamen
      this.newDictamen = {
        anuncio: dictamen.anuncio,
        id_licencia: dictamen.id_licencia,
        id_giro: dictamen.id_giro || 1,
        ubicacion: dictamen.ubicacion,
        numext_ubic: dictamen.numext_ubic,
        letraext_ubic: dictamen.letraext_ubic || '',
        colonia_ubic: dictamen.colonia_ubic || '',
        medidas1: dictamen.medidas1,
        medidas2: dictamen.medidas2,
        num_caras: dictamen.num_caras,
        texto_anuncio: dictamen.texto_anuncio || '',
        cp: dictamen.cp
      }
      this.showCreateModal = true
      this.showDetailsModal = false
    },

    resetCreateForm() {
      this.editingDictamen = null
      this.newDictamen = {
        anuncio: '',
        id_licencia: null,
        id_giro: 1,
        ubicacion: '',
        numext_ubic: null,
        letraext_ubic: '',
        colonia_ubic: '',
        medidas1: null,
        medidas2: null,
        num_caras: 1,
        texto_anuncio: '',
        cp: null
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

    formatDireccion(data) {
      if (!data) return 'No especificada'

      let direccion = data.ubicacion || ''
      if (data.numext_ubic) direccion += ` #${data.numext_ubic}`
      if (data.letraext_ubic) direccion += data.letraext_ubic
      if (data.colonia_ubic) direccion += `, Col. ${data.colonia_ubic}`
      if (data.cp) direccion += `, CP ${data.cp}`

      return direccion || 'Dirección no especificada'
    },

    getEstadoBadgeClass(vigente) {
      return vigente === 'V' ? 'bg-success' : 'bg-secondary'
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
          <h2>Dictamen de Anuncio</h2>
          <div style="margin: 20px 0;">
            <strong>Número de Anuncio:</strong> ${dictamen.anuncio}<br>
            <strong>Propietario:</strong> ${dictamen.propietarionvo}<br>
            <strong>Ubicación:</strong> ${this.formatDireccion(dictamen)}<br>
            <strong>Clasificación:</strong> ${dictamen.clasificacion || 'N/A'}<br>
            <strong>Medidas:</strong> ${dictamen.medidas1 || 0} x ${dictamen.medidas2 || 0} metros<br>
            <strong>Área Total:</strong> ${dictamen.area_anuncio || 0} m²<br>
            <strong>Número de Caras:</strong> ${dictamen.num_caras || 1}<br>
            <strong>Estado:</strong> ${dictamen.vigente === 'V' ? 'Vigente' : 'Inactivo'}<br>
            <strong>Fecha:</strong> ${dictamen.fecha_otorgamiento || 'N/A'}
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
    }
  },

  mounted() {
    console.log('DictamenFrm component mounted')
    this.loadDictamenes()
  }
};
</script>

<style scoped>
/* Estilos específicos del módulo de dictámenes */
.dictamen-module {
  padding: 1rem;
}

.module-header {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
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

/* Hover específico para dictámenes */
.table-hover tbody tr:hover {
  background-color: rgba(220, 53, 69, 0.05);
}

/* Paginación con tema rojo para dictámenes */
.pagination .page-link {
  color: #dc3545;
  border-color: #dee2e6;
  padding: 0.375rem 0.75rem;
}

.pagination .page-link:hover {
  color: #a71e2a;
  background-color: #e9ecef;
  border-color: #adb5bd;
}

.pagination .page-item.active .page-link {
  background-color: #dc3545;
  border-color: #dc3545;
  color: white;
}

.pagination .page-link:focus {
  box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25);
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
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
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
  background: linear-gradient(135deg, #17a2b8, #007bff);
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
.badge.bg-secondary { background-color: #6c757d !important; }
.badge.bg-danger { background-color: #dc3545 !important; }
.badge.bg-info { background-color: #17a2b8 !important; }

/* Responsive */
@media (max-width: 768px) {
  .dictamen-module {
    padding: 0.5rem;
  }

  .module-header {
    padding: 1rem;
  }

  .card-body .row {
    flex-direction: column;
  }

  .col-md-3, .col-md-6 {
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
