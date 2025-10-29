<template>
  <div class="municipal-form-page">
    <!-- Header -->
    <div class="municipal-header">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1"><i class="fas fa-file-contract me-2"></i>Gestión de Constancias</h1>
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
    <div class="municipal-card mb-3">
      <div class="municipal-card-body">
      <div class="row g-3 align-items-center">
        <!-- Botones de acción -->
        <div class="col-lg-8">
          <div class="municipal-group-btn" role="group">
            <button type="button" class="btn-municipal-primary" @click="nuevaConstancia" :disabled="formActive">
              <i class="fas fa-plus me-1"></i> Nueva
            </button>
            <button type="button" class="btn-municipal-primary" @click="modificarConstancia" :disabled="!selectedRow || formActive">
              <i class="fas fa-edit me-1"></i> Modificar
            </button>
            <button type="button" class="btn-municipal-secondary" @click="eliminarConstancia" :disabled="!selectedRow || formActive">
              <i class="fas fa-trash me-1"></i> Eliminar
            </button>
            <button type="button" class="btn-municipal-secondary" @click="imprimirConstancia" :disabled="!selectedRow">
              <i class="fas fa-print me-1"></i> Imprimir
            </button>
            <button type="button" class="btn-municipal-secondary" @click="cargarDatos" :disabled="formActive">
              <i class="fas fa-sync-alt me-1"></i> Actualizar
            </button>
          </div>
        </div>

        <!-- Búsqueda -->
        <div class="col-lg-4">
          <div class="input-group">
            <select v-model="searchType" @change="onSearchTypeChange" class="municipal-form-control" style="max-width: 140px;">
              <option value="solicita">Solicitante</option>
              <option value="folio">Folio</option>
              <option value="partidapago">Partida Pago</option>
            </select>
            <input
              v-model="searchValue"
              @input="buscar"
              placeholder="Buscar..."
              class="municipal-form-control"
            />
            <span class="input-group-text municipal-badge municipal-badge-primary">
              <strong>Total: {{ totalRegistros }}</strong>
            </span>
          </div>
        </div>
      </div>
    </div>
    </div>

    <!-- Tabla -->
    <div class="flex-grow-1">
      <div class="municipal-card">
        <div class="municipal-card-body p-0">
          <div class="table-responsive" style="max-height: 600px; overflow-x: auto;">
            <table class="municipal-table table-sm mb-0" style="min-width: 1400px;">
              <thead class="municipal-table-header sticky-top">
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
                  <td><span class="municipal-badge municipal-badge-secondary">{{ row.folio }}</span></td>
                  <td>{{ row.id_licencia }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.solicita">{{ row.solicita }}</td>
                  <td>{{ row.partidapago }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.domicilio">{{ row.domicilio }}</td>
                  <td>
                    <span v-if="row.tipo" class="municipal-badge municipal-badge-info">{{ getTypeName(row.tipo) }}</span>
                  </td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.observacion">{{ row.observacion }}</td>
                  <td>
                    <span :class="['municipal-badge', row.vigente === 'V' ? 'municipal-badge-success' : 'municipal-badge-danger']">
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
        <div class="municipal-card-footer">
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
                <select v-model="itemsPerPage" @change="onItemsPerPageChange" class="municipal-form-control form-select-sm" style="width: auto;">
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
                <label class="municipal-form-label">ID Licencia: <span class="required">*</span></label>
                <input
                  v-model.number="form.id_licencia"
                  type="number"
                  class="municipal-form-control"
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
                <label class="municipal-form-label">Solicita: <span class="required">*</span></label>
                <input
                  v-model="form.solicita"
                  class="municipal-form-control"
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
                <label class="municipal-form-label">Partida Pago:</label>
                <input
                  v-model="form.partidapago"
                  class="municipal-form-control"
                  maxlength="20"
                  placeholder="Ej: 12345/2025"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Tipo:</label>
                <select v-model.number="form.tipo" class="municipal-form-control">
                  <option value="">Seleccionar...</option>
                  <option value="1">Constancia de No Adeudo</option>
                  <option value="2">Constancia de Vigencia</option>
                  <option value="3">Constancia General</option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group full-width">
                <label class="municipal-form-label">Domicilio:</label>
                <input
                  v-model="form.domicilio"
                  class="municipal-form-control"
                  maxlength="150"
                  placeholder="Dirección completa del establecimiento"
                />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group full-width">
                <label class="municipal-form-label">Observación:</label>
                <textarea
                  v-model="form.observacion"
                  class="municipal-form-control"
                  maxlength="200"
                  rows="3"
                  placeholder="Observaciones adicionales (opcional)"
                ></textarea>
                <div class="character-count">{{ form.observacion.length }}/200</div>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Estado:</label>
                <select v-model="form.vigente" class="municipal-form-control" required>
                  <option value="V">Vigente</option>
                  <option value="C">Cancelada</option>
                </select>
              </div>
            </div>

            <div class="form-actions">
              <button type="submit" class="btn-municipal-primary" :disabled="loading">
                <i class="fas fa-save me-1" v-if="!loading"></i>
                <i class="fas fa-spinner fa-spin me-1" v-else></i>
                {{ loading ? 'Guardando...' : (formMode === 'create' ? 'Crear' : 'Actualizar') }}
              </button>
              <button type="button" class="btn-municipal-secondary" @click="cancelarEdicion">
                <i class="fas fa-times me-1"></i>
                Cancelar
              </button>
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
                  class="btn-municipal-secondary">
            <i class="fas fa-times me-1"></i>
            {{ sweetAlert.cancelButtonText || 'Cancelar' }}
          </button>
          <button @click="sweetAlert.onConfirm && sweetAlert.onConfirm(); closeSweetAlert()"
                  class="btn-municipal-primary">
            <i class="fas fa-check me-1"></i>
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
          Base: 'licencias',
          Parametros: params,
          Tenant: 'informix'
        }
      }

      try {
        const response = await fetch('http://localhost:8080/api/generic', {
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
        const eRequest = {
          Operacion: 'sp_constancia_list',
          Base: 'licencias',
          Tenant: 'guadalajara',
          Parametros: []
        }

        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })
        const data = await response.json()

        if (data.eResponse.success) {
          this.constancias = data.eResponse.data.result || []
        } else {
          this.constancias = []
          this.error = data.eResponse.message || 'Error al cargar los datos'
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
          const eRequest = {
            Operacion: 'sp_constancia_insert',
            Base: 'licencias',
            Tenant: 'guadalajara',
            Parametros: [
              { nombre: 'p_id_licencia', valor: this.form.id_licencia },
              { nombre: 'p_solicita', valor: this.form.solicita },
              { nombre: 'p_partidapago', valor: this.form.partidapago || '' },
              { nombre: 'p_domicilio', valor: this.form.domicilio || '' },
              { nombre: 'p_tipo', valor: this.form.tipo || null },
              { nombre: 'p_observacion', valor: this.form.observacion || '' },
              { nombre: 'p_vigente', valor: this.form.vigente }
            ]
          }

          const response = await fetch('http://localhost:8080/api/generic', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({ eRequest })
          })
          const data = await response.json()
          if (data.eResponse.success) {
            const result = data.eResponse.data.result[0]
            this.showToast('success', `Constancia creada exitosamente (Folio: ${result?.folio || 'N/A'})`)
          }
        } else {
          // Llamar SP para actualizar constancia
          const eRequest = {
            Operacion: 'sp_constancia_update',
            Base: 'licencias',
            Tenant: 'guadalajara',
            Parametros: [
              { nombre: 'p_axo', valor: this.selectedRow.axo },
              { nombre: 'p_folio', valor: this.selectedRow.folio },
              { nombre: 'p_id_licencia', valor: this.form.id_licencia },
              { nombre: 'p_solicita', valor: this.form.solicita },
              { nombre: 'p_partidapago', valor: this.form.partidapago || '' },
              { nombre: 'p_domicilio', valor: this.form.domicilio || '' },
              { nombre: 'p_tipo', valor: this.form.tipo || null },
              { nombre: 'p_observacion', valor: this.form.observacion || '' },
              { nombre: 'p_vigente', valor: this.form.vigente }
            ]
          }

          await fetch('http://localhost:8080/api/generic', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({ eRequest })
          })
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
        const eRequest = {
          Operacion: 'sp_constancia_delete',
          Base: 'licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_axo', valor: this.selectedRow.axo },
            { nombre: 'p_folio', valor: this.selectedRow.folio }
          ]
        }

        await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })
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
        const eRequest = {
          Operacion: 'sp_constancia_print',
          Base: 'licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_axo', valor: this.selectedRow.axo },
            { nombre: 'p_folio', valor: this.selectedRow.folio }
          ]
        }

        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })
        const data = await response.json()

        if (data.eResponse.success && data.eResponse.data.result.length > 0) {
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
/* Municipal Page Layout */
.municipal-form-page {
  padding: 20px;
  background: #f5f7fa;
  min-height: 100vh;
  font-family: var(--font-municipal);
  display: flex;
  flex-direction: column;
}

/* Municipal Header */
.municipal-header {
  background: var(--gradient-municipal);
  color: white;
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.municipal-header h1 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
}

/* Card Styles */
.municipal-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.municipal-card-body {
  padding: 1.5rem;
}

.municipal-card-footer {
  background: #f8f9fa;
  padding: 1rem 1.5rem;
  border-top: 1px solid #e9ecef;
}

/* Button Styles */
.municipal-group-btn {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.btn-municipal-primary,
.btn-municipal-secondary {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s;
  display: inline-flex;
  align-items: center;
  font-size: 0.875rem;
}

.btn-municipal-primary {
  background: var(--color-primary);
  color: white;
}

.btn-municipal-primary:hover:not(:disabled) {
  background: var(--color-primary-dark);
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.btn-municipal-secondary {
  background: #6c757d;
  color: white;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background: #5a6268;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Form Controls */
.municipal-form-control {
  padding: 0.5rem 0.75rem;
  border: 1px solid #ced4da;
  border-radius: 6px;
  font-size: 0.875rem;
  width: 100%;
  transition: border-color 0.3s, box-shadow 0.3s;
}

.municipal-form-control:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
}

/* Table Styles */
.table-responsive {
  overflow-x: auto;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;
}

.municipal-table-header {
  background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
  color: white;
  position: sticky;
  top: 0;
  z-index: 10;
}

.municipal-table-header th {
  padding: 0.75rem;
  text-align: left;
  font-weight: 600;
  white-space: nowrap;
}

.municipal-table tbody tr {
  border-bottom: 1px solid #e9ecef;
  transition: background-color 0.2s;
}

.municipal-table tbody tr:hover {
  background: #f8f9fa;
}

.municipal-table tbody tr.table-primary {
  background: rgba(0, 123, 255, 0.1);
}

.municipal-table td {
  padding: 0.75rem;
}

/* Badge Styles */
.municipal-badge {
  display: inline-block;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
  text-align: center;
}

.municipal-badge-primary {
  background: var(--color-primary);
  color: white;
}

.municipal-badge-secondary {
  background: #6c757d;
  color: white;
}

.municipal-badge-success {
  background: #28a745;
  color: white;
}

.municipal-badge-danger {
  background: #dc3545;
  color: white;
}

.municipal-badge-info {
  background: #17a2b8;
  color: white;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  max-width: 600px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e9ecef;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.25rem;
  color: var(--color-primary);
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: #6c757d;
  transition: color 0.3s;
}

.close-btn:hover {
  color: #dc3545;
}

.modal-body {
  padding: 1.5rem;
}

/* Form Styles */
.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.municipal-form-label {
  font-weight: 600;
  margin-bottom: 0.5rem;
  font-size: 0.875rem;
  color: #495057;
}

.required {
  color: #dc3545;
}

.input-error {
  border-color: #dc3545;
}

.field-error {
  color: #dc3545;
  font-size: 0.75rem;
  margin-top: 0.25rem;
}

.character-count {
  text-align: right;
  font-size: 0.75rem;
  color: #6c757d;
  margin-top: 0.25rem;
}

.form-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
  margin-top: 1.5rem;
}

/* Loading Overlay */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 2000;
}

.loading-spinner {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  text-align: center;
}

.spinner {
  border: 4px solid #f3f3f3;
  border-top: 4px solid var(--color-primary);
  border-radius: 50%;
  width: 50px;
  height: 50px;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* SweetAlert Styles */
.sweet-alert-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 2500;
}

.sweet-alert-modal {
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  max-width: 400px;
  width: 90%;
  padding: 2rem;
  text-align: center;
}

.sweet-alert-header {
  margin-bottom: 1.5rem;
}

.sweet-alert-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  margin: 0 auto 1rem;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 2rem;
}

.sweet-alert-success {
  background: #d4edda;
  color: #155724;
}

.sweet-alert-error {
  background: #f8d7da;
  color: #721c24;
}

.sweet-alert-warning {
  background: #fff3cd;
  color: #856404;
}

.sweet-alert-info {
  background: #d1ecf1;
  color: #0c5460;
}

.sweet-alert-title {
  font-size: 1.5rem;
  margin: 0;
  color: #333;
}

.sweet-alert-body {
  margin-bottom: 1.5rem;
  color: #666;
}

.sweet-alert-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
}

/* Toast Styles */
.toast {
  position: fixed;
  top: 20px;
  right: 20px;
  min-width: 300px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 3000;
  animation: slideIn 0.3s ease-out;
}

.toast-content {
  padding: 1rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.toast-success {
  border-left: 4px solid #28a745;
}

.toast-error {
  border-left: 4px solid #dc3545;
}

.toast-warning {
  border-left: 4px solid #ffc107;
}

.toast-info {
  border-left: 4px solid #17a2b8;
}

.toast-close {
  background: none;
  border: none;
  font-size: 1.25rem;
  cursor: pointer;
  margin-left: auto;
  color: #6c757d;
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

/* Pagination */
.pagination {
  display: flex;
  list-style: none;
  padding: 0;
  margin: 0;
  gap: 0.25rem;
}

.page-item {
  margin: 0;
}

.page-link {
  padding: 0.5rem 0.75rem;
  border: 1px solid #dee2e6;
  background: white;
  color: var(--color-primary);
  cursor: pointer;
  border-radius: 4px;
  transition: all 0.3s;
}

.page-link:hover:not(:disabled) {
  background: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
}

.page-item.active .page-link {
  background: var(--color-primary);
  color: white;
  border-color: var(--color-primary);
}

.page-item.disabled .page-link {
  opacity: 0.5;
  cursor: not-allowed;
}

.error {
  color: #dc3545;
  padding: 1rem;
  background: #f8d7da;
  border-radius: 6px;
  margin-top: 1rem;
}
</style>
