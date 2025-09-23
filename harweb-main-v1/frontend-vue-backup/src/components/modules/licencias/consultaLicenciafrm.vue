<template>
  <div class="container-fluid p-0 h-100 module-layout">
    <!-- Header -->
    <div class="bg-primary text-white p-3 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1">🏪 Consulta de Licencias Comerciales</h1>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0 bg-transparent p-0">
              <li class="breadcrumb-item"><a href="#" class="text-white-50">Inicio</a></li>
              <li class="breadcrumb-item"><a href="#" class="text-white-50">Licencias</a></li>
              <li class="breadcrumb-item text-white active">Consulta de Licencias</li>
            </ol>
          </nav>
        </div>
        <div class="text-white-50">
          <small>{{ new Date().toLocaleDateString('es-ES') }}</small>
        </div>
      </div>
    </div>

    <!-- Controles -->
    <div class="bg-light border-bottom p-3">
      <div class="row g-3 align-items-center">
        <!-- Botones de acción -->
        <div class="col-lg-8">
          <div class="btn-group" role="group">
            <button type="button" class="btn btn-success" @click="nuevaLicencia" :disabled="formActive">
              <i class="fas fa-plus me-1"></i> Nueva
            </button>
            <button type="button" class="btn btn-warning" @click="modificarLicencia" :disabled="!selectedRow || formActive">
              <i class="fas fa-edit me-1"></i> Modificar
            </button>
            <button type="button" class="btn btn-danger" @click="eliminarLicencia" :disabled="!selectedRow || formActive">
              <i class="fas fa-trash me-1"></i> Eliminar
            </button>
            <button type="button" class="btn btn-info" @click="imprimirLicencia" :disabled="!selectedRow">
              <i class="fas fa-print me-1"></i> Imprimir
            </button>
            <button type="button" class="btn btn-secondary" @click="cargarDatos" :disabled="formActive">
              <i class="fas fa-sync-alt me-1"></i> Actualizar
            </button>
          </div>
        </div>

        <!-- Búsqueda -->
        <div class="col-lg-4">
          <div class="input-group">
            <select v-model="searchType" @change="onSearchTypeChange" class="form-select" style="max-width: 140px;">
              <option value="razon_social">Razón Social</option>
              <option value="num_lic">Número</option>
              <option value="nombre_giro">Giro</option>
              <option value="direccion">Dirección</option>
              <option value="colonia">Colonia</option>
            </select>
            <input
              v-model="searchValue"
              @input="buscar"
              placeholder="Buscar..."
              class="form-control"
            />
            <span class="input-group-text bg-primary text-white">
              <strong>Total: {{ totalRegistros }}</strong>
            </span>
          </div>
        </div>
      </div>
    </div>


    <!-- Tabla -->
    <div class="flex-grow-1 p-3">
      <div class="card">
        <div class="card-body p-0">
          <div class="table-responsive" style="max-height: 600px; overflow-x: auto;">
            <table class="table table-hover table-sm mb-0" style="min-width: 1200px;">
              <thead class="table-dark sticky-top">
                <tr>
                  <th style="width: 60px;">#</th>
                  <th style="width: 120px;">Número Licencia</th>
                  <th style="width: 250px;">Razón Social</th>
                  <th style="width: 200px;">Giro Comercial</th>
                  <th style="width: 250px;">Dirección</th>
                  <th style="width: 150px;">Colonia</th>
                  <th style="width: 100px;">Estado</th>
                  <th style="width: 120px;">Fecha Expedición</th>
                  <th style="width: 120px;">Fecha Vencimiento</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="paginatedLicencias.length === 0">
                  <td colspan="9" class="text-center py-4 text-muted">
                    <i class="fas fa-inbox fa-2x mb-2"></i>
                    <div>No hay registros para mostrar</div>
                  </td>
                </tr>
                <tr v-for="(row, index) in paginatedLicencias"
                    :key="row.num_lic"
                    :class="{ 'table-primary': isSelected(row) }"
                    @click="selectRow(row)"
                    style="cursor: pointer;">
                  <td>{{ (currentPage - 1) * itemsPerPage + index + 1 }}</td>
                  <td><span class="badge bg-secondary">{{ row.num_lic }}</span></td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.razon_social">{{ row.razon_social }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.nombre_giro">{{ row.nombre_giro }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.direccion">{{ row.direccion }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.colonia">{{ row.colonia }}</td>
                  <td>
                    <span :class="['badge', getStatusBadgeClass(row.status_lic)]">
                      {{ row.status_lic }}
                    </span>
                  </td>
                  <td>{{ formatDate(row.fecha_expedicion) }}</td>
                  <td>{{ formatDate(row.fecha_vencimiento) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Paginación -->
        <div class="card-footer">
          <div class="row align-items-center">
            <div class="col-sm-6">
              <nav v-if="totalPages > 1" aria-label="Paginación de licencias">
                <ul class="pagination pagination-sm justify-content-start mb-0">
                  <li class="page-item" :class="{ disabled: currentPage === 1 }">
                    <button class="page-link" @click="currentPage = 1" :disabled="currentPage === 1">
                      <i class="fas fa-angle-double-left"></i>
                    </button>
                  </li>
                  <li class="page-item" :class="{ disabled: currentPage === 1 }">
                    <button class="page-link" @click="currentPage--" :disabled="currentPage === 1">
                      <i class="fas fa-angle-left"></i>
                    </button>
                  </li>
                  <li class="page-item active">
                    <span class="page-link">{{ currentPage }} de {{ totalPages }}</span>
                  </li>
                  <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                    <button class="page-link" @click="currentPage++" :disabled="currentPage === totalPages">
                      <i class="fas fa-angle-right"></i>
                    </button>
                  </li>
                  <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                    <button class="page-link" @click="currentPage = totalPages" :disabled="currentPage === totalPages">
                      <i class="fas fa-angle-double-right"></i>
                    </button>
                  </li>
                </ul>
              </nav>
              <div v-else class="text-start">
                <small class="text-muted">Página 1 de 1</small>
              </div>
            </div>
            <div class="col-sm-6">
              <div class="d-flex align-items-center justify-content-end gap-2">
                <span class="text-muted small">Mostrar:</span>
                <select v-model="itemsPerPage" @change="onItemsPerPageChange" class="form-select form-select-sm" style="width: auto;">
                  <option value="5">5</option>
                  <option value="10">10</option>
                  <option value="25">25</option>
                  <option value="50">50</option>
                  <option value="100">100</option>
                </select>
                <span class="text-muted small">registros</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal/Popup para formulario -->
    <div v-if="formActive" class="modal-overlay" @click="cancelarEdicion">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>{{ formMode === 'create' ? 'Nueva Licencia' : 'Modificar Licencia' }}</h2>
          <button type="button" class="close-btn" @click="cancelarEdicion">&times;</button>
        </div>

        <div class="modal-body">
          <form @submit.prevent="guardarLicencia">
            <div class="form-row">
              <div class="form-group">
                <label>Número Licencia: <span class="required">*</span></label>
                <input
                  v-model="form.num_lic"
                  type="text"
                  required
                  :class="{ 'input-error': validationErrors.num_lic }"
                  @blur="validateField('num_lic')"
                />
                <div v-if="validationErrors.num_lic" class="field-error">
                  {{ validationErrors.num_lic }}
                </div>
              </div>
              <div class="form-group">
                <label>Razón Social: <span class="required">*</span></label>
                <input
                  v-model="form.razon_social"
                  type="text"
                  required
                  :class="{ 'input-error': validationErrors.razon_social }"
                  @blur="validateField('razon_social')"
                />
                <div v-if="validationErrors.razon_social" class="field-error">
                  {{ validationErrors.razon_social }}
                </div>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label>Giro Comercial:</label>
                <input
                  v-model="form.nombre_giro"
                  type="text"
                />
              </div>
              <div class="form-group">
                <label>Estado:</label>
                <select v-model="form.status_lic">
                  <option value="ACTIVA">ACTIVA</option>
                  <option value="INACTIVA">INACTIVA</option>
                  <option value="CANCELADA">CANCELADA</option>
                </select>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group full-width">
                <label>Dirección:</label>
                <textarea
                  v-model="form.direccion"
                  rows="2"
                ></textarea>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label>Colonia:</label>
                <input
                  v-model="form.colonia"
                  type="text"
                />
              </div>
              <div class="form-group">
                <label>Fecha Expedición:</label>
                <input
                  v-model="form.fecha_expedicion"
                  type="date"
                />
              </div>
            </div>
          </form>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" @click="cancelarEdicion">
            <i class="fas fa-times"></i> Cancelar
          </button>
          <button type="button" class="btn btn-primary" @click="guardarLicencia">
            <i class="fas fa-save"></i> {{ formMode === 'create' ? 'Crear' : 'Actualizar' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Toast -->
    <div v-if="toast.show" class="toast-notification" :class="toast.type">
      <div class="toast-icon">
        <i :class="getToastIcon(toast.type)"></i>
      </div>
      <div class="toast-message">{{ toast.message }}</div>
      <button @click="hideToast" class="toast-close">
        <i class="fas fa-times"></i>
      </button>
    </div>

    <!-- Loading overlay global -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
      </div>
    </div>
    <!-- SweetAlert -->
    <div v-if="sweetAlert.show" class="sweet-alert-overlay" @click="sweetAlert.backdrop && closeSweetAlert()">
      <div class="sweet-alert-container" @click.stop>
        <div class="sweet-alert-icon" :class="sweetAlert.type">
          <i :class="getSweetAlertIcon(sweetAlert.type)"></i>
        </div>
        <h3 class="sweet-alert-title">{{ sweetAlert.title }}</h3>
        <p class="sweet-alert-text">{{ sweetAlert.text }}</p>
        <div class="sweet-alert-buttons">
          <button v-if="sweetAlert.showCancelButton" @click="sweetAlert.onCancel(); closeSweetAlert()" class="btn btn-secondary">
            {{ sweetAlert.cancelButtonText }}
          </button>
          <button @click="sweetAlert.onConfirm(); closeSweetAlert()" class="btn" :class="sweetAlert.type === 'error' ? 'btn-danger' : 'btn-primary'">
            {{ sweetAlert.confirmButtonText }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import licenciasApiService from '@/services/licenciasApiService.js'

export default {
  name: 'ConsultaLicenciafrm',
  data() {
    return {
      // Estado de carga
      loading: false,
      loadingMessage: 'Cargando...',
      error: '',

      // Datos
      licencias: [],
      filteredLicencias: [],
      selectedRow: null,
      searchType: 'razon_social',
      searchValue: '',

      // Paginación
      currentPage: 1,
      itemsPerPage: 25,

      // Formulario
      formActive: false,
      formMode: 'create', // 'create' | 'update'
      form: {
        num_lic: '',
        razon_social: '',
        nombre_giro: '',
        direccion: '',
        colonia: '',
        status_lic: 'ACTIVA',
        fecha_expedicion: '',
        fecha_vencimiento: ''
      },
      validationErrors: {},

      // Toast
      toast: {
        show: false,
        type: 'info',
        message: '',
        timeout: null
      },

      // SweetAlert
      sweetAlert: {
        show: false,
        type: 'info',
        title: '',
        text: '',
        showCancelButton: false,
        confirmButtonText: 'Aceptar',
        cancelButtonText: 'Cancelar',
        backdrop: true,
        onConfirm: () => {},
        onCancel: () => {}
      }
    }
  },

  computed: {
    totalRegistros() {
      return this.filteredLicencias.length
    },

    totalPages() {
      return Math.ceil(this.totalRegistros / this.itemsPerPage)
    },

    paginatedLicencias() {
      const start = (this.currentPage - 1) * this.itemsPerPage
      return this.filteredLicencias.slice(start, start + this.itemsPerPage)
    }
  },

  methods: {
    async cargarDatos(filters = {}) {
      this.loading = true
      this.loadingMessage = 'Cargando licencias...'
      this.error = ''
      try {
        // Usar el servicio API centralizado
        const result = await licenciasApiService.getConsultaLicenciasList({
          ...filters,
          limite: this.itemsPerPage * 10, // Cargar más registros para búsqueda local
          offset: 0
        })

        this.licencias = result || []
        this.filteredLicencias = [...this.licencias]
        this.selectedRow = null
        this.showToast('success', `${this.licencias.length} licencias cargadas exitosamente`)
        console.log('Licencias cargadas:', this.licencias.length)
      } catch (error) {
        console.error('Error loading licencias:', error)
        this.error = 'Error al cargar licencias: ' + error.message
        this.showToast('error', 'Error al cargar licencias')
        this.licencias = []
        this.filteredLicencias = []
      } finally {
        this.loading = false
      }
    },

    // Métodos de validación
    validateField(fieldName) {
      this.validationErrors = { ...this.validationErrors }
      delete this.validationErrors[fieldName]

      switch (fieldName) {
        case 'num_lic':
          if (!this.form.num_lic || this.form.num_lic.trim().length < 1) {
            this.validationErrors.num_lic = 'Número de licencia es obligatorio'
          }
          break
        case 'razon_social':
          if (!this.form.razon_social || this.form.razon_social.trim().length < 3) {
            this.validationErrors.razon_social = 'Razón social es obligatoria (mín. 3 caracteres)'
          }
          break
      }
    },

    validateForm() {
      this.validationErrors = {}
      this.validateField('num_lic')
      this.validateField('razon_social')
      return Object.keys(this.validationErrors).length === 0
    },

    // Métodos de Toast
    showToast(type, message, duration = 4000) {
      if (this.toast.timeout) {
        clearTimeout(this.toast.timeout)
      }

      this.toast = {
        show: true,
        type,
        message,
        timeout: setTimeout(() => {
          this.hideToast()
        }, duration)
      }
    },

    hideToast() {
      this.toast.show = false
      if (this.toast.timeout) {
        clearTimeout(this.toast.timeout)
        this.toast.timeout = null
      }
    },

    getToastIcon(type) {
      const icons = {
        success: 'fas fa-check-circle',
        error: 'fas fa-exclamation-circle',
        warning: 'fas fa-exclamation-triangle',
        info: 'fas fa-info-circle'
      }
      return icons[type] || icons.info
    },

    // SweetAlert methods
    getSweetAlertIcon(type) {
      const icons = {
        success: 'fas fa-check',
        error: 'fas fa-times',
        warning: 'fas fa-exclamation',
        info: 'fas fa-info',
        question: 'fas fa-question'
      }
      return icons[type] || icons.info
    },

    showSweetAlert(options) {
      return new Promise((resolve) => {
        this.sweetAlert = {
          show: true,
          type: options.type || 'info',
          title: options.title || '',
          text: options.text || '',
          showCancelButton: options.showCancelButton || false,
          confirmButtonText: options.confirmButtonText || 'Aceptar',
          cancelButtonText: options.cancelButtonText || 'Cancelar',
          backdrop: options.backdrop !== false,
          onConfirm: () => resolve(true),
          onCancel: () => resolve(false)
        }
      })
    },

    closeSweetAlert() {
      this.sweetAlert.show = false
    },

    buscar() {
      if (!this.searchValue.trim()) {
        this.filteredLicencias = [...this.licencias]
      } else {
        const term = this.searchValue.toLowerCase()
        this.filteredLicencias = this.licencias.filter(item => {
          const fieldValue = String(item[this.searchType] || '').toLowerCase()
          return fieldValue.includes(term)
        })
      }
      this.currentPage = 1
    },

    onSearchTypeChange() {
      this.searchValue = ''
      this.filteredLicencias = [...this.licencias]
      this.currentPage = 1
    },

    selectRow(row) {
      this.selectedRow = row
      this.formActive = false
    },

    isSelected(row) {
      return this.selectedRow && this.selectedRow.num_lic === row.num_lic
    },

    onItemsPerPageChange() {
      this.currentPage = 1
    },

    nuevaLicencia() {
      this.formActive = true
      this.formMode = 'create'
      this.form = {
        num_lic: '',
        razon_social: '',
        nombre_giro: '',
        direccion: '',
        colonia: '',
        status_lic: 'ACTIVA',
        fecha_expedicion: '',
        fecha_vencimiento: ''
      }
      this.selectedRow = null
    },

    modificarLicencia() {
      if (!this.selectedRow) return
      this.formActive = true
      this.formMode = 'update'
      this.form = {
        num_lic: this.selectedRow.num_lic,
        razon_social: this.selectedRow.razon_social,
        nombre_giro: this.selectedRow.nombre_giro,
        direccion: this.selectedRow.direccion,
        colonia: this.selectedRow.colonia,
        status_lic: this.selectedRow.status_lic,
        fecha_expedicion: this.selectedRow.fecha_expedicion,
        fecha_vencimiento: this.selectedRow.fecha_vencimiento
      }
    },

    cancelarEdicion() {
      this.formActive = false
      this.form = {
        num_lic: '',
        razon_social: '',
        nombre_giro: '',
        direccion: '',
        colonia: '',
        status_lic: 'ACTIVA',
        fecha_expedicion: '',
        fecha_vencimiento: ''
      }
    },

    async guardarLicencia() {
      this.error = ''

      // Validar formulario
      if (!this.validateForm()) {
        this.showToast('warning', 'Por favor corrige los errores en el formulario')
        return
      }

      // Confirmar acción con SweetAlert
      const mensaje = this.formMode === 'create'
        ? `¿Está seguro de crear esta licencia para "${this.form.razon_social}"?`
        : `¿Está seguro de actualizar la licencia de "${this.form.razon_social}"?`

      const shouldProceed = await this.showSweetAlert({
        type: this.formMode === 'create' ? 'question' : 'warning',
        title: this.formMode === 'create' ? '¿Crear Licencia?' : '¿Actualizar Licencia?',
        text: mensaje,
        showCancelButton: true,
        confirmButtonText: this.formMode === 'create' ? 'Sí, crear' : 'Sí, actualizar',
        cancelButtonText: 'Cancelar'
      })

      if (!shouldProceed) return

      this.loading = true
      this.loadingMessage = this.formMode === 'create' ? 'Creando licencia...' : 'Actualizando licencia...'

      try {
        if (this.formMode === 'create') {
          // Crear nueva licencia usando el servicio API centralizado
          const licenciaData = {
            numero_licencia: this.form.num_lic,
            razon_social: this.form.razon_social,
            giro: this.form.nombre_giro || '',
            direccion: this.form.direccion || '',
            colonia: this.form.colonia || '',
            estado: this.form.status_lic,
            fecha_expedicion: this.form.fecha_expedicion || new Date().toISOString().split('T')[0],
            propietario: this.form.razon_social, // Asumir que razón social es el propietario por defecto
            usuario_registro: 'USUARIO_SISTEMA' // TODO: Obtener del contexto de usuario
          }

          const result = await licenciasApiService.createConsultaLicencia(licenciaData)
          this.showToast('success', `Licencia creada exitosamente (${this.form.num_lic})`)
        } else {
          // Actualizar licencia existente usando el servicio API centralizado
          const licenciaData = {
            numero_licencia: this.form.num_lic,
            razon_social: this.form.razon_social,
            giro: this.form.nombre_giro || '',
            direccion: this.form.direccion || '',
            colonia: this.form.colonia || '',
            estado: this.form.status_lic,
            fecha_expedicion: this.form.fecha_expedicion,
            propietario: this.form.razon_social
          }

          const result = await licenciasApiService.updateConsultaLicencia(this.selectedRow.id, licenciaData)
          this.showToast('success', `Licencia actualizada exitosamente (${this.form.num_lic})`)
        }

        this.cancelarEdicion()
        await this.cargarDatos() // Recargar datos

      } catch (error) {
        console.error('Error saving licencia:', error)
        this.showToast('error', `Error al ${this.formMode === 'create' ? 'crear' : 'actualizar'} licencia: ${error.message}`)
      } finally {
        this.loading = false
      }
    },

    async eliminarLicencia() {
      if (!this.selectedRow) return

      const shouldProceed = await this.showSweetAlert({
        type: 'warning',
        title: '¿Eliminar Licencia?',
        text: `¿Está seguro de eliminar la licencia "${this.selectedRow.num_lic}" de "${this.selectedRow.razon_social}"? Esta acción no se puede deshacer.`,
        showCancelButton: true,
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'Cancelar'
      })

      if (!shouldProceed) return

      this.loading = true
      this.loadingMessage = 'Eliminando licencia...'

      try {
        await licenciasApiService.deleteConsultaLicencia(this.selectedRow.id)
        this.showToast('success', `Licencia ${this.selectedRow.num_lic} eliminada exitosamente`)
        this.selectedRow = null
        await this.cargarDatos()
      } catch (error) {
        console.error('Error deleting licencia:', error)
        this.showToast('error', `Error al eliminar licencia: ${error.message}`)
      } finally {
        this.loading = false
      }
    },

    imprimirLicencia() {
      if (!this.selectedRow) {
        this.showToast('warning', 'Por favor seleccione una licencia para imprimir')
        return
      }
      this.showToast('info', 'Función de impresión no implementada')
    },

    // Utilidades
    formatDate(date) {
      if (!date) return ''
      try {
        return new Date(date).toLocaleDateString('es-ES')
      } catch {
        return date
      }
    },

    getStatusBadgeClass(estado) {
      switch (estado?.toUpperCase()) {
        case 'ACTIVA': return 'bg-success'
        case 'SUSPENDIDA': return 'bg-warning'
        case 'CANCELADA': return 'bg-danger'
        case 'VENCIDA': return 'bg-danger'
        case 'INACTIVA': return 'bg-secondary'
        default: return 'bg-secondary'
      }
    }
  },

  async mounted() {
    await this.cargarDatos()
  }
}
</script>


<style scoped>
/* Estilos específicos del componente consultaLicenciafrm */
/* Todos los estilos comunes han sido movidos a src/styles/global.css */
</style>
