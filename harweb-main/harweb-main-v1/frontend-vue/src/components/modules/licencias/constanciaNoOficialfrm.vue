<template>
  <div class="municipal-form-page">
    <!-- Header -->
    <div class="municipal-header">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1"><i class="fas fa-file-alt me-2"></i>Solicitud de Número Oficial</h1>
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
    <div class="municipal-card mb-3">
      <div class="municipal-card-body">
      <div class="row g-3 align-items-center">
        <!-- Botones de acción -->
        <div class="col-lg-8">
          <div class="municipal-group-btn" role="group">
            <button type="button" class="btn-municipal-primary" @click="nuevaConstancia" :disabled="formActive || loading">
              <i class="fas fa-plus me-1"></i> Nueva
            </button>
            <button type="button" class="btn-municipal-primary" @click="modificarConstancia" :disabled="!selectedRow || formActive || loading">
              <i class="fas fa-edit me-1"></i> Modificar
            </button>
            <button type="button" class="btn-municipal-secondary" @click="cancelarConstancia" :disabled="!selectedRow || formActive || loading">
              <i class="fas fa-times me-1"></i> Cancelar
            </button>
            <button type="button" class="btn-municipal-secondary" @click="imprimirConstancia" :disabled="!selectedRow || loading">
              <i class="fas fa-print me-1"></i> Imprimir
            </button>
            <button type="button" class="btn-municipal-secondary" @click="cargarConstancias" :disabled="formActive || loading">
              <i class="fas fa-sync-alt me-1"></i> Actualizar
            </button>
          </div>
        </div>

        <!-- Búsqueda -->
        <div class="col-lg-4">
          <div class="input-group">
            <select v-model="searchType" @change="onSearchTypeChange" class="municipal-form-control" style="max-width: 140px;">
              <option value="propietario">Propietario</option>
              <option value="ubicacion">Ubicación</option>
            </select>
            <input
              v-model="searchValue"
              @input="buscar"
              placeholder="Buscar..."
              class="municipal-form-control"
            />
            <span class="input-group-text municipal-badge municipal-badge-primary">
              <strong>Total: {{ totalRecords }}</strong>
            </span>
          </div>
        </div>
      </div>
    </div>
    <!-- Tabla -->
    <div class="flex-grow-1">
      <div class="municipal-card">
        <div class="municipal-card-body p-0">
          <div class="table-responsive" style="max-height: 600px; overflow-x: auto;">
            <table class="municipal-table table-sm mb-0" style="min-width: 1300px;">
              <thead class="municipal-table-header sticky-top">
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
                  <td><span class="municipal-badge municipal-badge-secondary">{{ row.folio }}</span></td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.propietario">{{ row.propietario }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.actividad">{{ row.actividad }}</td>
                  <td style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" :title="row.ubicacion">{{ row.ubicacion }}</td>
                  <td>{{ row.zona }}</td>
                  <td>{{ row.subzona }}</td>
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
                <select v-model="pageSize" @change="updatePagination" class="municipal-form-control form-select-sm" style="width: auto;">
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
              <label class="municipal-form-label">Propietario:</label>
              <input v-model="form.propietario" class="municipal-form-control" required maxlength="50" />
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Actividad:</label>
              <input v-model="form.actividad" class="municipal-form-control" required maxlength="80" />
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Ubicación:</label>
              <input v-model="form.ubicacion" class="municipal-form-control" required maxlength="75" />
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Zona:</label>
              <input v-model.number="form.zona" class="municipal-form-control" type="number" required min="1" />
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Subzona:</label>
              <input v-model.number="form.subzona" class="municipal-form-control" type="number" required min="1" />
            </div>
          </div>
          <div class="modal-actions">
            <button type="submit" class="btn-municipal-primary">
              <i class="fas fa-save me-1"></i>
              Aceptar
            </button>
            <button type="button" @click="cancelarEdicion" class="btn-municipal-secondary">
              <i class="fas fa-times me-1"></i>
              Cancelar
            </button>
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
    paginatedConstancias() {
      const start = (this.currentPage - 1) * this.pageSize;
      const end = start + this.pageSize;
      return this.constancias.slice(start, end);
    },
    // Total de páginas basado en el filtro actual
    totalPages() {
      return Math.ceil(this.constancias.length / this.pageSize);
    },
    // Total de registros basado en el filtro actual
    totalRecords() {
      return this.constancias.length;
    }
  },
  created() {
    this.cargarConstancias();
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
        return data.eResponse || data
      } catch (error) {
        console.error('API Error:', error)
        throw error
      }
    },

    async cargarConstancias() {
      this.loading = true;
      this.loadingMessage = 'Cargando constancias...';
      this.error = '';
      this.selectedRow = null;

      try {
        const result = await this.callAPI('SP_CONSTANCIA_NO_OFICIAL_LIST');
        console.log('Raw API result:', result);

        // Manejar la respuesta de la misma forma que constanciafrm.vue
        this.allConstancias = result.data || result || [];
        this.constancias = [...this.allConstancias];

        console.log('Constancias loaded:', this.constancias.length);
      } catch (error) {
        console.error('Error loading constancias:', error);
        this.error = 'Error al cargar constancias: ' + error.message;
        this.allConstancias = [];
        this.constancias = [];
      } finally {
        this.loading = false;
      }
    },
    async buscar() {
      // Si no hay datos cargados, cargarlos primero
      if (this.allConstancias.length === 0) {
        await this.cargarConstancias();
        return;
      }

      // Filtrar datos en el frontend usando el cache
      if (!this.searchValue.trim()) {
        // Si no hay valor de búsqueda, mostrar todos
        this.constancias = [...this.allConstancias];
      } else {
        // Aplicar filtro local
        const searchLower = this.searchValue.toLowerCase().trim();

        this.constancias = this.allConstancias.filter(row => {
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
        const operacion = this.formMode === 'create' ? 'SP_CONSTANCIA_NO_OFICIAL_CREATE' : 'SP_CONSTANCIA_NO_OFICIAL_UPDATE';

        const parametros = this.formMode === 'create' ? [
          { nombre: 'p_propietario', valor: this.form.propietario.substring(0, 80), tipo: 'varchar' },
          { nombre: 'p_actividad', valor: this.form.actividad.substring(0, 120), tipo: 'varchar' },
          { nombre: 'p_ubicacion', valor: this.form.ubicacion.substring(0, 100), tipo: 'varchar' },
          { nombre: 'p_zona', valor: parseInt(this.form.zona), tipo: 'integer' },
          { nombre: 'p_subzona', valor: parseInt(this.form.subzona), tipo: 'integer' },
          { nombre: 'p_capturista', valor: 'SISTEMA', tipo: 'varchar' },
          { nombre: 'p_observaciones', valor: this.form.observaciones || '', tipo: 'varchar' },
          { nombre: 'p_tipo_doc', valor: this.form.tipo_doc || 'CNO', tipo: 'varchar' },
          { nombre: 'p_numero_oficial', valor: this.form.numero_oficial || '', tipo: 'varchar' },
          { nombre: 'p_colonia', valor: this.form.colonia || '', tipo: 'varchar' },
          { nombre: 'p_cp', valor: this.form.cp || '', tipo: 'varchar' },
          { nombre: 'p_telefono', valor: this.form.telefono || '', tipo: 'varchar' },
          { nombre: 'p_email', valor: this.form.email || '', tipo: 'varchar' },
          { nombre: 'p_uso_solicitado', valor: this.form.uso_solicitado || '', tipo: 'varchar' }
        ] : [
          { nombre: 'p_axo', valor: this.selectedRow.axo, tipo: 'integer' },
          { nombre: 'p_folio', valor: this.selectedRow.folio, tipo: 'integer' },
          { nombre: 'p_propietario', valor: this.form.propietario.substring(0, 80), tipo: 'varchar' },
          { nombre: 'p_actividad', valor: this.form.actividad.substring(0, 120), tipo: 'varchar' },
          { nombre: 'p_ubicacion', valor: this.form.ubicacion.substring(0, 100), tipo: 'varchar' },
          { nombre: 'p_zona', valor: parseInt(this.form.zona), tipo: 'integer' },
          { nombre: 'p_subzona', valor: parseInt(this.form.subzona), tipo: 'integer' },
          { nombre: 'p_observaciones', valor: this.form.observaciones || '', tipo: 'varchar' },
          { nombre: 'p_numero_oficial', valor: this.form.numero_oficial || '', tipo: 'varchar' },
          { nombre: 'p_colonia', valor: this.form.colonia || '', tipo: 'varchar' },
          { nombre: 'p_cp', valor: this.form.cp || '', tipo: 'varchar' },
          { nombre: 'p_telefono', valor: this.form.telefono || '', tipo: 'varchar' },
          { nombre: 'p_email', valor: this.form.email || '', tipo: 'varchar' },
          { nombre: 'p_uso_solicitado', valor: this.form.uso_solicitado || '', tipo: 'varchar' }
        ];

        await this.callAPI(operacion, parametros);
        this.cargarConstancias();
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

        await this.callAPI('SP_CONSTANCIA_NO_OFICIAL_DELETE', parametros);
        this.cargarConstancias();
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

        const data = await this.callAPI('SP_CONSTANCIA_NO_OFICIAL_GET', parametros);

        // Mostrar información de impresión
        await this.showSweetAlert({
          type: 'info',
          title: 'Impresión de Constancia',
          text: `Constancia ${this.selectedRow.axo}-${this.selectedRow.folio} lista para impresión.\\nPropietario: ${this.selectedRow.propietario}`,
          confirmButtonText: 'Entendido'
        });
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
/* Estilos específicos para Constancias No Oficiales */
.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.form-field {
  display: flex;
  flex-direction: column;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1050;
}

.modal-content {
  background: white;
  border-radius: 8px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
  max-width: 800px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  background: var(--gradient-municipal);
  color: white;
  padding: 1rem 1.5rem;
  border-radius: 8px 8px 0 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.25rem;
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

.modal-content form {
  padding: 1.5rem;
}

.modal-actions {
  padding: 1rem 1.5rem;
  border-top: 1px solid #e2e8f0;
  display: flex;
  gap: 0.75rem;
  justify-content: flex-end;
  background-color: #f8fafc;
  border-radius: 0 0 8px 8px;
}

/* Loading Overlay */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1060;
}

.loading-spinner {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  text-align: center;
  min-width: 200px;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f4f6;
  border-top: 4px solid var(--municipal-primary);
  border-radius: 50%;
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
  background-color: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1070;
}

.sweet-alert-modal {
  background: white;
  border-radius: 12px;
  box-shadow: 0 20px 25px rgba(0, 0, 0, 0.2);
  max-width: 500px;
  width: 90%;
  text-align: center;
  overflow: hidden;
}

.sweet-alert-header {
  padding: 2rem 1.5rem 1rem;
}

.sweet-alert-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  margin: 0 auto 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  color: white;
}

.sweet-alert-success { background-color: var(--municipal-success); }
.sweet-alert-error { background-color: var(--municipal-danger); }
.sweet-alert-warning { background-color: var(--municipal-warning); }
.sweet-alert-info { background-color: var(--municipal-info); }
.sweet-alert-question { background-color: var(--municipal-accent); }

.sweet-alert-title {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
  color: #1f2937;
}

.sweet-alert-body {
  padding: 0 1.5rem 1.5rem;
}

.sweet-alert-body p {
  margin: 0;
  color: #6b7280;
  line-height: 1.5;
}

.sweet-alert-actions {
  padding: 1rem 1.5rem;
  border-top: 1px solid #e5e7eb;
  display: flex;
  gap: 0.75rem;
  justify-content: center;
  background-color: #f9fafb;
}

/* Responsivo */
@media (max-width: 768px) {
  .form-grid {
    grid-template-columns: 1fr;
  }

  .modal-content {
    margin: 1rem;
    width: calc(100% - 2rem);
  }

  .sweet-alert-modal {
    margin: 1rem;
    width: calc(100% - 2rem);
  }
}
</style>
