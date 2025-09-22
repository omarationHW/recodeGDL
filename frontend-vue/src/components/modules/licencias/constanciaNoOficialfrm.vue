<template>
  <div class="container-fluid p-0 h-100">
    <!-- Header -->
    <div class="bg-primary text-white p-3 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1">📋 Solicitud de Número Oficial</h1>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0 bg-transparent p-0">
              <li class="breadcrumb-item"><a href="#" class="text-white-50">Inicio</a></li>
              <li class="breadcrumb-item"><a href="#" class="text-white-50">Licencias</a></li>
              <li class="breadcrumb-item text-white active">Solicitud Número Oficial</li>
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
            <button type="button" class="btn btn-success" @click="nuevaSolicitud" :disabled="formActive || loading">
              <i class="fas fa-plus me-1"></i> Nueva
            </button>
            <button type="button" class="btn btn-warning" @click="modificarSolicitud" :disabled="!selectedRow || formActive || loading">
              <i class="fas fa-edit me-1"></i> Modificar
            </button>
            <button type="button" class="btn btn-danger" @click="cancelarSolicitud" :disabled="!selectedRow || formActive || loading">
              <i class="fas fa-times me-1"></i> Cancelar
            </button>
            <button type="button" class="btn btn-info" @click="imprimirSolicitud" :disabled="!selectedRow || loading">
              <i class="fas fa-print me-1"></i> Imprimir
            </button>
            <button type="button" class="btn btn-secondary" @click="cargarSolicitudes" :disabled="formActive || loading">
              <i class="fas fa-sync-alt me-1"></i> Actualizar
            </button>
          </div>
        </div>

        <!-- Búsqueda -->
        <div class="col-lg-4">
          <div class="input-group">
            <select v-model="searchType" @change="onSearchTypeChange" class="form-select" style="max-width: 140px;">
              <option value="propietario">Propietario</option>
              <option value="ubicacion">Ubicación</option>
            </select>
            <input
              v-model="searchValue"
              @input="buscar"
              placeholder="Buscar..."
              class="form-control"
            />
            <span class="input-group-text bg-primary text-white">
              <strong>Total: {{ totalRecords }}</strong>
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
            <table class="table table-hover table-sm mb-0" style="min-width: 1300px;">
              <thead class="table-dark sticky-top">
                <tr>
                  <th style="width: 60px;">#</th>
                  <th style="width: 80px;">Año</th>
                  <th style="width: 80px;">Folio</th>
                  <th style="width: 200px;">Propietario</th>
                  <th style="width: 250px;">Actividad</th>
                  <th style="width: 220px;">Ubicación</th>
                  <th style="width: 80px;">Zona</th>
                  <th style="width: 90px;">Subzona</th>
                  <th style="width: 100px;">Vigente</th>
                  <th style="width: 120px;">Fecha</th>
                  <th style="width: 120px;">Capturista</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in paginatedSolicitudes"
                    :key="row.axo + '-' + row.folio"
                    :class="{ 'table-primary': isSelected(row) }"
                    @click="selectRow(row)"
                    style="cursor: pointer;">
                  <td>{{ (currentPage - 1) * pageSize + index + 1 }}</td>
                  <td>{{ row.axo }}</td>
                  <td><span class="badge bg-secondary">{{ row.folio }}</span></td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.propietario">{{ row.propietario }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.actividad">{{ row.actividad }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.ubicacion">{{ row.ubicacion }}</td>
                  <td>{{ row.zona }}</td>
                  <td>{{ row.subzona }}</td>
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
              <nav v-if="totalPages > 1" aria-label="Paginación de solicitudes">
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
                <select v-model="pageSize" @change="updatePagination" class="form-select form-select-sm" style="width: auto;">
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

    <!-- Modal Popup para formulario -->
    <div v-if="formActive" class="modal-overlay" @click="cancelarEdicion">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h2>{{ formMode === 'create' ? 'Nueva Solicitud' : 'Modificar Solicitud' }}</h2>
          <button class="close-btn" @click="cancelarEdicion">&times;</button>
        </div>
        <form @submit.prevent="guardarSolicitud">
          <div class="form-grid">
            <div class="form-field">
              <label>Propietario:</label>
              <input v-model="form.propietario" required maxlength="50" />
            </div>
            <div class="form-field">
              <label>Actividad:</label>
              <input v-model="form.actividad" required maxlength="80" />
            </div>
            <div class="form-field">
              <label>Ubicación:</label>
              <input v-model="form.ubicacion" required maxlength="75" />
            </div>
            <div class="form-field">
              <label>Zona:</label>
              <input v-model.number="form.zona" type="number" required min="1" />
            </div>
            <div class="form-field">
              <label>Subzona:</label>
              <input v-model.number="form.subzona" type="number" required min="1" />
            </div>
          </div>
          <div class="modal-actions">
            <button type="submit" class="btn-primary">Aceptar</button>
            <button type="button" @click="cancelarEdicion" class="btn-secondary">Cancelar</button>
          </div>
        </form>
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

    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'SolicNoOficialPage',
  data() {
    return {
      solicitudes: [],
      selectedRow: null,
      formActive: false,
      formMode: 'create',
      loading: false,
      loadingMessage: 'Cargando...',
      form: {
        propietario: '',
        actividad: '',
        ubicacion: '',
        zona: '',
        subzona: ''
      },
      searchType: 'propietario',
      searchValue: '',
      error: '',
      allSolicitudes: [], // Cache de todos los datos
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
      // Paginación
      currentPage: 1,
      pageSize: 10
    };
  },
  computed: {
    // Datos paginados para mostrar en la tabla
    paginatedSolicitudes() {
      const start = (this.currentPage - 1) * this.pageSize;
      const end = start + this.pageSize;
      return this.solicitudes.slice(start, end);
    },
    // Total de páginas basado en el filtro actual
    totalPages() {
      return Math.ceil(this.solicitudes.length / this.pageSize);
    },
    // Total de registros basado en el filtro actual
    totalRecords() {
      return this.solicitudes.length;
    }
  },
  created() {
    this.cargarSolicitudes();
  },
  methods: {
    // Método helper para llamadas a la API
    async callAPI(operacion, parametros = []) {
      const requestBody = {
        eRequest: {
          Operacion: operacion,
          Base: 'padron_licencias',
          Parametros: parametros,
          Tenant: 'guadalajara'
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
        return data.eResponse || data
      } catch (error) {
        console.error('API Error:', error)
        throw error
      }
    },

    async cargarSolicitudes() {
      this.loading = true;
      this.loadingMessage = 'Cargando solicitudes...';
      this.error = '';
      this.selectedRow = null;

      try {
        const result = await this.callAPI('SP_solicnooficial_list');
        console.log('Raw API result:', result);

        // Manejar la respuesta de la misma forma que constanciafrm.vue
        this.allSolicitudes = result.data || result || [];
        this.solicitudes = [...this.allSolicitudes];

        console.log('Solicitudes loaded:', this.solicitudes.length);
      } catch (error) {
        console.error('Error loading solicitudes:', error);
        this.error = 'Error al cargar solicitudes: ' + error.message;
        this.allSolicitudes = [];
        this.solicitudes = [];
      } finally {
        this.loading = false;
      }
    },
    async buscar() {
      // Si no hay datos cargados, cargarlos primero
      if (this.allSolicitudes.length === 0) {
        await this.cargarSolicitudes();
        return;
      }

      // Filtrar datos en el frontend usando el cache
      if (!this.searchValue.trim()) {
        // Si no hay valor de búsqueda, mostrar todos
        this.solicitudes = [...this.allSolicitudes];
      } else {
        // Aplicar filtro local
        const searchLower = this.searchValue.toLowerCase().trim();

        this.solicitudes = this.allSolicitudes.filter(row => {
          if (this.searchType === 'propietario') {
            return (row.propietario || '').toLowerCase().includes(searchLower);
          } else if (this.searchType === 'ubicacion') {
            return (row.ubicacion || '').toLowerCase().includes(searchLower);
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
      return this.selectedRow && row.axo === this.selectedRow.axo && row.folio === this.selectedRow.folio;
    },
    nuevaSolicitud() {
      this.formActive = true;
      this.formMode = 'create';
      this.form = { propietario: '', actividad: '', ubicacion: '', zona: '', subzona: '' };
      this.selectedRow = null;
    },
    modificarSolicitud() {
      if (!this.selectedRow) return;
      this.formActive = true;
      this.formMode = 'update';
      this.form = {
        propietario: this.selectedRow.propietario,
        actividad: this.selectedRow.actividad,
        ubicacion: this.selectedRow.ubicacion,
        zona: this.selectedRow.zona,
        subzona: this.selectedRow.subzona
      };
    },
    cancelarEdicion() {
      this.formActive = false;
      this.form = { propietario: '', actividad: '', ubicacion: '', zona: '', subzona: '' };
    },
    async guardarSolicitud() {
      this.error = '';

      // Validar campos obligatorios
      const missingFields = [];
      if (!this.form.propietario) missingFields.push('Propietario');
      if (!this.form.actividad) missingFields.push('Actividad');
      if (!this.form.ubicacion) missingFields.push('Ubicación');
      if (!this.form.zona) missingFields.push('Zona');
      if (!this.form.subzona) missingFields.push('Subzona');

      if (missingFields.length > 0) {
        this.error = `Los siguientes campos son obligatorios: ${missingFields.join(', ')}`;
        return;
      }

      // Confirmación antes de guardar
      const mensaje = this.formMode === 'create'
        ? '¿Desea crear esta nueva solicitud?'
        : '¿Desea actualizar esta solicitud?';
      const shouldProceed = await this.showSweetAlert({
        type: this.formMode === 'create' ? 'question' : 'warning',
        title: this.formMode === 'create' ? '¿Crear Solicitud?' : '¿Actualizar Solicitud?',
        text: mensaje,
        showCancelButton: true,
        confirmButtonText: this.formMode === 'create' ? 'Sí, crear' : 'Sí, actualizar',
        cancelButtonText: 'Cancelar'
      })

      if (!shouldProceed) return

      try {
        const operacion = this.formMode === 'create' ? 'SP_solicnooficial_create' : 'SP_solicnooficial_update';

        const parametros = this.formMode === 'create' ? [
          { nombre: 'p_propietario', valor: this.form.propietario.substring(0, 50), tipo: 'varchar' },
          { nombre: 'p_actividad', valor: this.form.actividad.substring(0, 80), tipo: 'varchar' },
          { nombre: 'p_ubicacion', valor: this.form.ubicacion.substring(0, 75), tipo: 'varchar' },
          { nombre: 'p_zona', valor: parseInt(this.form.zona), tipo: 'integer' },
          { nombre: 'p_subzona', valor: parseInt(this.form.subzona), tipo: 'integer' },
          { nombre: 'p_capturista', valor: this.apiConfig.capturista, tipo: 'varchar' },
          { nombre: 'p_feccap', valor: new Date().toISOString().split('T')[0], tipo: 'date' }
        ] : [
          { nombre: 'p_axo', valor: this.selectedRow.axo, tipo: 'integer' },
          { nombre: 'p_folio', valor: this.selectedRow.folio, tipo: 'integer' },
          { nombre: 'p_propietario', valor: this.form.propietario.substring(0, 50), tipo: 'varchar' },
          { nombre: 'p_actividad', valor: this.form.actividad.substring(0, 80), tipo: 'varchar' },
          { nombre: 'p_ubicacion', valor: this.form.ubicacion.substring(0, 75), tipo: 'varchar' },
          { nombre: 'p_zona', valor: parseInt(this.form.zona), tipo: 'integer' },
          { nombre: 'p_subzona', valor: parseInt(this.form.subzona), tipo: 'integer' }
        ];

        await this.callAPI(operacion, parametros);
        this.cargarSolicitudes();
        this.formActive = false;
      } catch (error) {
        this.error = error.message;
      }
    },
    async cancelarSolicitud() {
      if (!this.selectedRow) return;
      const shouldCancel = await this.showSweetAlert({
        type: 'warning',
        title: '¿Cancelar Solicitud?',
        text: '¿Está seguro de cancelar esta solicitud?',
        showCancelButton: true,
        confirmButtonText: 'Sí, cancelar',
        cancelButtonText: 'No'
      })

      if (!shouldCancel) return

      try {
        const parametros = [
          { nombre: 'p_axo', valor: this.selectedRow.axo, tipo: 'integer' },
          { nombre: 'p_folio', valor: this.selectedRow.folio, tipo: 'integer' }
        ];

        await this.callAPI('SP_solicnooficial_cancel', parametros);
        this.cargarSolicitudes();
      } catch (error) {
        this.error = error.message;
      }
    },
    async imprimirSolicitud() {
      if (!this.selectedRow) return;

      try {
        const parametros = [
          { nombre: 'p_axo', valor: this.selectedRow.axo, tipo: 'integer' },
          { nombre: 'p_folio', valor: this.selectedRow.folio, tipo: 'integer' }
        ];

        const data = await this.callAPI('SP_solicnooficial_print', parametros);
        alert('Funcionalidad de impresión lista para implementar');
      } catch (error) {
        this.error = error.message;
      }
    },
    onSearchTypeChange() {
      this.searchValue = '';
      this.buscar();
    },
    updatePagination() {
      // Resetear a página 1 cuando cambie el tamaño de página
      this.currentPage = 1;
    },
    formatDate(date) {
      if (!date) return ''
      try {
        return new Date(date).toLocaleDateString('es-ES')
      } catch {
        return date
      }
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
    }
  }
};
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
  z-index: 3000;
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

/* Error messages */
.error {
  background: #f8d7da;
  color: #721c24;
  padding: 12px 16px;
  border-radius: 4px;
  border: 1px solid #f5c6cb;
  margin-bottom: 20px;
  font-size: 14px;
}

/* Modal Overlay */
.modal-overlay {
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
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 20px 0;
  border-bottom: 1px solid #e9ecef;
  margin-bottom: 20px;
}

.modal-header h2 {
  margin: 0;
  color: #2c3e50;
  font-size: 18px;
  font-weight: 600;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #6c757d;
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
  background: #f8f9fa;
  color: #495057;
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

.form-field input {
  padding: 10px 12px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.2s;
}

.form-field input:focus {
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
  .solic-no-oficial-page {
    padding: 10px;
  }

  .actions {
    flex-direction: column;
  }

  .busqueda {
    flex-direction: column;
    align-items: stretch;
  }

  .solic-table {
    font-size: 12px;
  }

  .solic-table th, .solic-table td {
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

.sweet-alert-question {
  background: #6f42c1;
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

.sweet-alert-confirm.sweet-alert-question {
  background: #6f42c1;
}

.sweet-alert-confirm.sweet-alert-question:hover {
  background: #5a32a3;
  transform: translateY(-1px);
}
</style>
