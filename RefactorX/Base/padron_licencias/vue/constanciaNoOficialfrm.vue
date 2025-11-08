<template>
  <div class="solic-no-oficial-page">
    <h1>Solicitud de Número Oficial</h1>
    <div class="breadcrumb">Inicio / Solicitud de Número Oficial</div>
    <div class="actions">
      <button @click="nuevaSolicitud" :disabled="formActive">Nueva</button>
      <button @click="modificarSolicitud" :disabled="!selectedRow || formActive">Modificar</button>
      <button @click="cancelarSolicitud" :disabled="!selectedRow || formActive">Cancelar Solicitud</button>
      <button @click="imprimirSolicitud" :disabled="!selectedRow">Imprimir</button>
    </div>
    <div class="busqueda">
      <label>Tipo de Búsqueda:</label>
      <select v-model="searchType" @change="onSearchTypeChange">
        <option value="propietario">Propietario</option>
        <option value="ubicacion">Ubicación</option>
      </select>
      <input v-model="searchValue" @input="buscar" placeholder="Buscar..." />
    </div>
    <table class="solic-table">
      <thead>
        <tr>
          <th>Año</th>
          <th>Folio</th>
          <th>Propietario</th>
          <th>Actividad</th>
          <th>Ubicación</th>
          <th>Zona</th>
          <th>Subzona</th>
          <th>Vigente</th>
          <th>Fecha</th>
          <th>Capturista</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in solicitudes" :key="row.axo + '-' + row.folio" :class="{selected: isSelected(row)}" @click="selectRow(row)">
          <td>{{ row.axo }}</td>
          <td>{{ row.folio }}</td>
          <td>{{ row.propietario }}</td>
          <td>{{ row.actividad }}</td>
          <td>{{ row.ubicacion }}</td>
          <td>{{ row.zona }}</td>
          <td>{{ row.subzona }}</td>
          <td>{{ row.vigente }}</td>
          <td>{{ row.feccap }}</td>
          <td>{{ row.capturista }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="formActive" class="form-panel">
      <h2>{{ formMode === 'create' ? 'Nueva Solicitud' : 'Modificar Solicitud' }}</h2>
      <form @submit.prevent="guardarSolicitud">
        <div>
          <label>Propietario:</label>
          <input v-model="form.propietario" required maxlength="50" />
        </div>
        <div>
          <label>Actividad:</label>
          <input v-model="form.actividad" required maxlength="80" />
        </div>
        <div>
          <label>Ubicación:</label>
          <input v-model="form.ubicacion" required maxlength="75" />
        </div>
        <div>
          <label>Zona:</label>
          <input v-model.number="form.zona" type="number" required min="1" />
        </div>
        <div>
          <label>Subzona:</label>
          <input v-model.number="form.subzona" type="number" required min="1" />
        </div>
        <div class="form-actions">
          <button type="submit">Aceptar</button>
          <button type="button" @click="cancelarEdicion">Cancelar</button>
        </div>
      </form>
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
      form: {
        propietario: '',
        actividad: '',
        ubicacion: '',
        zona: '',
        subzona: ''
      },
      searchType: 'propietario',
      searchValue: '',
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
      }
    };
  },
  created() {
    this.cargarSolicitudes();
  },
  methods: {
    async cargarSolicitudes() {
      this.selectedRow = null;
      try {
        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_solicnooficial_list',
              Base: 'padron_licencias',
              Parametros: [],
              Tenant: 'guadalajara'
            }
          })
        });
        const json = await response.json();
        if (json.eResponse && json.eResponse.success) {
          this.solicitudes = json.eResponse.data || [];
        } else {
          const errorMessage = json.eResponse?.message || json.message || 'Error al cargar solicitudes';
          await this.showSweetAlert({
            type: 'error',
            title: 'Error al Cargar',
            text: errorMessage,
            confirmButtonText: 'Entendido'
          });
        }
      } catch (err) {
        await this.showSweetAlert({
          type: 'error',
          title: 'Error de Conexión',
          text: `Error al conectar con el servidor: ${err.message}`,
          confirmButtonText: 'Entendido'
        });
      }
    },
    async buscar() {
      try {
        const params = this.searchValue ? [this.searchType, this.searchValue] : [];
        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              Operacion: this.searchValue ? 'sp_solicnooficial_search' : 'sp_solicnooficial_list',
              Base: 'padron_licencias',
              Parametros: params,
              Tenant: 'guadalajara'
            }
          })
        });
        const json = await response.json();
        if (json.eResponse && json.eResponse.success) {
          this.solicitudes = json.eResponse.data || [];
        } else {
          const errorMessage = json.eResponse?.message || json.message || 'Error en la búsqueda';
          await this.showSweetAlert({
            type: 'error',
            title: 'Error en Búsqueda',
            text: errorMessage,
            confirmButtonText: 'Entendido'
          });
        }
      } catch (err) {
        await this.showSweetAlert({
          type: 'error',
          title: 'Error de Conexión',
          text: `Error al conectar con el servidor: ${err.message}`,
          confirmButtonText: 'Entendido'
        });
      }
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
      if (!this.form.propietario || !this.form.actividad || !this.form.ubicacion || !this.form.zona || !this.form.subzona) {
        await this.showSweetAlert({
          type: 'warning',
          title: 'Campos Incompletos',
          text: 'Todos los campos son obligatorios. Por favor complete la información.',
          confirmButtonText: 'Entendido'
        });
        return;
      }

      // Confirmar acción con SweetAlert
      const mensaje = this.formMode === 'create'
        ? `¿Está seguro de crear esta solicitud para "${this.form.propietario}"?`
        : `¿Está seguro de actualizar la solicitud de "${this.form.propietario}"?`;

      const shouldProceed = await this.showSweetAlert({
        type: this.formMode === 'create' ? 'question' : 'warning',
        title: this.formMode === 'create' ? '¿Crear Solicitud?' : '¿Actualizar Solicitud?',
        text: mensaje,
        showCancelButton: true,
        confirmButtonText: this.formMode === 'create' ? 'Sí, crear' : 'Sí, actualizar',
        cancelButtonText: 'Cancelar'
      });

      if (!shouldProceed) return;

      const action = this.formMode === 'create' ? 'create' : 'update';
      const params = this.formMode === 'create'
        ? { data: this.form }
        : { axo: this.selectedRow.axo, folio: this.selectedRow.folio, data: this.form };

      try {
        const operation = this.formMode === 'create' ? 'sp_solicnooficial_insert' : 'sp_solicnooficial_update';
        const apiParams = this.formMode === 'create'
          ? [this.form.propietario, this.form.actividad, this.form.ubicacion, this.form.zona, this.form.subzona]
          : [this.selectedRow.axo, this.selectedRow.folio, this.form.propietario, this.form.actividad, this.form.ubicacion, this.form.zona, this.form.subzona];

        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              Operacion: operation,
              Base: 'padron_licencias',
              Parametros: apiParams,
              Tenant: 'guadalajara'
            }
          })
        });

        console.log('Response status:', response.status);

        // Leer JSON independientemente del status code
        const json = await response.json();
        console.log('Response from API:', json);

        // Determinar si fue exitoso basado en status Y eResponse
        const isSuccess = response.ok && json.eResponse && json.eResponse.success;

        if (isSuccess) {
          // Operación exitosa
          console.log('✅ OPERACIÓN EXITOSA');
          await this.showSweetAlert({
            type: 'success',
            title: '¡Éxito!',
            text: this.formMode === 'create' ? 'Solicitud creada exitosamente' : 'Solicitud actualizada exitosamente',
            confirmButtonText: 'Excelente'
          });

          this.cargarSolicitudes();
          this.formActive = false;
        } else {
          // Error - puede venir del eResponse o ser un error HTTP
          let errorMessage = 'Error del servidor';

          if (json.eResponse && json.eResponse.message) {
            errorMessage = json.eResponse.message;
            console.log('🔴 ERROR CON eResponse:', errorMessage);
          } else if (json.message) {
            errorMessage = json.message;
            console.log('🔴 ERROR CON message:', errorMessage);
          } else {
            errorMessage = `Error ${response.status}: ${response.statusText}`;
            console.log('🔴 ERROR HTTP:', errorMessage);
          }

          console.log('🔴 Full error response:', json);
          console.log('🔴 Showing SweetAlert with message:', errorMessage);

          await this.showSweetAlert({
            type: 'error',
            title: 'Error al Guardar',
            text: errorMessage,
            confirmButtonText: 'Entendido'
          });

          console.log('🔴 SweetAlert shown');
        }
      } catch (err) {
        console.log('🔴 CATCH ERROR:', err);

        // Si es un error de respuesta HTTP pero tenemos la respuesta, intentar leer el JSON
        if (err.response) {
          try {
            const errorJson = await err.response.json();
            console.log('🔴 Error JSON from response:', errorJson);

            if (errorJson.eResponse && errorJson.eResponse.message) {
              await this.showSweetAlert({
                type: 'error',
                title: 'Error al Guardar',
                text: errorJson.eResponse.message,
                confirmButtonText: 'Entendido'
              });
              return;
            }
          } catch (jsonError) {
            console.log('🔴 Could not parse error JSON:', jsonError);
          }
        }

        // Error de conexión general
        await this.showSweetAlert({
          type: 'error',
          title: 'Error de Conexión',
          text: `Error al conectar con el servidor: ${err.message}`,
          confirmButtonText: 'Entendido'
        });
      }
    },
    async cancelarSolicitud() {
      if (!this.selectedRow) return;
      const shouldProceed = await this.showSweetAlert({
        type: 'warning',
        title: '¿Cancelar Solicitud?',
        text: '¿Está seguro de cancelar esta solicitud? Esta acción no se puede deshacer.',
        showCancelButton: true,
        confirmButtonText: 'Sí, cancelar',
        cancelButtonText: 'No'
      });
      if (!shouldProceed) return;

      try {
        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_solicnooficial_cancel',
              Base: 'padron_licencias',
              Parametros: [this.selectedRow.axo, this.selectedRow.folio],
              Tenant: 'guadalajara'
            }
          })
        });

        const json = await response.json();
        if (json.eResponse && json.eResponse.success) {
          await this.showSweetAlert({
            type: 'success',
            title: '¡Éxito!',
            text: 'Solicitud cancelada exitosamente',
            confirmButtonText: 'Entendido'
          });
          this.cargarSolicitudes();
        } else {
          const errorMessage = json.eResponse?.message || json.message || 'No se pudo cancelar la solicitud';
          await this.showSweetAlert({
            type: 'error',
            title: 'Error al Cancelar',
            text: errorMessage,
            confirmButtonText: 'Entendido'
          });
        }
      } catch (err) {
        await this.showSweetAlert({
          type: 'error',
          title: 'Error de Conexión',
          text: `Error al conectar con el servidor: ${err.message}`,
          confirmButtonText: 'Entendido'
        });
      }
    },
    async imprimirSolicitud() {
      if (!this.selectedRow) return;

      try {
        const response = await fetch('http://localhost:8080/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_solicnooficial_print',
              Base: 'padron_licencias',
              Parametros: [this.selectedRow.axo, this.selectedRow.folio],
              Tenant: 'guadalajara'
            }
          })
        });

        const json = await response.json();
        if (json.eResponse && json.eResponse.success) {
          if (json.eResponse.data && json.eResponse.data.pdf_url) {
            window.open(json.eResponse.data.pdf_url, '_blank');
          } else {
            // Si no hay PDF, simplemente imprimir la página
            window.print();
          }
        } else {
          const errorMessage = json.eResponse?.message || json.message || 'No se pudo imprimir';
          await this.showSweetAlert({
            type: 'error',
            title: 'Error al Imprimir',
            text: errorMessage,
            confirmButtonText: 'Entendido'
          });
        }
      } catch (err) {
        await this.showSweetAlert({
          type: 'error',
          title: 'Error de Conexión',
          text: `Error al conectar con el servidor: ${err.message}`,
          confirmButtonText: 'Entendido'
        });
      }
    },
    onSearchTypeChange() {
      this.searchValue = '';
      this.buscar();
    },
    getSweetAlertIcon(type) {
      switch (type) {
        case 'success': return 'fas fa-check-circle';
        case 'error': return 'fas fa-exclamation-circle';
        case 'warning': return 'fas fa-exclamation-triangle';
        case 'question': return 'fas fa-question-circle';
        default: return 'fas fa-info-circle';
      }
    },
    showSweetAlert(options) {
      console.log('🔵 showSweetAlert called with:', options);
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
        };
        console.log('🔵 sweetAlert set to:', this.sweetAlert);
      });
    },
    closeSweetAlert() {
      this.sweetAlert.show = false;
    }
  }
};
</script>

<style scoped>
.solic-no-oficial-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 24px;
}
.breadcrumb {
  font-size: 0.9em;
  color: #888;
  margin-bottom: 12px;
}
.actions {
  margin-bottom: 16px;
}
.actions button {
  margin-right: 8px;
}
.busqueda {
  margin-bottom: 16px;
}
.solic-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 16px;
}
.solic-table th, .solic-table td {
  border: 1px solid #ccc;
  padding: 6px 8px;
}
.solic-table tr.selected {
  background: #e0f7fa;
}
.form-panel {
  background: #f9f9f9;
  border: 1px solid #ddd;
  padding: 16px;
  margin-bottom: 16px;
}
.form-panel form > div {
  margin-bottom: 10px;
}
.form-actions {
  margin-top: 12px;
}
.error {
  color: #b71c1c;
  background: #ffebee;
  padding: 8px;
  border-radius: 4px;
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
</style>
