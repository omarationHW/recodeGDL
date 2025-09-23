<template>
  <div class="container-fluid p-0 h-100">
    <!-- Header -->
    <div class="bg-primary text-white p-3 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1">📜 Gestión de Constancias</h1>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0 bg-transparent p-0">
              <li class="breadcrumb-item"><a href="#" class="text-white-50">Inicio</a></li>
              <li class="breadcrumb-item"><a href="#" class="text-white-50">Licencias</a></li>
              <li class="breadcrumb-item text-white active">Constancias</li>
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
            <button type="button" class="btn btn-success" @click="nuevaConstancia" :disabled="formActive">
              <i class="fas fa-plus me-1"></i> Nueva
            </button>
            <button type="button" class="btn btn-warning" @click="modificarConstancia" :disabled="!selectedRow || formActive">
              <i class="fas fa-edit me-1"></i> Modificar
            </button>
            <button type="button" class="btn btn-danger" @click="eliminarConstancia" :disabled="!selectedRow || formActive">
              <i class="fas fa-trash me-1"></i> Eliminar
            </button>
            <button type="button" class="btn btn-info" @click="imprimirConstancia" :disabled="!selectedRow">
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
              <option value="solicita">Solicitante</option>
              <option value="folio">Folio</option>
              <option value="partidapago">Partida Pago</option>
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
            <table class="table table-hover table-sm mb-0" style="min-width: 1400px;">
              <thead class="table-dark sticky-top">
                <tr>
                  <th style="width: 60px;">#</th>
                  <th style="width: 80px;">Año</th>
                  <th style="width: 80px;">Folio</th>
                  <th style="width: 120px;">ID Licencia</th>
                  <th style="width: 250px;">Solicita</th>
                  <th style="width: 120px;">Partida Pago</th>
                  <th style="width: 250px;">Domicilio</th>
                  <th style="width: 120px;">Tipo</th>
                  <th style="width: 200px;">Observación</th>
                  <th style="width: 100px;">Vigente</th>
                  <th style="width: 120px;">Fecha</th>
                  <th style="width: 120px;">Capturista</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in paginatedConstancias"
                    :key="row.axo + '-' + row.folio"
                    :class="{ 'table-primary': isSelected(row) }"
                    @click="selectRow(row)"
                    style="cursor: pointer;">
                  <td>{{ (currentPage - 1) * itemsPerPage + index + 1 }}</td>
                  <td>{{ row.axo }}</td>
                  <td><span class="badge bg-secondary">{{ row.folio }}</span></td>
                  <td>{{ row.id_licencia }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.solicita">{{ row.solicita }}</td>
                  <td>{{ row.partidapago }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.domicilio">{{ row.domicilio }}</td>
                  <td>
                    <span v-if="row.tipo" class="badge bg-info">{{ getTypeName(row.tipo) }}</span>
                  </td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.observacion">{{ row.observacion }}</td>
                  <td>
                    <span :class="['badge', row.vigente === 'V' ? 'bg-success' : 'bg-danger']">
                      {{ row.vigente === 'V' ? 'Vigente' : 'Cancelada' }}
                    </span>
                  </td>
                  <td>{{ formatDate(row.feccap) }}</td>
                  <td>{{ row.capturista }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Paginación -->
        <div class="card-footer">
          <div class="row align-items-center">
            <div class="col-sm-6">
              <nav v-if="totalPages > 1" aria-label="Paginación de constancias">
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
          <h2>{{ formMode === 'create' ? 'Nueva Constancia' : 'Modificar Constancia' }}</h2>
          <button type="button" class="close-btn" @click="cancelarEdicion">&times;</button>
        </div>

        <div class="modal-body">
          <form @submit.prevent="guardarConstancia">
            <div class="form-row">
              <div class="form-group">
                <label>ID Licencia: <span class="required">*</span></label>
                <input
                  v-model.number="form.id_licencia"
                  type="number"
                  required
                  min="1"
                  :class="{ 'input-error': validationErrors.id_licencia }"
                  @blur="validateField('id_licencia')"
                />
                <div v-if="validationErrors.id_licencia" class="field-error">
                  {{ validationErrors.id_licencia }}
                </div>
              </div>
              <div class="form-group">
                <label>Solicita: <span class="required">*</span></label>
                <input
                  v-model="form.solicita"
                  required
                  maxlength="100"
                  :class="{ 'input-error': validationErrors.solicita }"
                  @blur="validateField('solicita')"
                />
                <div v-if="validationErrors.solicita" class="field-error">
                  {{ validationErrors.solicita }}
                </div>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>Partida Pago:</label>
                <input
                  v-model="form.partidapago"
                  maxlength="20"
                  placeholder="Ej: 12345/2025"
                />
              </div>
              <div class="form-group">
                <label>Tipo:</label>
                <select v-model.number="form.tipo">
                  <option value="">Seleccionar...</option>
                  <option value="1">Constancia de No Adeudo</option>
                  <option value="2">Constancia de Vigencia</option>
                  <option value="3">Constancia General</option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group full-width">
                <label>Domicilio:</label>
                <input
                  v-model="form.domicilio"
                  maxlength="150"
                  placeholder="Dirección completa del establecimiento"
                />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group full-width">
                <label>Observación:</label>
                <textarea
                  v-model="form.observacion"
                  maxlength="200"
                  rows="3"
                  placeholder="Observaciones adicionales (opcional)"
                ></textarea>
                <div class="character-count">{{ form.observacion.length }}/200</div>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>Estado:</label>
                <select v-model="form.vigente" required>
                  <option value="V">Vigente</option>
                  <option value="C">Cancelada</option>
                </select>
              </div>
            </div>

            <div class="form-actions">
              <button type="submit" :disabled="loading">
                {{ loading ? 'Guardando...' : (formMode === 'create' ? 'Crear' : 'Actualizar') }}
              </button>
              <button type="button" @click="cancelarEdicion">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Loading overlay global -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
      </div>
    </div>

    <!-- SweetAlert Modal -->
    <div v-if="sweetAlert.show" class="sweet-alert-overlay" @click="sweetAlert.backdrop && closeSweetAlert()">
      <div class="sweet-alert-modal" @click.stop>
        <div class="sweet-alert-header">
          <div :class="['sweet-alert-icon', 'sweet-alert-' + sweetAlert.type]">
            <i :class="getSweetAlertIcon(sweetAlert.type)"></i>
          </div>
          <h3 class="sweet-alert-title">{{ sweetAlert.title }}</h3>
        </div>
        <div class="sweet-alert-body">
          <p>{{ sweetAlert.text }}</p>
        </div>
        <div class="sweet-alert-actions">
          <button v-if="sweetAlert.showCancelButton"
                  @click="sweetAlert.onCancel && sweetAlert.onCancel(); closeSweetAlert()"
                  class="sweet-alert-btn sweet-alert-cancel">
            {{ sweetAlert.cancelButtonText || 'Cancelar' }}
          </button>
          <button @click="sweetAlert.onConfirm && sweetAlert.onConfirm(); closeSweetAlert()"
                  :class="['sweet-alert-btn', 'sweet-alert-confirm', 'sweet-alert-' + sweetAlert.type]">
            {{ sweetAlert.confirmButtonText || 'Aceptar' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Toast notifications -->
    <div v-if="toast.show" :class="['toast', `toast-${toast.type}`]">
      <div class="toast-content">
        <i :class="getToastIcon(toast.type)"></i>
        <span>{{ toast.message }}</span>
        <button class="toast-close" @click="hideToast">&times;</button>
      </div>
    </div>

    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'ConstanciaForm',
  data() {
    return {
      constancias: [],
      filteredConstancias: [],
      selectedRow: null,
      formActive: false,
      formMode: 'create',
      loading: false,
      loadingMessage: 'Cargando...',
      error: '',
      form: {
        id_licencia: '',
        solicita: '',
        partidapago: '',
        domicilio: '',
        tipo: '',
        observacion: '',
        vigente: 'V'
      },
      validationErrors: {},
      toast: {
        show: false,
        type: 'success', // success, error, warning, info
        message: '',
        timeout: null
      },
      sweetAlert: {
        show: false,
        type: 'info', // success, error, warning, info
        title: '',
        text: '',
        showCancelButton: false,
        confirmButtonText: 'Aceptar',
        cancelButtonText: 'Cancelar',
        backdrop: true,
        onConfirm: null,
        onCancel: null
      },
      searchType: 'solicita',
      searchValue: '',
      currentPage: 1,
      itemsPerPage: 10
    }
  },
  computed: {
    totalRegistros() {
      return this.filteredConstancias.length
    },
    totalPages() {
      return Math.ceil(this.filteredConstancias.length / this.itemsPerPage)
    },
    paginatedConstancias() {
      const start = (this.currentPage - 1) * this.itemsPerPage
      const end = start + this.itemsPerPage
      return this.filteredConstancias.slice(start, end)
    }
  },
  mounted() {
    this.cargarDatos()
  },
  methods: {
    async callAPI(operation, params = []) {
      const requestBody = {
        eRequest: {
          Operacion: operation,
          Base: 'padron_licencias',
          Parametros: params,
          Tenant: 'informix'
        }
      }

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(requestBody)
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        if (data.eResponse.success && data.eResponse.data.result) {
          return { success: true, data: data.eResponse.data.result }
        }
        return data
      } catch (error) {
        console.error('API Error:', error)
        throw error
      }
    },

    async cargarDatos(filters = {}) {
      this.loading = true
      this.loadingMessage = 'Cargando constancias...'
      this.error = ''
      try {
        // Usar el API genérica
        const response = await axios.post('http://localhost:8000/api/generic', {
          eRequest: {
            Operacion: 'sp_constancia_list',
            Base: 'padron_licencias',
            Tenant: 'guadalajara'
          }
        })

        if (response.data.eResponse.success) {
          this.constancias = response.data.eResponse.data.result || []
        } else {
          this.constancias = []
          this.error = response.data.eResponse.message || 'Error al cargar los datos'
        }
        this.filteredConstancias = [...this.constancias]
        this.selectedRow = null
        this.showToast('success', `${this.constancias.length} constancias cargadas exitosamente`)
        console.log('Constancias cargadas:', this.constancias.length)
      } catch (error) {
        console.error('Error loading constancias:', error)
        this.error = 'Error al cargar constancias: ' + error.message
        this.showToast('error', 'Error al cargar constancias')
        this.constancias = []
        this.filteredConstancias = []
      } finally {
        this.loading = false
      }
    },

    // Métodos de validación
    validateField(fieldName) {
      this.validationErrors = { ...this.validationErrors }
      delete this.validationErrors[fieldName]

      switch (fieldName) {
        case 'id_licencia':
          if (!this.form.id_licencia || this.form.id_licencia < 1) {
            this.validationErrors.id_licencia = 'ID Licencia es obligatorio y debe ser mayor a 0'
          }
          break
        case 'solicita':
          if (!this.form.solicita || this.form.solicita.trim().length < 3) {
            this.validationErrors.solicita = 'El nombre del solicitante es obligatorio (mín. 3 caracteres)'
          }
          break
      }
    },

    validateForm() {
      this.validationErrors = {}
      this.validateField('id_licencia')
      this.validateField('solicita')
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
        info: 'fas fa-info'
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
        this.filteredConstancias = [...this.constancias]
      } else {
        const term = this.searchValue.toLowerCase()
        this.filteredConstancias = this.constancias.filter(item => {
          switch (this.searchType) {
            case 'solicita':
              return String(item.solicita || '').toLowerCase().includes(term)
            case 'folio':
              return String(item.folio || '').includes(term)
            case 'partidapago':
              return String(item.partidapago || '').toLowerCase().includes(term)
            default:
              return false
          }
        })
      }
      this.currentPage = 1
    },

    selectRow(row) {
      this.selectedRow = row
      this.formActive = false
    },

    isSelected(row) {
      return this.selectedRow &&
             row.axo === this.selectedRow.axo &&
             row.folio === this.selectedRow.folio
    },

    nuevaConstancia() {
      this.formActive = true
      this.formMode = 'create'
      this.form = {
        id_licencia: '',
        solicita: '',
        partidapago: '',
        domicilio: '',
        tipo: '',
        observacion: '',
        vigente: 'V'
      }
      this.selectedRow = null
    },

    modificarConstancia() {
      if (!this.selectedRow) return
      this.formActive = true
      this.formMode = 'update'
      this.form = {
        id_licencia: this.selectedRow.id_licencia,
        solicita: this.selectedRow.solicita,
        partidapago: this.selectedRow.partidapago,
        domicilio: this.selectedRow.domicilio,
        tipo: this.selectedRow.tipo,
        observacion: this.selectedRow.observacion,
        vigente: this.selectedRow.vigente
      }
    },

    cancelarEdicion() {
      this.formActive = false
      this.form = {
        id_licencia: '',
        solicita: '',
        partidapago: '',
        domicilio: '',
        tipo: '',
        observacion: '',
        vigente: 'V'
      }
    },

    async guardarConstancia() {
      this.error = ''

      // Validar formulario
      if (!this.validateForm()) {
        this.showToast('warning', 'Por favor corrige los errores en el formulario')
        return
      }

      // Confirmar acción con SweetAlert
      const mensaje = this.formMode === 'create'
        ? `¿Está seguro de crear esta constancia para "${this.form.solicita}"?`
        : `¿Está seguro de actualizar la constancia de "${this.form.solicita}"?`

      const shouldProceed = await this.showSweetAlert({
        type: this.formMode === 'create' ? 'question' : 'warning',
        title: this.formMode === 'create' ? '¿Crear Constancia?' : '¿Actualizar Constancia?',
        text: mensaje,
        showCancelButton: true,
        confirmButtonText: this.formMode === 'create' ? 'Sí, crear' : 'Sí, actualizar',
        cancelButtonText: 'Cancelar'
      })

      if (!shouldProceed) return

      this.loading = true
      this.loadingMessage = this.formMode === 'create' ? 'Creando constancia...' : 'Actualizando constancia...'

      try {
        if (this.formMode === 'create') {
          // Llamar SP para crear nueva constancia
          const result = await this.callAPI('sp_constancia_insert', [
            this.form.id_licencia,
            this.form.solicita,
            this.form.partidapago || '',
            this.form.domicilio || '',
            this.form.tipo || null,
            this.form.observacion || '',
            this.form.vigente
          ])
          this.showToast('success', `Constancia creada exitosamente (Folio: ${result.data?.[0]?.folio || 'N/A'})`)
        } else {
          // Llamar SP para actualizar constancia
          await this.callAPI('sp_constancia_update', [
            this.selectedRow.axo,
            this.selectedRow.folio,
            this.form.id_licencia,
            this.form.solicita,
            this.form.partidapago || '',
            this.form.domicilio || '',
            this.form.tipo || null,
            this.form.observacion || '',
            this.form.vigente
          ])
          this.showToast('success', 'Constancia actualizada exitosamente')
        }

        // Mostrar alerta de éxito con SweetAlert
        await this.showSweetAlert({
          type: 'success',
          title: '¡Éxito!',
          text: this.formMode === 'create' ? 'Constancia creada exitosamente' : 'Constancia actualizada exitosamente',
          confirmButtonText: 'Entendido'
        })

        this.formActive = false
        await this.cargarDatos()
      } catch (error) {
        this.error = 'Error al guardar: ' + error.message
        this.showToast('error', 'Error al guardar la constancia')
      } finally {
        this.loading = false
      }
    },

    async eliminarConstancia() {
      if (!this.selectedRow) return

      const constanciaInfo = `${this.selectedRow.solicita} (Folio: ${this.selectedRow.folio})`
      const shouldDelete = await this.showSweetAlert({
        type: 'warning',
        title: '¿Eliminar Constancia?',
        text: `¿Está seguro de eliminar la constancia de ${constanciaInfo}?`,
        showCancelButton: true,
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'Cancelar'
      })

      if (!shouldDelete) return

      this.loading = true
      this.loadingMessage = 'Eliminando constancia...'

      try {
        await this.callAPI('sp_constancia_delete', [
          this.selectedRow.axo,
          this.selectedRow.folio
        ])
        this.showToast('success', 'Constancia eliminada exitosamente')
        this.selectedRow = null
        await this.cargarDatos()
      } catch (error) {
        this.error = 'Error al eliminar: ' + error.message
        this.showToast('error', 'Error al eliminar la constancia')
      } finally {
        this.loading = false
      }
    },

    async imprimirConstancia() {
      if (!this.selectedRow) return

      try {
        const result = await this.callAPI('sp_constancia_print', [
          this.selectedRow.axo,
          this.selectedRow.folio
        ])

        if (result.data && result.data.length > 0) {
          // Abrir ventana de impresión o PDF
          window.print()
        }
      } catch (error) {
        this.error = 'Error al imprimir: ' + error.message
      }
    },

    onSearchTypeChange() {
      this.searchValue = ''
      this.filteredConstancias = [...this.constancias]
      this.currentPage = 1
    },

    onItemsPerPageChange() {
      this.currentPage = 1
    },

    formatDate(date) {
      if (!date) return ''
      try {
        return new Date(date).toLocaleDateString('es-ES')
      } catch {
        return date
      }
    },

    getTypeName(tipo) {
      const tipos = {
        1: 'No Adeudo',
        2: 'Vigencia',
        3: 'General'
      }
      return tipos[tipo] || 'N/A'
    }
  }
}
</script>

<style scoped>
/* Bootstrap overrides and custom styles */
.h-100 {
  height: 100vh !important;
}

/* Table styling improvements */
.table-responsive {
  border-radius: 0.375rem;
}

.table th, .table td {
  vertical-align: middle;
  border-color: #dee2e6;
}

.table-hover tbody tr:hover {
  background-color: rgba(0, 123, 255, 0.1);
}

/* Horizontal scroll styling */
.table-responsive::-webkit-scrollbar {
  height: 8px;
}

.table-responsive::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.table-responsive::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

.table-responsive::-webkit-scrollbar-thumb:hover {
  background: #555;
}

/* Modal/Popup Styles */
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
  z-index: 2000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  background: #f8f9fa;
  padding: 16px 20px;
  border-bottom: 1px solid #dee2e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top-left-radius: 8px;
  border-top-right-radius: 8px;
}

.modal-header h2 {
  margin: 0;
  color: #333;
  font-size: 18px;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #666;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  color: #000;
}

.modal-body {
  padding: 20px;
}

.form-row {
  display: flex;
  gap: 16px;
  margin-bottom: 12px;
}

.form-group {
  flex: 1;
}

.form-group.full-width {
  flex: 2;
}

.form-group label {
  display: block;
  margin-bottom: 4px;
  font-weight: bold;
  color: #555;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 6px 8px;
  border: 1px solid #ccc;
  border-radius: 3px;
  box-sizing: border-box;
}

.form-group textarea {
  resize: vertical;
}

.form-actions {
  margin-top: 16px;
  display: flex;
  gap: 8px;
}

.form-actions button {
  padding: 8px 16px;
  border: 1px solid #ccc;
  cursor: pointer;
  border-radius: 3px;
}

.form-actions button[type="submit"] {
  background: #007bff;
  color: white;
  border-color: #007bff;
}

.form-actions button[type="submit"]:hover {
  background: #0056b3;
}

.form-actions button[type="button"] {
  background: #6c757d;
  color: white;
  border-color: #6c757d;
}

.form-actions button[type="button"]:hover {
  background: #545b62;
}

/* Loading Overlay */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 2000;
}

.loading-spinner {
  background: white;
  padding: 30px;
  border-radius: 8px;
  text-align: center;
  min-width: 200px;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #007bff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 15px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-spinner p {
  margin: 0;
  font-weight: bold;
  color: #333;
}

/* Toast Notifications */
.toast {
  position: fixed;
  top: 20px;
  right: 20px;
  min-width: 300px;
  max-width: 500px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  z-index: 1500;
  animation: slideIn 0.3s ease-out;
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

.toast-success {
  background: #d4edda;
  border: 1px solid #c3e6cb;
  color: #155724;
}

.toast-error {
  background: #f8d7da;
  border: 1px solid #f5c6cb;
  color: #721c24;
}

.toast-warning {
  background: #fff3cd;
  border: 1px solid #ffeaa7;
  color: #856404;
}

.toast-info {
  background: #d1ecf1;
  border: 1px solid #bee5eb;
  color: #0c5460;
}

.toast-content {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  gap: 10px;
}

.toast-content i {
  font-size: 18px;
  flex-shrink: 0;
}

.toast-content span {
  flex: 1;
  font-weight: 500;
}

.toast-close {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  padding: 0;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0.7;
}

.toast-close:hover {
  opacity: 1;
}

/* Validation Styles */
.required {
  color: #dc3545;
  font-weight: bold;
}

.input-error {
  border-color: #dc3545 !important;
  box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25);
}

.field-error {
  color: #dc3545;
  font-size: 12px;
  margin-top: 4px;
  font-weight: 500;
}

.character-count {
  font-size: 11px;
  color: #666;
  text-align: right;
  margin-top: 4px;
}

.form-group input::placeholder,
.form-group textarea::placeholder {
  color: #999;
  font-style: italic;
}

.error {
  color: #dc3545;
  background: #f8d7da;
  padding: 12px;
  border: 1px solid #f5c6cb;
  border-radius: 4px;
  margin-bottom: 16px;
}

/* SweetAlert Styles */
.sweet-alert-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2500;
  backdrop-filter: blur(2px);
}

.sweet-alert-modal {
  background: white;
  border-radius: 12px;
  min-width: 320px;
  max-width: 500px;
  padding: 0;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  animation: sweetAlertSlideIn 0.3s ease-out;
  text-align: center;
}

@keyframes sweetAlertSlideIn {
  from {
    opacity: 0;
    transform: scale(0.8) translateY(-20px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

.sweet-alert-header {
  padding: 30px 20px 20px;
}

.sweet-alert-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  margin: 0 auto 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  color: white;
}

.sweet-alert-success {
  background: #28a745;
}

.sweet-alert-error {
  background: #dc3545;
}

.sweet-alert-warning {
  background: #ffc107;
  color: #212529 !important;
}

.sweet-alert-info {
  background: #17a2b8;
}

.sweet-alert-title {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
  color: #333;
}

.sweet-alert-body {
  padding: 0 30px 20px;
}

.sweet-alert-body p {
  margin: 0;
  font-size: 16px;
  color: #666;
  line-height: 1.5;
}

.sweet-alert-actions {
  padding: 20px 30px 30px;
  display: flex;
  gap: 10px;
  justify-content: center;
}

.sweet-alert-btn {
  padding: 12px 24px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  min-width: 100px;
}

.sweet-alert-cancel {
  background: #6c757d;
  color: white;
}

.sweet-alert-cancel:hover {
  background: #5a6268;
  transform: translateY(-1px);
}

.sweet-alert-confirm {
  color: white;
}

.sweet-alert-confirm.sweet-alert-success {
  background: #28a745;
}

.sweet-alert-confirm.sweet-alert-success:hover {
  background: #218838;
  transform: translateY(-1px);
}

.sweet-alert-confirm.sweet-alert-error {
  background: #dc3545;
}

.sweet-alert-confirm.sweet-alert-error:hover {
  background: #c82333;
  transform: translateY(-1px);
}

.sweet-alert-confirm.sweet-alert-warning {
  background: #ffc107;
  color: #212529;
}

.sweet-alert-confirm.sweet-alert-warning:hover {
  background: #e0a800;
  transform: translateY(-1px);
}

.sweet-alert-confirm.sweet-alert-info {
  background: #17a2b8;
}

.sweet-alert-confirm.sweet-alert-info:hover {
  background: #138496;
  transform: translateY(-1px);
}
</style>