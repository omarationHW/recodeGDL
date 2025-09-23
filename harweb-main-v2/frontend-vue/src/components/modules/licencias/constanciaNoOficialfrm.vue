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
      form: {
        propietario: '',
        actividad: '',
        ubicacion: '',
        zona: '',
        subzona: ''
      },
      searchType: 'propietario',
      searchValue: '',
      error: ''
    };
  },
  created() {
    this.cargarSolicitudes();
  },
  methods: {
    cargarSolicitudes() {
      this.error = '';
      this.selectedRow = null;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: { action: 'list' }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.solicitudes = json.eResponse.data;
          } else {
            this.error = json.eResponse.message;
          }
        })
        .catch(err => { this.error = err.message; });
    },
    buscar() {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'search',
            params: { type: this.searchType, value: this.searchValue }
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.solicitudes = json.eResponse.data;
          } else {
            this.error = json.eResponse.message;
          }
        })
        .catch(err => { this.error = err.message; });
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
    guardarSolicitud() {
      this.error = '';
      if (!this.form.propietario || !this.form.actividad || !this.form.ubicacion || !this.form.zona || !this.form.subzona) {
        this.error = 'Todos los campos son obligatorios';
        return;
      }
      const action = this.formMode === 'create' ? 'create' : 'update';
      const params = this.formMode === 'create'
        ? { data: this.form }
        : { axo: this.selectedRow.axo, folio: this.selectedRow.folio, data: this.form };
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, params } })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.cargarSolicitudes();
            this.formActive = false;
          } else {
            this.error = json.eResponse.message;
          }
        })
        .catch(err => { this.error = err.message; });
    },
    cancelarSolicitud() {
      if (!this.selectedRow) return;
      if (!confirm('¿Está seguro de cancelar esta solicitud?')) return;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'cancel',
            params: { axo: this.selectedRow.axo, folio: this.selectedRow.folio }
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.cargarSolicitudes();
          } else {
            this.error = json.eResponse.message;
          }
        })
        .catch(err => { this.error = err.message; });
    },
    imprimirSolicitud() {
      if (!this.selectedRow) return;
      // Aquí se puede abrir una ventana PDF o similar
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'print',
            params: { axo: this.selectedRow.axo, folio: this.selectedRow.folio }
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success && json.eResponse.data && json.eResponse.data.pdf_url) {
            window.open(json.eResponse.data.pdf_url, '_blank');
          } else {
            this.error = json.eResponse.message || 'No se pudo imprimir.';
          }
        })
        .catch(err => { this.error = err.message; });
    },
    onSearchTypeChange() {
      this.searchValue = '';
      this.buscar();
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
</style>
