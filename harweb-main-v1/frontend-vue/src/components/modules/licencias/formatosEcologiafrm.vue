<template>
  <div class="container-fluid p-0 h-100">
    <!-- Municipal Header -->
    <div class="municipal-header p-3 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1">
            <i class="fas fa-leaf me-2 text-success"></i>
            Formatos de Ecología Municipal
          </h1>
          <p class="mb-0 opacity-75">Gestión integral de formatos y documentación ecológica para licencias ambientales</p>
        </div>
        <div class="text-white-50">
          <ol class="breadcrumb mb-0 bg-transparent p-0">
            <li class="breadcrumb-item"><router-link to="/" class="text-white-50">Inicio</router-link></li>
            <li class="breadcrumb-item"><router-link to="/licencias" class="text-white-50">Licencias</router-link></li>
            <li class="breadcrumb-item text-white active">Formatos Ecología</li>
          </ol>
        </div>
      </div>
    </div>

    <!-- Controls Section -->
    <div class="municipal-controls border-bottom p-3">
      <div class="d-flex justify-content-between align-items-center">
        <div class="btn-group" role="group">
          <button type="button" class="btn btn-municipal-white" @click="refreshData" :disabled="state.loading">
            <i class="fas fa-sync-alt" :class="{ 'fa-spin': state.loading }"></i>
          </button>
          <button type="button" class="btn btn-municipal-white" @click="clearFilters">
            <i class="fas fa-eraser"></i>
          </button>
          <button type="button" class="btn btn-municipal-white" @click="exportData">
            <i class="fas fa-file-export"></i>
          </button>
        </div>
        <div class="d-flex gap-2">
          <button type="button" class="btn btn-municipal-success" @click="openCreateModal">
            <i class="fas fa-plus me-1"></i>Nuevo Formato
          </button>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="p-4">
      <!-- Search and Filters Card -->
      <div class="card mb-4 shadow-sm">
        <div class="card-header bg-primary text-white">
          <h5 class="mb-0">
            <i class="fas fa-filter me-2"></i>
            Filtros de Búsqueda de Formatos Ecológicos
          </h5>
        </div>
        <div class="card-body">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label fw-bold">Nombre del Formato</label>
              <input
                v-model="state.filters.nombre"
                type="text"
                class="form-control"
                placeholder="Buscar por nombre..."
                @input="debouncedSearch"
                @keyup.enter="searchFormatos"
                maxlength="255"
              >
            </div>
            <div class="col-md-3">
              <label class="form-label fw-bold">Tipo de Formato</label>
              <select v-model="state.filters.tipo" class="form-select" @change="debouncedSearch">
                <option value="">Todos los tipos</option>
                <option value="IMPACTO_AMBIENTAL">Impacto Ambiental</option>
                <option value="RESIDUOS">Gestión de Residuos</option>
                <option value="EMISIONES">Control de Emisiones</option>
                <option value="AGUA">Uso de Agua</option>
                <option value="RUIDO">Control de Ruido</option>
                <option value="CERTIFICACION">Certificación Ambiental</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label fw-bold">Estado</label>
              <select v-model="state.filters.activo" class="form-select" @change="debouncedSearch">
                <option value="">Todos los estados</option>
                <option value="S">Activos</option>
                <option value="N">Inactivos</option>
              </select>
            </div>
            <div class="col-md-2">
              <label class="form-label fw-bold">&nbsp;</label>
              <div class="d-grid gap-2">
                <button
                  type="button"
                  class="btn btn-primary"
                  @click="searchFormatos"
                  :disabled="state.loading"
                >
                  <i class="fas fa-search"></i> Buscar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Results Table -->
      <div class="card shadow-sm">
        <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
          <h5 class="mb-0">
            <i class="fas fa-table me-2"></i>
            Formatos Ecológicos Registrados
          </h5>
          <div class="text-end">
            <small class="d-block">{{ state.pagination.totalRecords }} registros encontrados</small>
            <small class="d-block">Página {{ state.pagination.currentPage }} de {{ state.pagination.totalPages }}</small>
          </div>
        </div>

        <div class="card-body p-0">
          <!-- Loading State -->
          <div v-if="state.loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="mt-3 text-muted">Cargando formatos ecológicos...</p>
          </div>

          <!-- Error State -->
          <div v-else-if="state.error" class="alert alert-danger m-3" role="alert">
            <i class="fas fa-exclamation-triangle me-2"></i>
            {{ state.error }}
          </div>

          <!-- Results Table -->
          <div v-else class="table-responsive">
            <table class="table table-hover mb-0">
              <thead class="table-dark">
                <tr>
                  <th class="text-center" style="width: 80px;">ID</th>
                  <th style="min-width: 200px;">Formato</th>
                  <th style="width: 180px;">Tipo</th>
                  <th style="min-width: 250px;">Descripción</th>
                  <th style="width: 120px;">Vigencia</th>
                  <th style="width: 100px;">Estado</th>
                  <th style="width: 130px;">Fecha Registro</th>
                  <th style="width: 200px;" class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="formato in state.resultados" :key="formato.id" class="align-middle">
                  <td class="text-center">
                    <span class="badge bg-primary">{{ formato.id }}</span>
                  </td>
                  <td>
                    <div>
                      <strong class="text-dark">{{ formato.nombre }}</strong>
                      <br>
                      <small class="text-muted" v-if="formato.codigo">
                        <i class="fas fa-barcode me-1"></i>{{ formato.codigo }}
                      </small>
                    </div>
                  </td>
                  <td>
                    <span class="badge" :class="getTipoBadgeClass(formato.tipo)">
                      {{ formatTipo(formato.tipo) }}
                    </span>
                    <div v-if="formato.es_obligatorio === 'S'" class="mt-1">
                      <small class="badge bg-warning text-dark">
                        <i class="fas fa-exclamation-circle me-1"></i>Obligatorio
                      </small>
                    </div>
                  </td>
                  <td>
                    <div class="text-truncate" style="max-width: 250px;" :title="formato.descripcion">
                      {{ formato.descripcion || 'Sin descripción' }}
                    </div>
                  </td>
                  <td class="text-center">
                    <span class="badge bg-info text-dark">
                      {{ formato.vigencia_meses }} meses
                    </span>
                  </td>
                  <td class="text-center">
                    <span class="badge" :class="formato.activo === 'S' ? 'bg-success' : 'bg-danger'">
                      {{ formato.activo === 'S' ? 'Activo' : 'Inactivo' }}
                    </span>
                  </td>
                  <td class="text-center">
                    <small class="text-muted">{{ formatDate(formato.fecha_creacion) }}</small>
                  </td>
                  <td>
                    <div class="btn-group btn-group-sm" role="group">
                      <button
                        type="button"
                        class="btn btn-outline-info"
                        @click="viewDetail(formato)"
                        :title="`Ver detalle de ${formato.nombre}`"
                      >
                        <i class="fas fa-eye"></i>
                      </button>
                      <button
                        type="button"
                        class="btn btn-outline-warning"
                        @click="editFormato(formato)"
                        :title="`Editar ${formato.nombre}`"
                      >
                        <i class="fas fa-edit"></i>
                      </button>
                      <button
                        type="button"
                        :class="formato.activo === 'S' ? 'btn btn-outline-danger' : 'btn btn-outline-success'"
                        @click="toggleStatus(formato)"
                        :title="formato.activo === 'S' ? 'Desactivar formato' : 'Activar formato'"
                        :disabled="state.loading"
                      >
                        <i :class="formato.activo === 'S' ? 'fas fa-ban' : 'fas fa-check'"></i>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>

            <!-- Empty State -->
            <div v-if="state.resultados.length === 0" class="text-center py-5">
              <div class="text-muted">
                <i class="fas fa-search fa-3x mb-3 opacity-50"></i>
                <h5>No se encontraron formatos ecológicos</h5>
                <p>No hay formatos que coincidan con los criterios de búsqueda.</p>
                <button type="button" class="btn btn-primary" @click="openCreateModal">
                  <i class="fas fa-plus me-1"></i>Crear Primer Formato
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Pagination Footer -->
        <div v-if="state.pagination.totalPages > 1" class="card-footer">
          <nav aria-label="Paginación de formatos">
            <ul class="pagination pagination-sm justify-content-center mb-0">
              <li class="page-item" :class="{ disabled: state.pagination.currentPage === 1 }">
                <button class="page-link" @click="goToPage(1)" :disabled="state.pagination.currentPage === 1">
                  <i class="fas fa-angle-double-left"></i> Primera
                </button>
              </li>
              <li class="page-item" :class="{ disabled: state.pagination.currentPage === 1 }">
                <button class="page-link" @click="goToPage(state.pagination.currentPage - 1)" :disabled="state.pagination.currentPage === 1">
                  <i class="fas fa-angle-left"></i> Anterior
                </button>
              </li>
              <li class="page-item active">
                <span class="page-link">
                  {{ state.pagination.currentPage }} de {{ state.pagination.totalPages }}
                </span>
              </li>
              <li class="page-item" :class="{ disabled: state.pagination.currentPage === state.pagination.totalPages }">
                <button class="page-link" @click="goToPage(state.pagination.currentPage + 1)" :disabled="state.pagination.currentPage === state.pagination.totalPages">
                  Siguiente <i class="fas fa-angle-right"></i>
                </button>
              </li>
              <li class="page-item" :class="{ disabled: state.pagination.currentPage === state.pagination.totalPages }">
                <button class="page-link" @click="goToPage(state.pagination.totalPages)" :disabled="state.pagination.currentPage === state.pagination.totalPages">
                  Última <i class="fas fa-angle-double-right"></i>
                </button>
              </li>
            </ul>
          </nav>
        </div>
      </div>
    </div>

    <!-- Detail Modal -->
    <div v-if="state.showDetailModal" class="modal fade show d-block" tabindex="-1" style="background-color: rgba(0,0,0,0.5);">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header bg-success text-white">
            <h5 class="modal-title">
              <i class="fas fa-leaf me-2"></i>
              Detalle del Formato Ecológico
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="closeDetailModal"></button>
          </div>
          <div class="modal-body" v-if="state.selectedFormato">
            <div class="row">
              <div class="col-md-6">
                <div class="mb-3">
                  <label class="form-label fw-bold text-muted">Código</label>
                  <p class="form-control-plaintext">{{ state.selectedFormato.codigo || 'No asignado' }}</p>
                </div>
                <div class="mb-3">
                  <label class="form-label fw-bold text-muted">Nombre</label>
                  <p class="form-control-plaintext">{{ state.selectedFormato.nombre }}</p>
                </div>
                <div class="mb-3">
                  <label class="form-label fw-bold text-muted">Tipo</label>
                  <p class="form-control-plaintext">
                    <span class="badge" :class="getTipoBadgeClass(state.selectedFormato.tipo)">
                      {{ formatTipo(state.selectedFormato.tipo) }}
                    </span>
                  </p>
                </div>
                <div class="mb-3">
                  <label class="form-label fw-bold text-muted">Vigencia</label>
                  <p class="form-control-plaintext">
                    <span class="badge bg-info text-dark">
                      {{ state.selectedFormato.vigencia_meses }} meses
                    </span>
                  </p>
                </div>
              </div>
              <div class="col-md-6">
                <div class="mb-3">
                  <label class="form-label fw-bold text-muted">¿Es Obligatorio?</label>
                  <p class="form-control-plaintext">
                    <span class="badge" :class="state.selectedFormato.es_obligatorio === 'S' ? 'bg-warning text-dark' : 'bg-secondary'">
                      {{ state.selectedFormato.es_obligatorio === 'S' ? 'Sí' : 'No' }}
                    </span>
                  </p>
                </div>
                <div class="mb-3">
                  <label class="form-label fw-bold text-muted">Estado</label>
                  <p class="form-control-plaintext">
                    <span class="badge" :class="state.selectedFormato.activo === 'S' ? 'bg-success' : 'bg-danger'">
                      {{ state.selectedFormato.activo === 'S' ? 'Activo' : 'Inactivo' }}
                    </span>
                  </p>
                </div>
                <div class="mb-3">
                  <label class="form-label fw-bold text-muted">Fecha de Registro</label>
                  <p class="form-control-plaintext">{{ formatDateTime(state.selectedFormato.fecha_creacion) }}</p>
                </div>
                <div class="mb-3">
                  <label class="form-label fw-bold text-muted">Última Actualización</label>
                  <p class="form-control-plaintext">{{ formatDateTime(state.selectedFormato.fecha_actualizacion) }}</p>
                </div>
              </div>
            </div>
            <div v-if="state.selectedFormato.descripcion" class="mb-3">
              <label class="form-label fw-bold text-muted">Descripción</label>
              <div class="alert alert-info">
                {{ state.selectedFormato.descripcion }}
              </div>
            </div>
            <div v-if="state.selectedFormato.observaciones" class="mb-3">
              <label class="form-label fw-bold text-muted">Observaciones</label>
              <div class="alert alert-warning">
                {{ state.selectedFormato.observaciones }}
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeDetailModal">
              <i class="fas fa-times me-1"></i>Cerrar
            </button>
            <button type="button" class="btn btn-primary" @click="editFromDetail">
              <i class="fas fa-edit me-1"></i>Editar Formato
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <div v-if="state.showFormModal" class="modal fade show d-block" tabindex="-1" style="background-color: rgba(0,0,0,0.5);">
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header" :class="state.isEditing ? 'bg-warning' : 'bg-success'" class="text-white">
            <h5 class="modal-title text-white">
              <i :class="state.isEditing ? 'fas fa-edit' : 'fas fa-plus'" class="me-2"></i>
              {{ state.isEditing ? 'Editar' : 'Nuevo' }} Formato Ecológico
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="closeFormModal"></button>
          </div>
          <form @submit.prevent="saveFormato">
            <div class="modal-body">
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-bold">Nombre del Formato <span class="text-danger">*</span></label>
                  <input
                    v-model="state.form.nombre"
                    type="text"
                    class="form-control"
                    :class="{ 'is-invalid': state.formErrors.nombre }"
                    placeholder="Ingrese el nombre del formato"
                    required
                    maxlength="255"
                  >
                  <div v-if="state.formErrors.nombre" class="invalid-feedback">
                    {{ state.formErrors.nombre }}
                  </div>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-bold">Código (Opcional)</label>
                  <input
                    v-model="state.form.codigo"
                    type="text"
                    class="form-control"
                    :class="{ 'is-invalid': state.formErrors.codigo }"
                    placeholder="Se genera automáticamente si se deja vacío"
                    maxlength="50"
                  >
                  <div v-if="state.formErrors.codigo" class="invalid-feedback">
                    {{ state.formErrors.codigo }}
                  </div>
                </div>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-bold">Tipo de Formato</label>
                  <select v-model="state.form.tipo" class="form-select" :class="{ 'is-invalid': state.formErrors.tipo }">
                    <option value="">Seleccionar tipo...</option>
                    <option value="IMPACTO_AMBIENTAL">Evaluación de Impacto Ambiental</option>
                    <option value="RESIDUOS">Gestión y Manejo de Residuos</option>
                    <option value="EMISIONES">Control de Emisiones a la Atmósfera</option>
                    <option value="AGUA">Uso y Aprovechamiento de Agua</option>
                    <option value="RUIDO">Control de Ruido y Contaminación Acústica</option>
                    <option value="CERTIFICACION">Certificaciones Ambientales</option>
                  </select>
                  <div v-if="state.formErrors.tipo" class="invalid-feedback">
                    {{ state.formErrors.tipo }}
                  </div>
                </div>
                <div class="col-md-6 mb-3">
                  <label class="form-label fw-bold">Vigencia (meses)</label>
                  <input
                    v-model.number="state.form.vigencia_meses"
                    type="number"
                    class="form-control"
                    :class="{ 'is-invalid': state.formErrors.vigencia_meses }"
                    min="1"
                    max="120"
                    placeholder="12"
                  >
                  <div class="form-text">Entre 1 y 120 meses</div>
                  <div v-if="state.formErrors.vigencia_meses" class="invalid-feedback">
                    {{ state.formErrors.vigencia_meses }}
                  </div>
                </div>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Descripción</label>
                <textarea
                  v-model="state.form.descripcion"
                  class="form-control"
                  :class="{ 'is-invalid': state.formErrors.descripcion }"
                  rows="3"
                  placeholder="Descripción detallada del formato ecológico..."
                  maxlength="1000"
                ></textarea>
                <div v-if="state.formErrors.descripcion" class="invalid-feedback">
                  {{ state.formErrors.descripcion }}
                </div>
              </div>
              <div class="mb-3">
                <label class="form-label fw-bold">Observaciones</label>
                <textarea
                  v-model="state.form.observaciones"
                  class="form-control"
                  rows="2"
                  placeholder="Observaciones adicionales..."
                  maxlength="500"
                ></textarea>
              </div>
              <div class="row">
                <div class="col-md-6 mb-3">
                  <div class="form-check form-switch">
                    <input
                      v-model="state.form.es_obligatorio"
                      class="form-check-input"
                      type="checkbox"
                      id="es_obligatorio"
                    >
                    <label class="form-check-label fw-bold" for="es_obligatorio">
                      <i class="fas fa-exclamation-triangle text-warning me-1"></i>
                      Es formato obligatorio
                    </label>
                  </div>
                </div>
                <div class="col-md-6 mb-3">
                  <div class="form-check form-switch">
                    <input
                      v-model="state.form.activo"
                      class="form-check-input"
                      type="checkbox"
                      id="activo"
                    >
                    <label class="form-check-label fw-bold" for="activo">
                      <i class="fas fa-toggle-on text-success me-1"></i>
                      Estado activo
                    </label>
                  </div>
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" @click="closeFormModal" :disabled="state.loading">
                <i class="fas fa-times me-1"></i>Cancelar
              </button>
              <button type="submit" class="btn" :class="state.isEditing ? 'btn-warning' : 'btn-success'" :disabled="state.loading">
                <i class="fas fa-spinner fa-spin me-1" v-if="state.loading"></i>
                <i :class="state.isEditing ? 'fas fa-save' : 'fas fa-plus'" class="me-1" v-else></i>
                {{ state.isEditing ? 'Actualizar' : 'Crear' }} Formato
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { reactive, onMounted } from 'vue'

/**
 * Simple debounce implementation to avoid external dependencies
 * @param {Function} func - Function to debounce
 * @param {number} wait - Wait time in milliseconds
 * @returns {Function} Debounced function
 */
const debounce = (func, wait) => {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout)
      func(...args)
    }
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}

/**
 * Componente de Gestión de Formatos Ecológicos
 *
 * Sistema Municipal de Guadalajara - Módulo de Licencias
 * Gestión integral de formatos y documentación ecológica para licencias ambientales
 *
 * Características:
 * - CRUD completo con validaciones
 * - Búsqueda avanzada con filtros
 * - Paginación server-side
 * - Modales para detalle y edición
 * - Diseño responsive con Bootstrap 5
 * - Vue 3 Composition API + eRequest/eResponse pattern
 *
 * @author Sistema Municipal Guadalajara
 * @version 1.0.0
 */
export default {
  name: 'FormatosEcologiafrm',
  setup() {

    // Reactive state
    const state = reactive({
      // Main data
      resultados: [],
      loading: false,
      error: null,

      // Modals
      showDetailModal: false,
      showFormModal: false,
      selectedFormato: null,
      isEditing: false,

      // Filters
      filters: {
        nombre: '',
        tipo: '',
        activo: ''
      },

      // Pagination
      pagination: {
        currentPage: 1,
        itemsPerPage: 20,
        totalPages: 0,
        totalRecords: 0
      },

      // Form
      form: {
        id: null,
        nombre: '',
        codigo: '',
        tipo: '',
        descripcion: '',
        observaciones: '',
        vigencia_meses: 12,
        es_obligatorio: false,
        activo: true
      },

      // Form validation
      formErrors: {}
    })

    // API Methods using eRequest/eResponse pattern
    const searchFormatos = async () => {
      state.loading = true
      state.error = null

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
            Operacion: 'sp_formatosecologia_list',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_nombre', valor: state.filters.nombre || null },
              { nombre: 'p_tipo', valor: state.filters.tipo || null },
              { nombre: 'p_activo', valor: state.filters.activo || null },
              { nombre: 'p_limite', valor: state.pagination.itemsPerPage },
              { nombre: 'p_offset', valor: (state.pagination.currentPage - 1) * state.pagination.itemsPerPage }
            ],
            Tenant: 'public'
          }
          })
        })

        const data = await response.json()

        if (data.eResponse.success) {
          const data = data.eResponse.data.result || []
          state.resultados = data

          // Update pagination info
          if (data.length > 0) {
            state.pagination.totalRecords = parseInt(data[0].total_registros) || 0
            state.pagination.totalPages = Math.ceil(state.pagination.totalRecords / state.pagination.itemsPerPage)
          } else {
            state.pagination.totalRecords = 0
            state.pagination.totalPages = 0
          }
        } else {
          state.error = response.data.eResponse.message || 'Error al cargar formatos ecológicos'
          state.resultados = []
        }
      } catch (error) {
        console.error('Error loading formatos:', error)
        state.error = 'Error de conexión con el servidor'
        state.resultados = []
      } finally {
        state.loading = false
      }
    }

    // Debounced search
    const debouncedSearch = debounce(() => {
      state.pagination.currentPage = 1
      searchFormatos()
    }, 500)

    const refreshData = () => {
      searchFormatos()
    }

    const clearFilters = () => {
      state.filters = {
        nombre: '',
        tipo: '',
        activo: ''
      }
      state.pagination.currentPage = 1
      searchFormatos()
    }

    const goToPage = (page) => {
      if (page >= 1 && page <= state.pagination.totalPages) {
        state.pagination.currentPage = page
        searchFormatos()
      }
    }

    const exportData = () => {
      // TODO: Implement export functionality
      console.log('Export functionality to be implemented')
    }

    // Modal Methods
    const viewDetail = async (formato) => {
      state.loading = true

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
            Operacion: 'sp_formatosecologia_get',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_id', valor: formato.id }
            ],
            Tenant: 'public'
          }
        })

        if (response.data.eResponse.success && data.eResponse.data.result.length > 0) {
          state.selectedFormato = data.eResponse.data.result[0]
          state.showDetailModal = true
        } else {
          state.error = 'No se pudo cargar el detalle del formato'
        }
      } catch (error) {
        console.error('Error loading detail:', error)
        state.error = 'Error al cargar detalle del formato'
      } finally {
        state.loading = false
      }
    }

    const closeDetailModal = () => {
      state.showDetailModal = false
      state.selectedFormato = null
    }

    const editFromDetail = () => {
      if (state.selectedFormato) {
        editFormato(state.selectedFormato)
        closeDetailModal()
      }
    }

    // Form Methods
    const openCreateModal = () => {
      resetForm()
      state.isEditing = false
      state.showFormModal = true
    }

    const editFormato = (formato) => {
      state.form = {
        id: formato.id,
        nombre: formato.nombre || '',
        codigo: formato.codigo || '',
        tipo: formato.tipo || '',
        descripcion: formato.descripcion || '',
        observaciones: formato.observaciones || '',
        vigencia_meses: formato.vigencia_meses || 12,
        es_obligatorio: formato.es_obligatorio === 'S',
        activo: formato.activo === 'S'
      }
      state.isEditing = true
      state.showFormModal = true
      state.formErrors = {}
    }

    const closeFormModal = () => {
      state.showFormModal = false
      resetForm()
      state.formErrors = {}
    }

    const resetForm = () => {
      state.form = {
        id: null,
        nombre: '',
        codigo: '',
        tipo: '',
        descripcion: '',
        observaciones: '',
        vigencia_meses: 12,
        es_obligatorio: false,
        activo: true
      }
    }

    const validateForm = () => {
      state.formErrors = {}
      let isValid = true

      if (!state.form.nombre?.trim()) {
        state.formErrors.nombre = 'El nombre es obligatorio'
        isValid = false
      }

      if (state.form.vigencia_meses < 1 || state.form.vigencia_meses > 120) {
        state.formErrors.vigencia_meses = 'La vigencia debe estar entre 1 y 120 meses'
        isValid = false
      }

      return isValid
    }

    const saveFormato = async () => {
      if (!validateForm()) {
        return
      }

      state.loading = true

      try {
        const operacion = state.isEditing ? 'sp_formatosecologia_update' : 'sp_formatosecologia_create'
        const parametros = [
          { nombre: 'p_nombre', valor: state.form.nombre },
          { nombre: 'p_codigo', valor: state.form.codigo || null },
          { nombre: 'p_tipo', valor: state.form.tipo || null },
          { nombre: 'p_descripcion', valor: state.form.descripcion || null },
          { nombre: 'p_observaciones', valor: state.form.observaciones || null },
          { nombre: 'p_vigencia_meses', valor: state.form.vigencia_meses || 12 },
          { nombre: 'p_es_obligatorio', valor: state.form.es_obligatorio ? 'S' : 'N' },
          { nombre: 'p_activo', valor: state.form.activo ? 'S' : 'N' }
        ]

        if (state.isEditing) {
          parametros.unshift({ nombre: 'p_id', valor: state.form.id })
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
            Operacion: operacion,
            Base: 'padron_licencias',
            Parametros: parametros,
            Tenant: 'public'
          }
          })
        })

        const data = await response.json()

        if (data.eResponse.success) {
          // Show success message
          showSuccessNotification(
            state.isEditing
              ? 'Formato ecológico actualizado exitosamente'
              : 'Formato ecológico creado exitosamente'
          )

          closeFormModal()
          searchFormatos()
        } else {
          state.error = response.data.eResponse.message || 'Error al guardar el formato'
        }
      } catch (error) {
        console.error('Error saving formato:', error)
        state.error = 'Error de conexión al guardar formato'
      } finally {
        state.loading = false
      }
    }

    const toggleStatus = async (formato) => {
      const newStatus = formato.activo === 'S' ? 'N' : 'S'
      const action = newStatus === 'S' ? 'activar' : 'desactivar'

      if (!confirm(`¿Está seguro de ${action} el formato "${formato.nombre}"?`)) {
        return
      }

      state.loading = true

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
            Operacion: 'sp_formatosecologia_cambiar_estado',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_id', valor: formato.id },
              { nombre: 'p_activo', valor: newStatus }
            ],
            Tenant: 'public'
          }
          })
        })

        const data = await response.json()

        if (data.eResponse.success) {
          showSuccessNotification(`Formato ${action === 'activar' ? 'activado' : 'desactivado'} correctamente`)
          searchFormatos()
        } else {
          state.error = response.data.eResponse.message || `Error al ${action} formato`
        }
      } catch (error) {
        console.error('Error toggling status:', error)
        state.error = `Error de conexión al ${action} formato`
      } finally {
        state.loading = false
      }
    }

    // Utility Methods
    const showSuccessNotification = (message) => {
      // TODO: Implement proper notification system
      alert(message)
    }

    const formatDate = (dateString) => {
      if (!dateString) return '-'
      const date = new Date(dateString)
      return date.toLocaleDateString('es-MX', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
      })
    }

    const formatDateTime = (dateString) => {
      if (!dateString) return '-'
      const date = new Date(dateString)
      return date.toLocaleString('es-MX', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const formatTipo = (tipo) => {
      const tipos = {
        'IMPACTO_AMBIENTAL': 'Impacto Ambiental',
        'RESIDUOS': 'Gestión de Residuos',
        'EMISIONES': 'Control de Emisiones',
        'AGUA': 'Uso de Agua',
        'RUIDO': 'Control de Ruido',
        'CERTIFICACION': 'Certificación Ambiental'
      }
      return tipos[tipo] || tipo
    }

    const getTipoBadgeClass = (tipo) => {
      const classes = {
        'IMPACTO_AMBIENTAL': 'bg-danger',
        'RESIDUOS': 'bg-warning text-dark',
        'EMISIONES': 'bg-info text-dark',
        'AGUA': 'bg-primary',
        'RUIDO': 'bg-secondary',
        'CERTIFICACION': 'bg-success'
      }
      return classes[tipo] || 'bg-light text-dark'
    }

    // Initialize component
    onMounted(() => {
      searchFormatos()
    })

    // Return everything for template access
    return {
      state,
      searchFormatos,
      refreshData,
      clearFilters,
      exportData,
      goToPage,
      viewDetail,
      closeDetailModal,
      editFromDetail,
      openCreateModal,
      editFormato,
      closeFormModal,
      saveFormato,
      toggleStatus,
      formatDate,
      formatDateTime,
      formatTipo,
      getTipoBadgeClass,
      debouncedSearch
    }
  }
}
</script>

<style scoped>
.municipal-header {
  background: linear-gradient(135deg, #2c5530 0%, #4a7c59 100%);
  color: white;
  border-radius: 0;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.municipal-controls {
  background-color: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
}

.btn-municipal-white {
  background-color: white;
  border: 1px solid #dee2e6;
  color: #6c757d;
  padding: 0.375rem 0.75rem;
  margin-right: 0.25rem;
}

.btn-municipal-white:hover {
  background-color: #e9ecef;
  color: #495057;
}

.btn-municipal-success {
  background-color: #198754;
  border-color: #198754;
  color: white;
}

.btn-municipal-success:hover {
  background-color: #157347;
  border-color: #146c43;
}

.table-responsive {
  border-radius: 0.375rem;
  overflow: hidden;
}

.table-hover tbody tr:hover {
  background-color: rgba(0,123,255,0.05);
}

.modal-content {
  border: none;
  border-radius: 0.5rem;
  box-shadow: 0 10px 30px rgba(0,0,0,0.2);
}

.form-control:focus,
.form-select:focus {
  border-color: #2c5530;
  box-shadow: 0 0 0 0.2rem rgba(44, 85, 48, 0.25);
}

.btn-group-sm > .btn {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.card {
  border: none;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.badge {
  font-size: 0.75em;
}

@media (max-width: 768px) {
  .btn-group {
    flex-direction: column;
  }

  .btn-group-sm > .btn {
    margin-bottom: 0.25rem;
  }

  .table-responsive {
    font-size: 0.875rem;
  }

  .modal-dialog {
    margin: 0.5rem;
  }
}
</style>