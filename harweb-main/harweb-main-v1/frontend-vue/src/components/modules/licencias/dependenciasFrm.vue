<template>
  <div class="municipal-form-page">
    <!-- Header del módulo -->
    <div class="municipal-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="mb-1">
            <i class="fas fa-building-columns me-2"></i>
            Gestión de Dependencias
          </h3>
          <p class="mb-0 opacity-90">
            Administración de dependencias gubernamentales para el sistema de licencias
          </p>
        </div>
        <div class="col-auto">
          <button
            class="btn-municipal-primary"
            @click="showCreateModal = true"
            :disabled="loading"
          >
            <i class="fas fa-plus me-1"></i>
            Nueva Dependencia
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card mb-4">
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">Código</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.codigo"
              placeholder="Código de dependencia"
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Nombre</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.nombre"
              placeholder="Nombre de la dependencia"
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Descripción</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.descripcion"
              placeholder="Descripción"
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Estado</label>
            <select class="municipal-form-control" v-model="filters.activo">
              <option value="">Todos</option>
              <option value="S">Activos</option>
              <option value="N">Inactivos</option>
            </select>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-12">
            <div class="municipal-group-btn">
              <button
                class="btn-municipal-primary me-2"
                @click="searchDependencias"
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
                class="btn-municipal-secondary"
                @click="loadDependencias"
                :disabled="loading"
              >
                <i class="fas fa-sync-alt me-1"></i>
                Actualizar
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
          Dependencias Registradas
          <span v-if="dependencias.length > 0" class="municipal-badge municipal-badge-primary ms-2">
            {{ dependencias.length }} registros
          </span>
        </h6>
      </div>
      <div class="municipal-card-body">
        <!-- Loading state -->
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2 text-muted">Cargando dependencias...</p>
        </div>

        <!-- Error state -->
        <div v-else-if="error" class="alert alert-danger">
          <h6 class="alert-heading">Error al cargar datos</h6>
          <p class="mb-0">{{ error }}</p>
          <hr>
          <button class="btn-municipal-secondary btn-sm" @click="loadDependencias">
            <i class="fas fa-retry me-1"></i>
            Reintentar
          </button>
        </div>

        <!-- Empty state -->
        <div v-else-if="dependencias.length === 0" class="text-center py-5">
          <i class="fas fa-building-columns fa-3x text-muted mb-3"></i>
          <h5 class="text-muted">No se encontraron dependencias</h5>
          <p class="text-muted">
            {{ hasActiveFilters ? 'No hay registros que coincidan con los filtros aplicados.' : 'No hay dependencias registradas en el sistema.' }}
          </p>
          <button
            v-if="!hasActiveFilters"
            class="btn-municipal-primary"
            @click="showCreateModal = true"
          >
            <i class="fas fa-plus me-1"></i>
            Registrar primera dependencia
          </button>
        </div>

        <!-- Tabla con datos -->
        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Código</th>
                <th>Nombre</th>
                <th>Abreviación</th>
                <th>Estado</th>
                <th>Licencias</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="dependencia in dependencias" :key="dependencia.id_dependencia">
                <td>
                  <strong class="text-primary">{{ dependencia.id_dependencia }}</strong>
                </td>
                <td>{{ dependencia.codigo }}</td>
                <td>{{ dependencia.nombre }}</td>
                <td>
                  <span class="municipal-badge municipal-badge-info">{{ dependencia.abrevia || 'N/A' }}</span>
                </td>
                <td>
                  <span class="municipal-badge" :class="dependencia.activo === 'S' ? 'municipal-badge-success' : 'municipal-badge-secondary'">
                    {{ dependencia.activo === 'S' ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
                <td>
                  <span class="municipal-badge" :class="dependencia.licencias === 1 ? 'municipal-badge-primary' : 'municipal-badge-warning'">
                    {{ dependencia.licencias === 1 ? 'Sí' : 'No' }}
                  </span>
                </td>
                <td>
                  <div class="municipal-group-btn btn-group-sm">
                    <button
                      class="btn-municipal-secondary btn-sm"
                      @click="viewDependencia(dependencia)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editDependencia(dependencia)"
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      class="btn-municipal-secondary btn-sm"
                      @click="deleteDependencia(dependencia)"
                      title="Eliminar"
                    >
                      <i class="fas fa-trash"></i>
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
          <nav aria-label="Paginación de dependencias">
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

    <!-- Modal para crear/editar dependencia -->
    <div class="modal fade" tabindex="-1" v-if="showCreateModal" style="display: block;" @click.self="showCreateModal = false">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-plus"></i>
              {{ editingDependencia ? 'Editar Dependencia' : 'Nueva Dependencia' }}
            </h5>
            <button type="button" class="btn-close" @click="showCreateModal = false"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveDependencia">
              <div class="row">
                <div class="col-md-6">
                  <label class="municipal-form-label">Código <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newDependencia.codigo"
                    placeholder="Código único"
                    required
                    maxlength="10"
                    :disabled="editingDependencia"
                  >
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Estado</label>
                  <select class="form-select" v-model="newDependencia.activo">
                    <option value="S">Activo</option>
                    <option value="N">Inactivo</option>
                  </select>
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="municipal-form-label">Nombre <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newDependencia.nombre"
                    placeholder="Nombre completo de la dependencia"
                    required
                    maxlength="200"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="municipal-form-label">Descripción</label>
                  <textarea
                    class="municipal-form-control"
                    rows="3"
                    v-model="newDependencia.descripcion"
                    placeholder="Descripción detallada de la dependencia"
                    maxlength="500"
                  ></textarea>
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="municipal-form-label">Responsable</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newDependencia.responsable"
                    placeholder="Nombre del responsable"
                    maxlength="100"
                  >
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Teléfono</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newDependencia.telefono"
                    placeholder="Número telefónico"
                    maxlength="20"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="municipal-form-label">Email</label>
                  <input
                    type="email"
                    class="municipal-form-control"
                    v-model="newDependencia.email"
                    placeholder="correo@gobierno.mx"
                    maxlength="100"
                  >
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Extensión</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newDependencia.extension"
                    placeholder="Ext. telefónica"
                    maxlength="10"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="municipal-form-label">Dirección</label>
                  <textarea
                    class="municipal-form-control"
                    rows="2"
                    v-model="newDependencia.direccion"
                    placeholder="Dirección física de la dependencia"
                    maxlength="300"
                  ></textarea>
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="municipal-form-label">Observaciones</label>
                  <textarea
                    class="municipal-form-control"
                    rows="2"
                    v-model="newDependencia.observaciones"
                    placeholder="Observaciones adicionales"
                    maxlength="500"
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
              @click="saveDependencia"
              :disabled="creating || !newDependencia.codigo || !newDependencia.nombre"
            >
              <span v-if="creating">
                <i class="fas fa-spinner fa-spin me-1"></i>
                {{ editingDependencia ? 'Actualizando...' : 'Creando...' }}
              </span>
              <span v-else>
                <i class="fas fa-save me-1"></i>
                {{ editingDependencia ? 'Actualizar Dependencia' : 'Crear Dependencia' }}
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showCreateModal" class="modal-backdrop fade show"></div>

    <!-- Modal de detalles de la dependencia -->
    <div v-if="showDetailsModal" class="modal-overlay" @click.self="showDetailsModal = false">
      <div class="modal-content" style="max-width: 800px;">
        <div class="modal-header">
          <h2>
            <i class="fas fa-building-columns"></i>
            Detalles de la Dependencia
          </h2>
          <button class="close-btn" @click="showDetailsModal = false">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body" v-if="selectedDependencia">
          <div class="row">
            <div class="col-12 mb-4">
              <div class="alert alert-info">
                <h5 class="alert-heading mb-2">
                  <i class="fas fa-info-circle"></i>
                  {{ selectedDependencia.codigo }} - {{ selectedDependencia.nombre }}
                </h5>
                <p class="mb-0">{{ selectedDependencia.descripcion || 'Sin descripción disponible' }}</p>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-md-6">
              <div class="card h-100">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-info"></i>
                    Información General
                  </h6>
                </div>
                <div class="card-body">
                  <div class="form-group mb-3">
                    <label class="municipal-form-label">Código:</label>
                    <p class="form-control-plaintext">{{ selectedDependencia.codigo }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="municipal-form-label">Abreviación:</label>
                    <p class="form-control-plaintext">{{ selectedDependencia.abrevia || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="municipal-form-label">Estado:</label>
                    <span class="municipal-badge" :class="selectedDependencia.activo === 'S' ? 'municipal-badge-success' : 'municipal-badge-secondary'">
                      {{ selectedDependencia.activo === 'S' ? 'Activo' : 'Inactivo' }}
                    </span>
                  </div>
                  <div class="form-group mb-0">
                    <label class="municipal-form-label">Maneja Licencias:</label>
                    <span class="municipal-badge" :class="selectedDependencia.licencias === 1 ? 'municipal-badge-primary' : 'municipal-badge-warning'">
                      {{ selectedDependencia.licencias === 1 ? 'Sí' : 'No' }}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-md-6">
              <div class="card h-100">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-address-book"></i>
                    Contacto
                  </h6>
                </div>
                <div class="card-body">
                  <div class="form-group mb-3">
                    <label class="municipal-form-label">Responsable:</label>
                    <p class="form-control-plaintext">{{ selectedDependencia.responsable || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="municipal-form-label">Teléfono:</label>
                    <p class="form-control-plaintext">{{ selectedDependencia.telefono || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-3">
                    <label class="municipal-form-label">Email:</label>
                    <p class="form-control-plaintext">{{ selectedDependencia.email || 'N/A' }}</p>
                  </div>
                  <div class="form-group mb-0">
                    <label class="municipal-form-label">Extensión:</label>
                    <p class="form-control-plaintext">{{ selectedDependencia.extension || 'N/A' }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="row mt-4" v-if="selectedDependencia.direccion">
            <div class="col-12">
              <div class="card">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-map-marker-alt"></i>
                    Dirección
                  </h6>
                </div>
                <div class="card-body">
                  <p class="mb-0">{{ selectedDependencia.direccion }}</p>
                </div>
              </div>
            </div>
          </div>

          <div class="row mt-4" v-if="selectedDependencia.observaciones">
            <div class="col-12">
              <div class="card">
                <div class="card-header">
                  <h6 class="mb-0">
                    <i class="fas fa-comment"></i>
                    Observaciones
                  </h6>
                </div>
                <div class="card-body">
                  <p class="mb-0">{{ selectedDependencia.observaciones }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-primary" @click="editDependencia(selectedDependencia)">
            <i class="fas fa-edit me-1"></i>
            Editar Dependencia
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
  name: 'DependenciasForm',
  data() {
    return {
      // Estado de carga
      loading: false,
      creating: false,
      error: null,

      // Datos
      dependencias: [],
      totalRegistros: 0,

      // Paginación
      currentPage: 1,
      itemsPerPage: 10,
      totalPages: 0,

      // Filtros
      filters: {
        codigo: '',
        nombre: '',
        descripcion: '',
        activo: ''
      },

      // Modal
      showCreateModal: false,
      editingDependencia: null,

      // Modales
      showDetailsModal: false,
      selectedDependencia: null,

      // SweetAlert
      sweetAlert: {
        show: false,
        type: 'info',
        title: '',
        text: ''
      },

      // Toast notifications
      toasts: [],

      // Nueva dependencia
      newDependencia: {
        codigo: '',
        nombre: '',
        descripcion: '',
        responsable: '',
        telefono: '',
        email: '',
        extension: '',
        direccion: '',
        observaciones: '',
        activo: 'S'
      }
    }
  },

  computed: {
    hasActiveFilters() {
      return Object.values(this.filters).some(value => value !== null && value !== '')
    }
  },

  mounted() {
    console.log('DependenciasForm component mounted')
    this.loadDependencias()
  },
  methods: {
    async loadDependencias() {
      this.loading = true
      this.error = null

      try {
        // Llamada real a la API usando SP_DEPENDENCIAS_LIST
        const eRequest = {
          Operacion: 'sp_dependencias_list',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_codigo', valor: this.filters.codigo || null },
            { nombre: 'p_nombre', valor: this.filters.nombre || null },
            { nombre: 'p_descripcion', valor: this.filters.descripcion || null },
            { nombre: 'p_activo', valor: this.filters.activo || null },
            { nombre: 'p_limite', valor: this.itemsPerPage },
            { nombre: 'p_offset', valor: (this.currentPage - 1) * this.itemsPerPage }
          ],
          Tenant: 'informix'
        }

        console.log('📨 Cargando dependencias con SP_DEPENDENCIAS_LIST:', eRequest)

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
          this.dependencias = data.eResponse.data.result || []

          // Obtener el total de registros del primer elemento (si existe)
          if (this.dependencias.length > 0) {
            this.totalRegistros = parseInt(this.dependencias[0].total_registros) || 0
            this.totalPages = Math.ceil(this.totalRegistros / this.itemsPerPage)
          } else {
            this.totalRegistros = 0
            this.totalPages = 0
          }

          console.log(`✅ Cargadas ${this.dependencias.length} dependencias de ${this.totalRegistros} totales (Página ${this.currentPage}/${this.totalPages})`)
        } else {
          throw new Error(data.eResponse.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.error = 'Error al cargar las dependencias: ' + error.message
        console.error('❌ Error loading dependencias:', error)
      } finally {
        this.loading = false
      }
    },

    async searchDependencias() {
      console.log('🔍 Buscando dependencias con filtros:', this.filters)
      this.currentPage = 1 // Reset to first page when searching
      this.loadDependencias()
    },

    clearFilters() {
      this.filters = {
        codigo: '',
        nombre: '',
        descripcion: '',
        activo: ''
      }
      this.currentPage = 1 // Reset to first page
      this.loadDependencias()
    },

    async saveDependencia() {
      if (!this.newDependencia.codigo || !this.newDependencia.nombre) {
        this.showSweetAlert('warning', 'Campos Requeridos', 'Por favor complete los campos requeridos (Código y Nombre)')
        return
      }

      this.creating = true

      try {
        let eRequest

        if (this.editingDependencia) {
          // Actualizar dependencia existente
          eRequest = {
            Operacion: 'SP_DEPENDENCIAS_UPDATE',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_id', valor: this.editingDependencia.id_dependencia },
              { nombre: 'p_codigo', valor: this.newDependencia.codigo },
              { nombre: 'p_nombre', valor: this.newDependencia.nombre },
              { nombre: 'p_descripcion', valor: this.newDependencia.descripcion || null },
              { nombre: 'p_responsable', valor: this.newDependencia.responsable || null },
              { nombre: 'p_telefono', valor: this.newDependencia.telefono || null },
              { nombre: 'p_email', valor: this.newDependencia.email || null },
              { nombre: 'p_extension', valor: this.newDependencia.extension || null },
              { nombre: 'p_direccion', valor: this.newDependencia.direccion || null },
              { nombre: 'p_observaciones', valor: this.newDependencia.observaciones || null },
              { nombre: 'p_activo', valor: this.newDependencia.activo }
            ],
            Tenant: 'informix'
          }
        } else {
          // Crear nueva dependencia
          eRequest = {
            Operacion: 'SP_DEPENDENCIAS_CREATE',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_codigo', valor: this.newDependencia.codigo },
              { nombre: 'p_nombre', valor: this.newDependencia.nombre },
              { nombre: 'p_descripcion', valor: this.newDependencia.descripcion || null },
              { nombre: 'p_responsable', valor: this.newDependencia.responsable || null },
              { nombre: 'p_telefono', valor: this.newDependencia.telefono || null },
              { nombre: 'p_email', valor: this.newDependencia.email || null },
              { nombre: 'p_extension', valor: this.newDependencia.extension || null },
              { nombre: 'p_direccion', valor: this.newDependencia.direccion || null },
              { nombre: 'p_observaciones', valor: this.newDependencia.observaciones || null },
              { nombre: 'p_activo', valor: this.newDependencia.activo }
            ],
            Tenant: 'informix'
          }
        }

        console.log(`📨 ${this.editingDependencia ? 'Actualizando' : 'Creando'} dependencia:`, eRequest)

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
              this.editingDependencia ? 'Dependencia Actualizada' : 'Dependencia Creada',
              result.message || (this.editingDependencia ? 'Dependencia actualizada exitosamente' : 'Dependencia creada exitosamente')
            )
            this.resetCreateForm()
            this.showCreateModal = false
            this.loadDependencias()
          } else {
            this.showSweetAlert('error', 'Error', result.message || 'Error en la operación')
            return
          }
        } else {
          throw new Error(data.eResponse.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Guardar', 'Error al guardar la dependencia: ' + error.message)
        console.error('❌ Error saving dependencia:', error)
      } finally {
        this.creating = false
      }
    },

    editDependencia(dependencia) {
      this.editingDependencia = dependencia
      this.newDependencia = {
        codigo: dependencia.codigo,
        nombre: dependencia.nombre,
        descripcion: dependencia.descripcion || '',
        responsable: dependencia.responsable || '',
        telefono: dependencia.telefono || '',
        email: dependencia.email || '',
        extension: dependencia.extension || '',
        direccion: dependencia.direccion || '',
        observaciones: dependencia.observaciones || '',
        activo: dependencia.activo
      }
      this.showCreateModal = true
      this.showDetailsModal = false
    },

    deleteDependencia(dependencia) {
      if (confirm(`¿Está seguro que desea eliminar la dependencia "${dependencia.nombre}"?`)) {
        this.confirmDeleteDependencia(dependencia)
      }
    },

    async confirmDeleteDependencia(dependencia) {
      try {
        const eRequest = {
          Operacion: 'SP_DEPENDENCIAS_DELETE',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_id', valor: dependencia.id_dependencia }
          ],
          Tenant: 'informix'
        }

        console.log('📨 Eliminando dependencia:', eRequest)

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
            this.showSweetAlert('success', 'Dependencia Eliminada', result.message || 'Dependencia eliminada exitosamente')
            this.loadDependencias()
          } else {
            this.showSweetAlert('error', 'Error', result.message || 'Error al eliminar la dependencia')
          }
        } else {
          throw new Error(data.eResponse.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Eliminar', 'Error al eliminar la dependencia: ' + error.message)
        console.error('❌ Error deleting dependencia:', error)
      }
    },

    resetCreateForm() {
      this.editingDependencia = null
      this.newDependencia = {
        codigo: '',
        nombre: '',
        descripcion: '',
        responsable: '',
        telefono: '',
        email: '',
        extension: '',
        direccion: '',
        observaciones: '',
        activo: 'S'
      }
    },

    viewDependencia(dependencia) {
      console.log('View dependencia:', dependencia)
      this.showDependenciaDetailsModal(dependencia)
    },

    // Métodos de paginación
    goToPage(page) {
      if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
        this.currentPage = page
        this.loadDependencias()
      }
    },

    previousPage() {
      if (this.currentPage > 1) {
        this.currentPage--
        this.loadDependencias()
      }
    },

    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++
        this.loadDependencias()
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

    // Ver detalles de la dependencia en modal
    showDependenciaDetailsModal(dependencia) {
      this.selectedDependencia = dependencia
      this.showDetailsModal = true
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
  }
}
</script>
