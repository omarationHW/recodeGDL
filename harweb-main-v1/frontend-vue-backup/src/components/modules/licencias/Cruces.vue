<template>
  <div class="container-fluid p-0 h-100">
    <!-- Header -->
    <div class="bg-primary text-white p-3 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1">🛣️ Gestión de Cruces de Calles</h1>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0 bg-transparent p-0">
              <li class="breadcrumb-item"><a href="#" class="text-white-50">Inicio</a></li>
              <li class="breadcrumb-item"><a href="#" class="text-white-50">Licencias</a></li>
              <li class="breadcrumb-item text-white active">Cruces</li>
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
            <button type="button" class="btn btn-success" @click="nuevoCruce" :disabled="formActive">
              <i class="fas fa-plus me-1"></i> Nuevo
            </button>
            <button type="button" class="btn btn-warning" @click="modificarCruce" :disabled="!selectedRow || formActive">
              <i class="fas fa-edit me-1"></i> Modificar
            </button>
            <button type="button" class="btn btn-danger" @click="cancelarCruce" :disabled="!selectedRow || formActive">
              <i class="fas fa-trash me-1"></i> Cancelar
            </button>
            <button type="button" class="btn btn-info" @click="imprimirCruce" :disabled="!selectedRow">
              <i class="fas fa-print me-1"></i> Imprimir
            </button>
            <button type="button" class="btn btn-secondary" @click="cargarCruces" :disabled="formActive">
              <i class="fas fa-sync-alt me-1"></i> Actualizar
            </button>
            <button type="button" class="btn btn-dark" @click="toggleSearchHelper">
              <i class="fas fa-search me-1"></i> {{ showSearchHelper ? 'Ocultar' : 'Búsqueda Avanzada' }}
            </button>
          </div>
        </div>

        <!-- Búsqueda -->
        <div class="col-lg-4">
          <div class="input-group">
            <select v-model="searchType" @change="onSearchTypeChange" class="form-select" style="max-width: 140px;">
              <option value="calle1">Calle 1</option>
              <option value="calle2">Calle 2</option>
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

      <!-- Componente de búsqueda avanzada -->
      <div v-if="showSearchHelper" class="row mt-3">
        <div class="col-12">
          <div class="card">
            <div class="card-header">
              <h5 class="mb-0"><i class="fas fa-search me-2"></i>Búsqueda Avanzada de Calles</h5>
            </div>
            <div class="card-body">
              <CrucesSearchHelper
                :apiConfig="apiConfig"
                @calles-selected="onCallesSelected"
              />
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla -->
    <div class="flex-grow-1 p-3">
      <div class="card">
        <div class="card-body p-0">
          <div class="table-responsive" style="max-height: 600px; overflow-x: auto;">
            <table class="table table-hover table-sm mb-0" style="min-width: 800px;">
              <thead class="table-dark sticky-top">
                <tr>
                  <th style="width: 60px;">#</th>
                  <th style="width: 80px;">ID</th>
                  <th style="width: 250px;">Calle 1</th>
                  <th style="width: 250px;">Calle 2</th>
                  <th style="width: 200px;">Colonia</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in paginatedCruces"
                    :key="row.id"
                    :class="{ 'table-primary': isSelected(row) }"
                    @click="selectRow(row)"
                    style="cursor: pointer;">
                  <td>{{ (currentPage - 1) * itemsPerPage + index + 1 }}</td>
                  <td><span class="badge bg-secondary">{{ row.id }}</span></td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.calle1">{{ row.calle1 }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.calle2">{{ row.calle2 }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.colonia">{{ row.colonia }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Paginación -->
        <div class="card-footer">
          <div class="row align-items-center">
            <div class="col-sm-6">
              <nav v-if="totalPages > 1" aria-label="Paginación de cruces">
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
          <h2>{{ formMode === 'create' ? 'Nuevo Cruce' : 'Modificar Cruce' }}</h2>
          <button type="button" class="close-btn" @click="cancelarEdicion">&times;</button>
        </div>

        <div class="modal-body">
          <form @submit.prevent="guardarCruce">
            <div class="form-row">
              <div class="form-group">
                <label>Calle 1: <span class="required">*</span></label>
                <input
                  v-model="form.calle1"
                  required
                  maxlength="255"
                  :class="{ 'input-error': validationErrors.calle1 }"
                  @blur="validateField('calle1')"
                />
                <div v-if="validationErrors.calle1" class="field-error">
                  {{ validationErrors.calle1 }}
                </div>
              </div>
              <div class="form-group">
                <label>Calle 2: <span class="required">*</span></label>
                <input
                  v-model="form.calle2"
                  required
                  maxlength="255"
                  :class="{ 'input-error': validationErrors.calle2 }"
                  @blur="validateField('calle2')"
                />
                <div v-if="validationErrors.calle2" class="field-error">
                  {{ validationErrors.calle2 }}
                </div>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group full-width">
                <label>Colonia: <span class="required">*</span></label>
                <input
                  v-model="form.colonia"
                  required
                  maxlength="255"
                  :class="{ 'input-error': validationErrors.colonia }"
                  @blur="validateField('colonia')"
                />
                <div v-if="validationErrors.colonia" class="field-error">
                  {{ validationErrors.colonia }}
                </div>
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
  </div>
</template>

<script>
import CrucesSearchHelper from './crucesSearchHelper.vue';

export default {
  name: 'CrucesPage',
  components: {
    CrucesSearchHelper
  },
  data() {
    return {
      // Configuración de la API
      apiConfig: {
        baseUrl: 'http://localhost:8080/api/generic',
        tenant: 'guadalajara',
        database: 'padron_licencias',
        capturista: 'usr_web'
      },
      cruces: [],
      selectedRow: null,
      formActive: false,
      formMode: 'create',
      form: {
        calle1: '',
        calle2: '',
        colonia: ''
      },
      searchType: 'calle1',
      searchValue: '',
      error: '',
      allCruces: [], // Cache de todos los datos
      showSearchHelper: false,
      // Paginación
      currentPage: 1,
      itemsPerPage: 25,
      // Loading state
      loading: false,
      loadingMessage: 'Cargando...',
      // Validaciones
      validationErrors: {},
      // Toast notifications
      toast: {
        show: false,
        type: 'success', // success, error, warning, info
        message: '',
        timeout: null
      },
      // SweetAlert
      sweetAlert: {
        show: false,
        type: 'info', // success, error, warning, info, question
        title: '',
        text: '',
        showCancelButton: false,
        confirmButtonText: 'Aceptar',
        cancelButtonText: 'Cancelar',
        backdrop: true,
        onConfirm: null,
        onCancel: null
      }
    };
  },
  computed: {
    // Datos paginados para mostrar en la tabla
    paginatedCruces() {
      const start = (this.currentPage - 1) * this.itemsPerPage;
      const end = start + this.itemsPerPage;
      return this.cruces.slice(start, end);
    },
    // Total de páginas basado en el filtro actual
    totalPages() {
      return Math.ceil(this.cruces.length / this.itemsPerPage);
    },
    // Total de registros basado en el filtro actual
    totalRegistros() {
      return this.cruces.length;
    }
  },
  created() {
    this.cargarCruces();
  },
  methods: {
    // Método helper para llamadas a la API con manejo mejorado de errores
    async callAPI(operacion, parametros = [], base = null) {
      const eRequest = {
        Operacion: operacion,
        Base: base || this.apiConfig.database,
        Parametros: parametros,
        Tenant: this.apiConfig.tenant
      }

      try {
        const response = await fetch(this.apiConfig.baseUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest })
        })

        console.log('Response status:', response.status)
        const data = await response.json()
        console.log('Response from API:', data)

        // Determinar si fue exitoso basado en status
        const isSuccess = response.ok && data.success

        if (!isSuccess) {
          let errorMessage = 'Error en la API'
          if (data.message) {
            errorMessage = data.message
          } else {
            errorMessage = `Error ${response.status}: ${response.statusText}`
          }
          throw new Error(errorMessage)
        }

        return data.data
      } catch (error) {
        console.error('API Error:', error)
        throw error
      }
    },

    async cargarCruces() {
      this.loading = true
      this.loadingMessage = 'Cargando cruces de calles...'
      this.selectedRow = null

      try {
        const data = await this.callAPI('sp_cruces_list')

        // El SP retorna filas directamente en data
        if (data && Array.isArray(data)) {
          this.allCruces = [...data] // Guardar copia de todos los datos
          this.cruces = data
          this.showToast('success', `${data.length} cruces cargados exitosamente`)
        } else {
          this.allCruces = []
          this.cruces = []
          this.showToast('info', 'No se encontraron cruces')
        }
      } catch (error) {
        console.error('Error loading cruces:', error)
        await this.showSweetAlert({
          type: 'error',
          title: 'Error al Cargar',
          text: `Error al cargar cruces: ${error.message}`,
          confirmButtonText: 'Entendido'
        })
        this.cruces = []
      } finally {
        this.loading = false
      }
    },

    async buscar() {
      // Si no hay datos cargados, cargarlos primero
      if (this.allCruces.length === 0) {
        await this.cargarCruces();
        return;
      }

      // Filtrar datos en el frontend usando el cache
      if (!this.searchValue.trim()) {
        // Si no hay valor de búsqueda, mostrar todos
        this.cruces = [...this.allCruces];
      } else {
        // Aplicar filtro local
        const searchLower = this.searchValue.toLowerCase().trim();

        this.cruces = this.allCruces.filter(row => {
          if (this.searchType === 'calle1') {
            return (row.calle1 || '').toLowerCase().includes(searchLower);
          } else if (this.searchType === 'calle2') {
            return (row.calle2 || '').toLowerCase().includes(searchLower);
          } else if (this.searchType === 'colonia') {
            return (row.colonia || '').toLowerCase().includes(searchLower);
          }
          return false;
        });
      }
      // Resetear a página 1 después de filtrar
      this.currentPage = 1;
    },

    selectRow(row) {
      this.selectedRow = row;
      this.formActive = false;
    },

    isSelected(row) {
      return this.selectedRow && row.id === this.selectedRow.id;
    },

    nuevoCruce() {
      this.formActive = true;
      this.formMode = 'create';
      this.form = { calle1: '', calle2: '', colonia: '' };
      this.selectedRow = null;
    },

    modificarCruce() {
      if (!this.selectedRow) return;
      this.formActive = true;
      this.formMode = 'update';
      this.form = {
        calle1: this.selectedRow.calle1,
        calle2: this.selectedRow.calle2,
        colonia: this.selectedRow.colonia
      };
    },

    cancelarEdicion() {
      this.formActive = false;
      this.form = { calle1: '', calle2: '', colonia: '' };
    },

    async guardarCruce() {
      // Validar formulario
      if (!this.validateForm()) {
        this.showToast('warning', 'Por favor corrige los errores en el formulario')
        return
      }

      // Confirmación con SweetAlert
      const mensaje = this.formMode === 'create'
        ? `¿Está seguro de crear el cruce "${this.form.calle1}" con "${this.form.calle2}"?`
        : `¿Está seguro de actualizar este cruce?`

      const shouldProceed = await this.showSweetAlert({
        type: this.formMode === 'create' ? 'question' : 'warning',
        title: this.formMode === 'create' ? '¿Crear Cruce?' : '¿Actualizar Cruce?',
        text: mensaje,
        showCancelButton: true,
        confirmButtonText: this.formMode === 'create' ? 'Sí, crear' : 'Sí, actualizar',
        cancelButtonText: 'Cancelar'
      })

      if (!shouldProceed) return

      this.loading = true
      this.loadingMessage = this.formMode === 'create' ? 'Creando cruce...' : 'Actualizando cruce...'

      try {
        const operacion = this.formMode === 'create' ? 'SP_CRUCES_CREATE' : 'SP_CRUCES_UPDATE'

        const parametros = this.formMode === 'create' ? [
          { nombre: 'p_calle1', valor: this.form.calle1.substring(0, 255), tipo: 'varchar' },
          { nombre: 'p_calle2', valor: this.form.calle2.substring(0, 255), tipo: 'varchar' },
          { nombre: 'p_colonia', valor: this.form.colonia.substring(0, 255), tipo: 'varchar' },
          { nombre: 'p_capturista', valor: this.apiConfig.capturista, tipo: 'varchar' },
          { nombre: 'p_feccap', valor: new Date().toISOString().split('T')[0], tipo: 'date' }
        ] : [
          { nombre: 'p_id', valor: this.selectedRow.id, tipo: 'integer' },
          { nombre: 'p_calle1', valor: this.form.calle1.substring(0, 255), tipo: 'varchar' },
          { nombre: 'p_calle2', valor: this.form.calle2.substring(0, 255), tipo: 'varchar' },
          { nombre: 'p_colonia', valor: this.form.colonia.substring(0, 255), tipo: 'varchar' }
        ]

        await this.callAPI(operacion, parametros)

        // Mostrar alerta de éxito
        await this.showSweetAlert({
          type: 'success',
          title: '¡Éxito!',
          text: this.formMode === 'create' ? 'Cruce creado exitosamente' : 'Cruce actualizado exitosamente',
          confirmButtonText: 'Entendido'
        })

        this.formActive = false
        await this.cargarCruces()
      } catch (error) {
        await this.showSweetAlert({
          type: 'error',
          title: 'Error al Guardar',
          text: `Error: ${error.message}`,
          confirmButtonText: 'Entendido'
        })
      } finally {
        this.loading = false
      }
    },

    async cancelarCruce() {
      if (!this.selectedRow) return

      const cruceInfo = `${this.selectedRow.calle1} con ${this.selectedRow.calle2}`
      const shouldDelete = await this.showSweetAlert({
        type: 'warning',
        title: '¿Cancelar Cruce?',
        text: `¿Está seguro de cancelar el cruce "${cruceInfo}"? Esta acción no se puede deshacer.`,
        showCancelButton: true,
        confirmButtonText: 'Sí, cancelar',
        cancelButtonText: 'No'
      })

      if (!shouldDelete) return

      this.loading = true
      this.loadingMessage = 'Cancelando cruce...'

      try {
        const parametros = [
          { nombre: 'p_id', valor: this.selectedRow.id, tipo: 'integer' }
        ]

        await this.callAPI('SP_CRUCES_CANCEL', parametros)

        await this.showSweetAlert({
          type: 'success',
          title: '¡Éxito!',
          text: 'Cruce cancelado exitosamente',
          confirmButtonText: 'Entendido'
        })

        this.selectedRow = null
        await this.cargarCruces()
      } catch (error) {
        await this.showSweetAlert({
          type: 'error',
          title: 'Error al Cancelar',
          text: `Error: ${error.message}`,
          confirmButtonText: 'Entendido'
        })
      } finally {
        this.loading = false
      }
    },

    async imprimirCruce() {
      if (!this.selectedRow) return

      this.loading = true
      this.loadingMessage = 'Preparando impresión...'

      try {
        const parametros = [
          { nombre: 'p_id', valor: this.selectedRow.id, tipo: 'integer' }
        ]

        const data = await this.callAPI('SP_CRUCES_PRINT', parametros)

        if (data && data.pdf_url) {
          window.open(data.pdf_url, '_blank')
        } else {
          await this.showSweetAlert({
            type: 'info',
            title: 'Imprimir',
            text: 'Documento listo para imprimir',
            confirmButtonText: 'Entendido'
          })
          window.print()
        }
      } catch (error) {
        await this.showSweetAlert({
          type: 'error',
          title: 'Error al Imprimir',
          text: `Error: ${error.message}`,
          confirmButtonText: 'Entendido'
        })
      } finally {
        this.loading = false
      }
    },

    onSearchTypeChange() {
      this.searchValue = '';
      this.buscar();
    },

    // Métodos de paginación
    previousPage() {
      if (this.currentPage > 1) {
        this.currentPage--;
      }
    },

    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++;
      }
    },

    onItemsPerPageChange() {
      // Resetear a página 1 cuando cambie el tamaño de página
      this.currentPage = 1;
    },

    toggleSearchHelper() {
      this.showSearchHelper = !this.showSearchHelper;
    },

    onCallesSelected(datosCalles) {
      // Rellenar el formulario con las calles seleccionadas
      this.form.calle1 = datosCalles.nombreCompleto1;
      this.form.calle2 = datosCalles.nombreCompleto2;
      this.form.colonia = ''; // Usuario debe ingresar la colonia

      // Abrir el formulario en modo crear
      this.nuevoCruce();

      // Ocultar el helper de búsqueda
      this.showSearchHelper = false;
    },

    // Métodos de validación
    validateField(fieldName) {
      this.validationErrors = { ...this.validationErrors }
      delete this.validationErrors[fieldName]

      switch (fieldName) {
        case 'calle1':
          if (!this.form.calle1 || this.form.calle1.trim().length < 2) {
            this.validationErrors.calle1 = 'Calle 1 es obligatoria (mín. 2 caracteres)'
          }
          break
        case 'calle2':
          if (!this.form.calle2 || this.form.calle2.trim().length < 2) {
            this.validationErrors.calle2 = 'Calle 2 es obligatoria (mín. 2 caracteres)'
          }
          break
        case 'colonia':
          if (!this.form.colonia || this.form.colonia.trim().length < 2) {
            this.validationErrors.colonia = 'Colonia es obligatoria (mín. 2 caracteres)'
          }
          break
      }
    },

    validateForm() {
      this.validationErrors = {}
      this.validateField('calle1')
      this.validateField('calle2')
      this.validateField('colonia')
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
        question: 'fas fa-question',
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
    }
  }
};
</script>

<style scoped>
/* Estilo base del módulo */
.cruces-page {
  padding: 20px;
  background: #f8f9fa;
  min-height: 100vh;
}

/* Encabezado */
h1 {
  color: #2c3e50;
  margin-bottom: 10px;
  font-size: 24px;
  font-weight: 600;
}

.breadcrumb {
  color: #6c757d;
  font-size: 14px;
  margin-bottom: 20px;
}

/* Botones de acción */
.actions {
  margin-bottom: 20px;
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.actions button {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
}

.actions button:not(:disabled) {
  background: #007bff;
  color: white;
}

.actions button:not(:disabled):hover {
  background: #0056b3;
  transform: translateY(-1px);
}

.actions button:disabled {
  background: #e9ecef;
  color: #6c757d;
  cursor: not-allowed;
}

.btn-search {
  background: #17a2b8 !important;
  color: white !important;
}

.btn-search:hover {
  background: #138496 !important;
}

/* Sección de búsqueda */
.busqueda {
  background: white;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.busqueda label {
  font-weight: 500;
  color: #495057;
}

.busqueda select, .busqueda input {
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
}

.busqueda select {
  min-width: 120px;
}

.busqueda input {
  min-width: 200px;
  flex: 1;
}

/* Tabla */
.cruces-table {
  width: 100%;
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  border-collapse: collapse;
  margin-bottom: 20px;
}

.cruces-table th {
  background: #343a40;
  color: white;
  padding: 12px 8px;
  text-align: left;
  font-weight: 600;
  font-size: 13px;
  border-bottom: 2px solid #dee2e6;
}

.cruces-table td {
  padding: 10px 8px;
  border-bottom: 1px solid #dee2e6;
  font-size: 13px;
}

.cruces-table tbody tr {
  cursor: pointer;
  transition: background-color 0.2s;
}

.cruces-table tbody tr:hover {
  background: #f8f9fa;
}

.cruces-table tbody tr.selected {
  background: #e3f2fd !important;
  border-left: 4px solid #2196f3;
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

/* SweetAlert Styles */
.sweet-alert-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 2000;
}

.sweet-alert-modal {
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  max-width: 400px;
  width: 90%;
  animation: sweetAlertScale 0.3s ease-out;
}

@keyframes sweetAlertScale {
  from {
    transform: scale(0.7);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

.sweet-alert-header {
  padding: 24px 24px 16px;
  text-align: center;
}

.sweet-alert-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  margin: 0 auto 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
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
  color: #333 !important;
}

.sweet-alert-question {
  background: #17a2b8;
}

.sweet-alert-info {
  background: #6c757d;
}

.sweet-alert-title {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

.sweet-alert-body {
  padding: 0 24px 16px;
  text-align: center;
}

.sweet-alert-body p {
  color: #666;
  font-size: 16px;
  line-height: 1.5;
  margin: 0;
}

.sweet-alert-actions {
  padding: 16px 24px 24px;
  display: flex;
  gap: 12px;
  justify-content: center;
}

.sweet-alert-btn {
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  min-width: 80px;
}

.sweet-alert-confirm {
  color: white;
}

.sweet-alert-confirm.sweet-alert-success {
  background: #28a745;
}

.sweet-alert-confirm.sweet-alert-error {
  background: #dc3545;
}

.sweet-alert-confirm.sweet-alert-warning {
  background: #ffc107;
  color: #333;
}

.sweet-alert-confirm.sweet-alert-question {
  background: #17a2b8;
}

.sweet-alert-confirm.sweet-alert-info {
  background: #6c757d;
}

.sweet-alert-cancel {
  background: #e9ecef;
  color: #6c757d;
}

.sweet-alert-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.sweet-alert-confirm:hover {
  filter: brightness(1.1);
}

.sweet-alert-cancel:hover {
  background: #dee2e6;
  color: #495057;
}

/* Modal Overlay - exact match with constanciafrm */
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

.modal-body {
  padding: 20px;
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
  border-radius: 50%;
  transition: all 0.2s;
}

.close-btn:hover {
  background: #e9ecef;
  color: #000;
}

/* Form styling - exact match with constanciafrm */
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
  border-color: #0056b3;
}

.form-actions button[type="button"] {
  background: #6c757d;
  color: white;
  border-color: #6c757d;
}

.form-actions button[type="button"]:hover {
  background: #5a6268;
  border-color: #5a6268;
}

.form-actions button:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  padding: 0 20px;
  margin-bottom: 20px;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.form-field label {
  font-weight: 500;
  color: #495057;
  font-size: 14px;
}

.form-field input, .form-field select {
  padding: 10px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.2s;
}

.form-field input:focus, .form-field select:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  padding: 0 20px 20px;
}

.btn-primary {
  background: #007bff;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
}

.btn-primary:hover {
  background: #0056b3;
}

.btn-secondary {
  background: #6c757d;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
}

.btn-secondary:hover {
  background: #5a6268;
}

/* Paginación */
.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 10px;
}

.pagination button {
  padding: 8px 16px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  background: white;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s;
}

.pagination button:not(:disabled):hover {
  background: #e9ecef;
  border-color: #adb5bd;
}

.pagination button:disabled {
  background: #f8f9fa;
  color: #6c757d;
  cursor: not-allowed;
  border-color: #e9ecef;
}

.pagination span {
  color: #495057;
  font-size: 14px;
  font-weight: 500;
}

.pagination select {
  padding: 6px 10px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
  background: white;
}

/* Responsive */
@media (max-width: 768px) {
  .cruces-page {
    padding: 10px;
  }

  .actions {
    flex-direction: column;
  }

  .busqueda {
    flex-direction: column;
    align-items: stretch;
  }

  .cruces-table {
    font-size: 12px;
  }

  .cruces-table th, .cruces-table td {
    padding: 6px 4px;
  }

  .form-grid {
    grid-template-columns: 1fr;
  }

  .modal-content {
    width: 95%;
    margin: 10px;
  }

  .pagination {
    flex-direction: column;
    align-items: stretch;
    gap: 10px;
  }

  .pagination button, .pagination span, .pagination select {
    text-align: center;
  }
}
</style>