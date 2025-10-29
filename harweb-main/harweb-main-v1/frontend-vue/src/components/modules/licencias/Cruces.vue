<template>
  <div class="container-fluid p-0 h-100">
    <!-- Header -->
    <div class="municipal-header p-3 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1"><i class="fas fa-map-signs me-2"></i>Gestión de Cruces de Calles</h1>
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
    <div class="municipal-controls border-bottom p-3">
      <div class="row g-3 align-items-center">
        <!-- Botones de acción -->
        <div class="col-lg-8">
          <div class="btn-group" role="group" aria-label="Acciones de cruces">
            <button type="button" class="btn municipal-group-btn" @click="nuevoCruce" :disabled="formActive">
              <i class="fas fa-plus me-1"></i> Nuevo
            </button>
            <button type="button" class="btn municipal-group-btn" @click="modificarCruce" :disabled="!selectedRow || formActive">
              <i class="fas fa-edit me-1"></i> Modificar
            </button>
            <button type="button" class="btn municipal-group-btn" @click="cancelarCruce" :disabled="!selectedRow || formActive">
              <i class="fas fa-trash me-1"></i> Cancelar
            </button>
            <button type="button" class="btn municipal-group-btn" @click="imprimirCruce" :disabled="!selectedRow">
              <i class="fas fa-print me-1"></i> Imprimir
            </button>
            <button type="button" class="btn municipal-group-btn" @click="cargarCruces" :disabled="formActive">
              <i class="fas fa-sync-alt me-1"></i> Actualizar
            </button>
            <button type="button" class="btn municipal-group-btn" @click="toggleSearchHelper">
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
            <span class="input-group-text municipal-counter">
              <strong>Total: {{ totalRegistros }}</strong>
            </span>
          </div>
        </div>
      </div>

      <!-- Componente de búsqueda avanzada -->
      <div v-if="showSearchHelper" class="row mt-3">
        <div class="col-12">
          <div class="card municipal-card">
            <div class="card-header municipal-card-header">
              <h5 class="mb-0 municipal-card-title"><i class="fas fa-search me-2"></i>Búsqueda Avanzada de Calles</h5>
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
      <div class="card municipal-card">
        <div class="card-body p-0">
          <div class="table-responsive" style="max-height: 600px; overflow-x: auto;">
            <table class="table table-hover table-sm mb-0" style="min-width: 800px;">
              <thead class="municipal-table-header sticky-top">
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
                    :class="{ 'municipal-selected': isSelected(row) }"
                    @click="selectRow(row)"
                    style="cursor: pointer;">
                  <td>{{ (currentPage - 1) * itemsPerPage + index + 1 }}</td>
                  <td><span class="municipal-badge">{{ row.id }}</span></td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.calle1">{{ row.calle1 }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.calle2">{{ row.calle2 }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.colonia">{{ row.colonia }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Paginación -->
        <div class="card-footer municipal-card-footer">
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
        baseUrl: 'http://localhost:8000/api/generic',
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
        const isSuccess = response.ok && data.eResponse && data.eResponse.success

        if (!isSuccess) {
          let errorMessage = 'Error en la API'
          if (data.eResponse && data.eResponse.message) {
            errorMessage = data.eResponse.message
          } else {
            errorMessage = `Error ${response.status}: ${response.statusText}`
          }
          throw new Error(errorMessage)
        }

        return data.eResponse.data.result
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
        if (data && Array.isArray(data) && data.length > 0) {
          this.allCruces = [...data] // Guardar copia de todos los datos
          this.cruces = data
          this.showToast('success', `${data.length} cruces cargados exitosamente`)
        } else {
          // No hay registros
          this.allCruces = []
          this.cruces = []
          this.showToast('info', 'No se encontraron cruces')
        }
      } catch (error) {
        console.error('Error loading cruces:', error)
        this.showToast('error', `Error al cargar cruces: ${error.message}`)
        this.cruces = []
        this.allCruces = []
      } finally {
        // Siempre desactivar el loading, sin importar si hay o no registros
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
/* Municipal Theme Integration */
.cruces-page {
  padding: 20px;
  background: white;
  min-height: 100vh;
  font-family: var(--font-municipal);
}

/* Municipal Header */
.municipal-header {
  background: var(--gradient-municipal);
  color: white;
  border-radius: 8px 8px 0 0;
  box-shadow: var(--shadow-md);
}

/* Encabezado */
h1 {
  color: white;
  margin-bottom: 10px;
  font-size: 24px;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-municipal);
}

.breadcrumb {
  color: rgba(255, 255, 255, 0.8);
  font-size: 14px;
  margin-bottom: 20px;
}

.breadcrumb a {
  color: rgba(255, 255, 255, 0.6);
  text-decoration: none;
}

.breadcrumb a:hover {
  color: rgba(255, 255, 255, 0.9);
}

/* Municipal Button Group - Bootstrap Integration */
.btn-group {
  box-shadow: 0 2px 4px rgba(234, 130, 21, 0.2);
  border-radius: 6px;
  overflow: hidden;
}

.municipal-group-btn {
  background: var(--municipal-primary) !important;
  color: white !important;
  border: 1px solid var(--municipal-primary) !important;
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-medium);
  padding: 10px 16px;
  font-size: 14px;
  transition: all 0.3s ease;
  border-radius: 0 !important;
  position: relative;
}

.municipal-group-btn:not(:disabled):hover {
  background: var(--municipal-secondary) !important;
  border-color: var(--municipal-secondary) !important;
  color: white !important;
  transform: translateY(-1px);
  z-index: 2;
  box-shadow: 0 4px 8px rgba(234, 130, 21, 0.3);
}

.municipal-group-btn:not(:disabled):active {
  background: var(--municipal-secondary) !important;
  transform: translateY(0);
}

.municipal-group-btn:disabled {
  background: rgba(234, 130, 21, 0.3) !important;
  border-color: rgba(234, 130, 21, 0.3) !important;
  color: rgba(255, 255, 255, 0.6) !important;
  cursor: not-allowed !important;
  transform: none !important;
}

/* Bootstrap btn-group integration with municipal colors */
.btn-group .municipal-group-btn + .municipal-group-btn {
  border-left: 1px solid rgba(255, 255, 255, 0.2) !important;
  margin-left: -1px;
}

.btn-group .municipal-group-btn:first-child {
  border-top-left-radius: 6px !important;
  border-bottom-left-radius: 6px !important;
}

.btn-group .municipal-group-btn:last-child {
  border-top-right-radius: 6px !important;
  border-bottom-right-radius: 6px !important;
}

/* Ensure Bootstrap doesn't override our styles */
.btn-group > .municipal-group-btn {
  position: relative;
  flex: 1 1 auto;
}

/* Municipal Search Section */
.municipal-counter {
  background: var(--gradient-municipal) !important;
  color: white !important;
  border: 1px solid var(--municipal-primary) !important;
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-bold);
  border-radius: 0 6px 6px 0;
}

.form-control {
  font-family: var(--font-municipal);
  border-color: var(--slate-300);
  transition: border-color 0.3s ease, box-shadow 0.3s ease;
}

.form-control:focus {
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
}

.form-select {
  font-family: var(--font-municipal);
  border-color: var(--slate-300);
}

.form-select:focus {
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
}

/* Municipal Table - Clean */
.municipal-table-header {
  background: var(--gradient-municipal) !important;
  color: white;
}

.municipal-table-header th {
  color: white !important;
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-bold);
  border: none;
}

.table {
  font-family: var(--font-municipal);
  border: none;
}

.table td {
  vertical-align: middle;
  font-size: 14px;
  border: none;
}

.table thead th {
  border: none;
}

.table tbody tr {
  transition: all 0.3s ease;
  border: none;
}

.table tbody tr:hover {
  background: rgba(234, 130, 21, 0.05) !important;
  transform: none;
}

.municipal-selected {
  background: rgba(234, 130, 21, 0.1) !important;
  border: none;
  border-left: 3px solid var(--municipal-primary);
}

.municipal-badge {
  background: var(--gradient-municipal);
  color: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-municipal);
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

/* Municipal Loading Overlay */
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
  backdrop-filter: blur(4px);
}

.loading-spinner {
  background: white;
  padding: 40px;
  border-radius: 16px;
  text-align: center;
  min-width: 240px;
  box-shadow: var(--shadow-xl);
  font-family: var(--font-municipal);
}

.spinner {
  width: 48px;
  height: 48px;
  border: 4px solid var(--slate-200);
  border-top: 4px solid var(--municipal-primary);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-spinner p {
  margin: 0;
  font-weight: var(--font-weight-bold);
  color: var(--slate-800);
  font-family: var(--font-municipal);
  font-size: 16px;
}

/* Municipal Toast Notifications */
.toast {
  position: fixed;
  top: 20px;
  right: 20px;
  min-width: 320px;
  max-width: 500px;
  border-radius: 12px;
  box-shadow: var(--shadow-lg);
  z-index: 1500;
  animation: slideIn 0.3s ease-out;
  font-family: var(--font-municipal);
  border: 1px solid;
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
  background: rgba(34, 197, 94, 0.1);
  border-color: var(--success-300);
  color: var(--success-800);
  backdrop-filter: blur(10px);
}

.toast-error {
  background: rgba(239, 68, 68, 0.1);
  border-color: var(--danger-300);
  color: var(--danger-800);
  backdrop-filter: blur(10px);
}

.toast-warning {
  background: rgba(245, 158, 11, 0.1);
  border-color: var(--warning-300);
  color: var(--warning-800);
  backdrop-filter: blur(10px);
}

.toast-info {
  background: rgba(59, 130, 246, 0.1);
  border-color: var(--info-300);
  color: var(--info-800);
  backdrop-filter: blur(10px);
}

.toast-content {
  display: flex;
  align-items: center;
  padding: 16px 20px;
  gap: 12px;
}

.toast-content i {
  font-size: 18px;
  flex-shrink: 0;
}

.toast-content span {
  flex: 1;
  font-weight: var(--font-weight-medium);
  font-family: var(--font-municipal);
  font-size: 14px;
}

.toast-close {
  background: rgba(0, 0, 0, 0.1);
  border: none;
  font-size: 16px;
  cursor: pointer;
  padding: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0.7;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.toast-close:hover {
  opacity: 1;
  background: rgba(0, 0, 0, 0.2);
  transform: scale(1.1);
}

/* Municipal SweetAlert Styles */
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
  backdrop-filter: blur(4px);
}

.sweet-alert-modal {
  background: white;
  border-radius: 16px;
  box-shadow: var(--shadow-xl);
  max-width: 420px;
  width: 90%;
  animation: sweetAlertScale 0.3s ease-out;
  font-family: var(--font-municipal);
  overflow: hidden;
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
  background: var(--success-600);
}

.sweet-alert-error {
  background: var(--danger-600);
}

.sweet-alert-warning {
  background: var(--warning-500);
  color: var(--slate-800) !important;
}

.sweet-alert-question {
  background: var(--municipal-primary);
}

.sweet-alert-info {
  background: var(--info-600);
}

.sweet-alert-title {
  font-size: 20px;
  font-weight: var(--font-weight-bold);
  color: var(--slate-800);
  margin: 0;
  font-family: var(--font-municipal);
}

.sweet-alert-body {
  padding: 0 24px 16px;
  text-align: center;
}

.sweet-alert-body p {
  color: var(--slate-600);
  font-size: 16px;
  line-height: 1.5;
  margin: 0;
  font-family: var(--font-municipal);
}

.sweet-alert-actions {
  padding: 16px 24px 24px;
  display: flex;
  gap: 12px;
  justify-content: center;
}

.sweet-alert-btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: var(--font-weight-medium);
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 90px;
  font-family: var(--font-municipal);
}

.sweet-alert-confirm {
  color: white;
}

.sweet-alert-confirm.sweet-alert-success {
  background: var(--success-600);
}

.sweet-alert-confirm.sweet-alert-error {
  background: var(--danger-600);
}

.sweet-alert-confirm.sweet-alert-warning {
  background: var(--warning-500);
  color: var(--slate-800);
}

.sweet-alert-confirm.sweet-alert-question {
  background: var(--gradient-municipal);
}

.sweet-alert-confirm.sweet-alert-info {
  background: var(--info-600);
}

.sweet-alert-cancel {
  background: var(--slate-200);
  color: var(--slate-600);
}

.sweet-alert-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.sweet-alert-confirm:hover {
  filter: brightness(1.1);
}

.sweet-alert-cancel:hover {
  background: var(--slate-300);
  color: var(--slate-700);
  transform: translateY(-1px);
}

/* Municipal Modal Overlay */
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
  backdrop-filter: blur(4px);
}

.modal-content {
  background: white;
  border-radius: 12px;
  box-shadow: var(--shadow-xl);
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  font-family: var(--font-municipal);
}

.modal-header {
  background: var(--gradient-municipal);
  padding: 16px 20px;
  border-bottom: none;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top-left-radius: 12px;
  border-top-right-radius: 12px;
}

.modal-header h2 {
  margin: 0;
  color: white;
  font-size: 18px;
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-bold);
}

.modal-body {
  padding: 20px;
}

.close-btn {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: white;
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: rotate(90deg);
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
  margin-bottom: 6px;
  font-weight: var(--font-weight-bold);
  color: var(--slate-700);
  font-family: var(--font-municipal);
  font-size: 14px;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--slate-300);
  border-radius: 6px;
  box-sizing: border-box;
  font-family: var(--font-municipal);
  font-size: 14px;
  transition: all 0.3s ease;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
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
  background: var(--gradient-municipal);
  color: white;
  border: none;
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-medium);
  padding: 10px 20px;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.form-actions button[type="submit"]:hover {
  background: var(--municipal-secondary);
  transform: translateY(-1px);
  box-shadow: var(--shadow-md);
}

.form-actions button[type="button"] {
  background: var(--slate-600);
  color: white;
  border: none;
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-medium);
  padding: 10px 20px;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.form-actions button[type="button"]:hover {
  background: var(--slate-700);
  transform: translateY(-1px);
  box-shadow: var(--shadow-md);
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

/* Municipal Pagination - Clean */
.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  padding: 16px 20px;
  border-radius: 12px;
  box-shadow: none;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 12px;
  font-family: var(--font-municipal);
  border: none;
}

.pagination button {
  padding: 8px 16px;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  background: white;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s ease;
  font-family: var(--font-municipal);
  color: #6c757d;
}

.pagination button:not(:disabled):hover {
  background: var(--municipal-primary);
  border-color: var(--municipal-primary);
  color: white;
}

.pagination button:disabled {
  background: #f8f9fa;
  color: #6c757d;
  cursor: not-allowed;
  border-color: #dee2e6;
}

.pagination span {
  color: var(--slate-700);
  font-size: 14px;
  font-weight: var(--font-weight-medium);
  font-family: var(--font-municipal);
}

.pagination select {
  padding: 8px 12px;
  border: 1px solid var(--slate-300);
  border-radius: 6px;
  font-size: 14px;
  background: white;
  font-family: var(--font-municipal);
  color: var(--slate-700);
  transition: all 0.3s ease;
}

.pagination select:focus {
  outline: none;
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.25);
}

/* Municipal Controls and Cards */
.municipal-controls {
  background: white;
  border: none !important;
}

.municipal-card {
  border: none;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: none;
  transition: all 0.3s ease;
  background: white;
}

.municipal-card:hover {
  box-shadow: none;
  transform: none;
}

.municipal-card-header {
  background: var(--gradient-municipal) !important;
  border-bottom: none !important;
  padding: 16px 20px;
}

.municipal-card-title {
  color: white !important;
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-bold);
  font-size: 16px;
}

.municipal-card-footer {
  background: white !important;
  border-top: none !important;
  padding: 16px 20px;
}

/* Error States */
.input-error {
  border-color: var(--danger-500) !important;
  box-shadow: 0 0 0 0.2rem rgba(239, 68, 68, 0.25) !important;
}

.field-error {
  color: var(--danger-600);
  font-size: 12px;
  margin-top: 4px;
  font-weight: var(--font-weight-medium);
  font-family: var(--font-municipal);
}

.required {
  color: var(--danger-600);
  font-weight: var(--font-weight-bold);
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