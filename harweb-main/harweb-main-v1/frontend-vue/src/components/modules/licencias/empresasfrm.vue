<template>
  <div class="municipal-form-page">
    <!-- Header del módulo -->
    <div class="municipal-header">
      <div class="row align-items-center">
        <div class="col">
          <h3 class="mb-1">
            <i class="fas fa-building"></i>
            Gestión de Empresas
          </h3>
          <p class="mb-0 opacity-75">
            Administración del catálogo de empresas del sistema
          </p>
        </div>
        <div class="col-auto">
          <button
            class="btn-municipal-primary"
            @click="showCreateModal = true"
            :disabled="loading"
          >
            <i class="fas fa-plus"></i>
            Nueva Empresa
          </button>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card mb-4">
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">RFC</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.rfc"
              placeholder="RFC de la empresa"
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Razón Social</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.razon_social"
              placeholder="Razón social"
            >
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Nombre Comercial</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.nombre_comercial"
              placeholder="Nombre comercial"
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
                class="btn-municipal-primary"
                @click="searchEmpresas"
                :disabled="loading"
              >
                <i class="fas fa-search"></i>
                Buscar
              </button>
              <button
                class="btn-municipal-secondary"
                @click="clearFilters"
                :disabled="loading"
              >
                <i class="fas fa-times"></i>
                Limpiar
              </button>
              <button
                class="btn-municipal-secondary"
                @click="loadEmpresas"
                :disabled="loading"
              >
                <i class="fas fa-sync-alt"></i>
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
          <i class="fas fa-list"></i>
          Empresas Registradas
          <span v-if="empresas.length > 0" class="municipal-badge municipal-badge-primary ms-2">
            {{ empresas.length }} registros
          </span>
        </h6>
      </div>
      <div class="municipal-card-body">
        <!-- Loading state -->
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2 text-muted">Cargando empresas...</p>
        </div>

        <!-- Error state -->
        <div v-else-if="error" class="municipal-alert-danger">
          <h6 class="alert-heading">Error al cargar datos</h6>
          <p class="mb-0">{{ error }}</p>
          <hr>
          <button class="btn-municipal-primary btn-sm" @click="loadEmpresas">
            <i class="fas fa-retry"></i>
            Reintentar
          </button>
        </div>

        <!-- Empty state -->
        <div v-else-if="empresas.length === 0" class="text-center py-5">
          <i class="fas fa-building fa-3x text-muted mb-3"></i>
          <h5 class="text-muted">No se encontraron empresas</h5>
          <p class="text-muted">
            {{ hasActiveFilters ? 'No hay registros que coincidan con los filtros aplicados.' : 'No hay empresas registradas en el sistema.' }}
          </p>
          <button
            v-if="!hasActiveFilters"
            class="btn-municipal-primary"
            @click="showCreateModal = true"
          >
            <i class="fas fa-plus"></i>
            Registrar primera empresa
          </button>
        </div>

        <!-- Tabla con datos -->
        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>RFC</th>
                <th>Razón Social</th>
                <th>Nombre Comercial</th>
                <th>Teléfono</th>
                <th>Email</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="empresa in paginatedEmpresas" :key="empresa.id">
                <td>
                  <strong class="text-primary">{{ empresa.rfc }}</strong>
                </td>
                <td>{{ empresa.razon_social }}</td>
                <td>{{ empresa.nombre_comercial || 'N/A' }}</td>
                <td>{{ empresa.telefono || 'N/A' }}</td>
                <td>{{ empresa.email || 'N/A' }}</td>
                <td>
                  <span class="municipal-badge" :class="empresa.activo === 'S' ? 'municipal-badge-success' : 'municipal-badge-secondary'">
                    {{ empresa.activo === 'S' ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
                <td>
                  <div class="municipal-group-btn">
                    <button
                      class="btn-municipal-secondary btn-sm"
                      @click="viewEmpresa(empresa)"
                      title="Ver detalles"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      class="btn-municipal-warning btn-sm"
                      @click="editEmpresa(empresa)"
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="deleteEmpresa(empresa)"
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
          <nav aria-label="Paginación de empresas">
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

    <!-- Modal para crear/editar empresa -->
    <div class="modal fade" tabindex="-1" v-if="showCreateModal" style="display: block;" @click.self="showCreateModal = false">
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fas fa-plus"></i>
              {{ editingEmpresa ? 'Editar Empresa' : 'Nueva Empresa' }}
            </h5>
            <button type="button" class="btn-close" @click="showCreateModal = false"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveEmpresa">
              <div class="row">
                <div class="col-md-4">
                  <label class="municipal-form-label">RFC <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newEmpresa.rfc"
                    placeholder="RFC de la empresa"
                    required
                    maxlength="13"
                    :disabled="editingEmpresa"
                  >
                </div>
                <div class="col-md-8">
                  <label class="municipal-form-label">Razón Social <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newEmpresa.razon_social"
                    placeholder="Razón social de la empresa"
                    required
                    maxlength="255"
                  >
                </div>
              </div>
              <div class="row">
                <div class="col-md-6">
                  <label class="municipal-form-label">Nombre Comercial</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newEmpresa.nombre_comercial"
                    placeholder="Nombre comercial"
                    maxlength="255"
                  >
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Giro Empresarial</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newEmpresa.giro_empresarial"
                    placeholder="Giro o actividad empresarial"
                    maxlength="100"
                  >
                </div>
              </div>
              <div class="row">
                <div class="col-md-4">
                  <label class="municipal-form-label">Clasificación</label>
                  <select class="municipal-form-control" v-model="newEmpresa.clasificacion">
                    <option value="PRIVADA">Privada</option>
                    <option value="PUBLICA">Pública</option>
                    <option value="MIXTA">Mixta</option>
                  </select>
                </div>
                <div class="col-md-4">
                  <label class="municipal-form-label">Número de Empleados</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model="newEmpresa.numero_empleados"
                    placeholder="0"
                    min="0"
                  >
                </div>
                <div class="col-md-4">
                  <label class="municipal-form-label">Estado</label>
                  <select class="municipal-form-control" v-model="newEmpresa.estado">
                    <option value="A">Activa</option>
                    <option value="I">Inactiva</option>
                  </select>
                </div>
              </div>
              <div class="row">
                <div class="col-md-6">
                  <label class="municipal-form-label">Dirección</label>
                  <textarea
                    class="municipal-form-control"
                    v-model="newEmpresa.direccion"
                    placeholder="Dirección completa de la empresa"
                    rows="2"
                  ></textarea>
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Teléfono</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newEmpresa.telefono"
                    placeholder="Número telefónico"
                    maxlength="20"
                  >
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Email</label>
                  <input
                    type="email"
                    class="municipal-form-control"
                    v-model="newEmpresa.email"
                    placeholder="Correo electrónico"
                    maxlength="100"
                  >
                </div>
              </div>
              <div class="row">
                <div class="col-md-6">
                  <label class="municipal-form-label">Representante Legal</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newEmpresa.representante_legal"
                    placeholder="Nombre del representante legal"
                    maxlength="255"
                  >
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Observaciones</label>
                  <textarea
                    class="municipal-form-control"
                    v-model="newEmpresa.observaciones"
                    placeholder="Observaciones adicionales"
                    rows="2"
                  ></textarea>
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="municipal-form-label">Notas Administrativas</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newEmpresa.razon_social"
                    placeholder="Razón social de la empresa"
                    required
                    maxlength="200"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="municipal-form-label">Nombre Comercial</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newEmpresa.nombre_comercial"
                    placeholder="Nombre comercial"
                    maxlength="200"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-md-6">
                  <label class="municipal-form-label">Teléfono</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="newEmpresa.telefono"
                    placeholder="Teléfono"
                    maxlength="20"
                  >
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Email</label>
                  <input
                    type="email"
                    class="municipal-form-control"
                    v-model="newEmpresa.email"
                    placeholder="correo@empresa.com"
                    maxlength="100"
                  >
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="municipal-form-label">Dirección</label>
                  <textarea
                    class="municipal-form-control"
                    rows="3"
                    v-model="newEmpresa.direccion"
                    placeholder="Dirección completa"
                    maxlength="500"
                  ></textarea>
                </div>
              </div>
              <div class="row mt-3">
                <div class="col-12">
                  <label class="municipal-form-label">Observaciones</label>
                  <textarea
                    class="municipal-form-control"
                    rows="2"
                    v-model="newEmpresa.observaciones"
                    placeholder="Observaciones adicionales"
                    maxlength="500"
                  ></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="showCreateModal = false">
              Cancelar
            </button>
            <button
              type="button"
              class="btn-municipal-primary"
              @click="saveEmpresa"
              :disabled="creating || !newEmpresa.rfc || !newEmpresa.razon_social || !newEmpresa.genero"
            >
              <span v-if="creating">
                <i class="fas fa-spinner fa-spin"></i>
                {{ editingEmpresa ? 'Actualizando...' : 'Creando...' }}
              </span>
              <span v-else>
                <i class="fas fa-save"></i>
                {{ editingEmpresa ? 'Actualizar Empresa' : 'Crear Empresa' }}
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showCreateModal" class="modal-backdrop fade show"></div>

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
  name: 'EmpresasForm',
  data() {
    return {
      // Estado de carga
      loading: false,
      creating: false,
      error: null,

      // Datos
      empresas: [],
      totalRegistros: 0,

      // Paginación
      currentPage: 1,
      itemsPerPage: 10,
      totalPages: 0,

      // Filtros
      filters: {
        rfc: '',
        razon_social: '',
        nombre_comercial: '',
        activo: ''
      },

      // Modal
      showCreateModal: false,
      editingEmpresa: null,

      // SweetAlert
      sweetAlert: {
        show: false,
        type: 'info',
        title: '',
        text: ''
      },

      // Toast notifications
      toasts: [],

      // Nueva empresa
      newEmpresa: {
        rfc: '',
        razon_social: '',
        nombre_comercial: '',
        telefono: '',
        email: '',
        direccion: '',
        observaciones: '',
        genero: '',
        activo: 'S'
      }
    }
  },

  computed: {
    hasActiveFilters() {
      return Object.values(this.filters).some(value => value !== null && value !== '')
    },

    paginatedEmpresas() {
      const start = (this.currentPage - 1) * this.itemsPerPage
      const end = start + this.itemsPerPage
      return this.empresas.slice(start, end)
    }
  },

  methods: {
    async loadEmpresas() {
      this.loading = true
      this.error = null

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_EMPRESAS_LIST',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_rfc', valor: this.filters.rfc || null },
                { nombre: 'p_razon_social', valor: this.filters.razon_social || null },
                { nombre: 'p_nombre_comercial', valor: this.filters.nombre_comercial || null },
                { nombre: 'p_activo', valor: this.filters.activo || null },
                { nombre: 'p_limite', valor: this.itemsPerPage },
                { nombre: 'p_offset', valor: (this.currentPage - 1) * this.itemsPerPage }
              ],
              Tenant: 'informix'
            }
          })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        console.log('Respuesta del servidor:', data)

        if (data.eResponse && data.eResponse.success) {
          this.empresas = data.eResponse.data.result || []

          // Obtener el total de registros del primer elemento (si existe)
          if (this.empresas.length > 0) {
            this.totalRegistros = parseInt(this.empresas[0].total_registros) || 0
            this.totalPages = Math.ceil(this.totalRegistros / this.itemsPerPage)
          } else {
            this.totalRegistros = 0
            this.totalPages = 0
          }

          console.log(`Cargadas ${this.empresas.length} empresas de ${this.totalRegistros} totales`)
        } else {
          throw new Error(data.eResponse.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.error = 'Error al cargar las empresas: ' + error.message
        console.error('Error loading empresas:', error)
        this.showToast('error', 'Error al cargar empresas')
      } finally {
        this.loading = false
      }
    },

    async searchEmpresas() {
      console.log('Buscando empresas con filtros:', this.filters)
      this.currentPage = 1
      this.loadEmpresas()
    },

    clearFilters() {
      this.filters = {
        rfc: '',
        razon_social: '',
        nombre_comercial: '',
        activo: ''
      }
      this.currentPage = 1
      this.loadEmpresas()
    },

    async saveEmpresa() {
      if (!this.newEmpresa.rfc || !this.newEmpresa.razon_social || !this.newEmpresa.genero) {
        this.showSweetAlert('warning', 'Campos Requeridos', 'Por favor complete los campos requeridos (RFC, Razón Social y Género)')
        return
      }

      this.creating = true

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: this.editingEmpresa ? 'SP_EMPRESAS_UPDATE' : 'SP_EMPRESAS_CREATE',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: this.editingEmpresa ? [
                { nombre: 'p_id', valor: this.editingEmpresa.id },
                { nombre: 'p_rfc', valor: this.newEmpresa.rfc },
                { nombre: 'p_razon_social', valor: this.newEmpresa.razon_social },
                { nombre: 'p_nombre_comercial', valor: this.newEmpresa.nombre_comercial },
                { nombre: 'p_telefono', valor: this.newEmpresa.telefono },
                { nombre: 'p_email', valor: this.newEmpresa.email },
                { nombre: 'p_direccion', valor: this.newEmpresa.direccion },
                { nombre: 'p_observaciones', valor: this.newEmpresa.observaciones },
                { nombre: 'p_genero', valor: this.newEmpresa.genero },
                { nombre: 'p_activo', valor: this.newEmpresa.activo }
              ] : [
                { nombre: 'p_rfc', valor: this.newEmpresa.rfc },
                { nombre: 'p_razon_social', valor: this.newEmpresa.razon_social },
                { nombre: 'p_nombre_comercial', valor: this.newEmpresa.nombre_comercial },
                { nombre: 'p_telefono', valor: this.newEmpresa.telefono },
                { nombre: 'p_email', valor: this.newEmpresa.email },
                { nombre: 'p_direccion', valor: this.newEmpresa.direccion },
                { nombre: 'p_observaciones', valor: this.newEmpresa.observaciones },
                { nombre: 'p_genero', valor: this.newEmpresa.genero },
                { nombre: 'p_activo', valor: this.newEmpresa.activo }
              ],
              Tenant: 'informix'
            }
          })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        console.log('Respuesta del servidor:', data)

        if (data.eResponse && data.eResponse.success) {
          const result = data.eResponse.data.result[0]
          if (result.success) {
            this.showSweetAlert(
              'success',
              this.editingEmpresa ? 'Empresa Actualizada' : 'Empresa Creada',
              result.message || (this.editingEmpresa ? 'Empresa actualizada exitosamente' : 'Empresa creada exitosamente')
            )
            this.resetCreateForm()
            this.showCreateModal = false
            this.loadEmpresas()
          } else {
            this.showSweetAlert('error', 'Error', result.message || 'Error en la operación')
            return
          }
        } else {
          throw new Error(data.eResponse.message || 'Error en la respuesta del servidor')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Guardar', 'Error al guardar la empresa: ' + error.message)
        console.error('Error saving empresa:', error)
      } finally {
        this.creating = false
      }
    },

    editEmpresa(empresa) {
      this.editingEmpresa = empresa
      this.newEmpresa = {
        rfc: empresa.rfc,
        razon_social: empresa.razon_social,
        nombre_comercial: empresa.nombre_comercial || '',
        telefono: empresa.telefono || '',
        email: empresa.email || '',
        direccion: empresa.direccion || '',
        observaciones: empresa.observaciones || '',
        genero: empresa.genero || '',
        activo: empresa.activo || 'S'
      }
      this.showCreateModal = true
    },

    async deleteEmpresa(empresa) {
      if (!confirm(`¿Está seguro de eliminar la empresa "${empresa.razon_social}"?`)) {
        return
      }

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_EMPRESAS_DELETE',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_id', valor: empresa.id }
              ],
              Tenant: 'informix'
            }
          })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()

        if (data.eResponse && data.eResponse.success) {
          this.showSweetAlert('success', 'Empresa Eliminada', 'La empresa ha sido eliminada exitosamente')
          this.loadEmpresas()
        } else {
          throw new Error(data.eResponse.message || 'Error al eliminar la empresa')
        }

      } catch (error) {
        this.showSweetAlert('error', 'Error al Eliminar', 'Error al eliminar la empresa: ' + error.message)
        console.error('Error deleting empresa:', error)
      }
    },

    viewEmpresa(empresa) {
      this.showSweetAlert('info', 'Información de la Empresa',
        `RFC: ${empresa.rfc}\nRazón Social: ${empresa.razon_social}\nNombre Comercial: ${empresa.nombre_comercial || 'N/A'}\nTeléfono: ${empresa.telefono || 'N/A'}\nEmail: ${empresa.email || 'N/A'}\nEstado: ${empresa.activo === 'S' ? 'Activo' : 'Inactivo'}`)
    },

    resetCreateForm() {
      this.editingEmpresa = null
      this.newEmpresa = {
        rfc: '',
        razon_social: '',
        nombre_comercial: '',
        telefono: '',
        email: '',
        direccion: '',
        observaciones: '',
        genero: '',
        activo: 'S'
      }
    },

    // Métodos de paginación
    goToPage(page) {
      if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
        this.currentPage = page
        this.loadEmpresas()
      }
    },

    previousPage() {
      if (this.currentPage > 1) {
        this.currentPage--
        this.loadEmpresas()
      }
    },

    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++
        this.loadEmpresas()
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

      // Auto cerrar después de 3 segundos para success, 5 segundos para error y warning
      const autoCloseTime = (type === 'success' || type === 'info') ? 3000 : 5000
      setTimeout(() => {
        this.sweetAlert.show = false
      }, autoCloseTime)
    },

    closeSweetAlert() {
      this.sweetAlert.show = false
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
    console.log('EmpresasForm component mounted')
    this.loadEmpresas()
  }
}
</script>

