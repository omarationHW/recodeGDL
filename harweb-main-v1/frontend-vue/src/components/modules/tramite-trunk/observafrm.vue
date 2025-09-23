<template>
  <div class="observa-transm-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Observaciones de Transmisión</li>
      </ol>
    </nav>
    <h2>Observaciones de Transmisión Patrimonial</h2>
    <div class="mb-3">
      <label for="cvecuenta">Cuenta Catastral</label>
      <input v-model="cvecuenta" id="cvecuenta" type="number" class="form-control" @change="fetchObservaciones" />
    </div>
    <div v-if="observaciones.length > 0">
      <h4>Historial de Observaciones</h4>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>ID</th>
            <th>Folio</th>
            <th>Observación</th>
            <th>Usuario</th>
            <th>Fecha</th>
            <th>Global</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="obs in observaciones" :key="obs.id">
            <td>{{ obs.id }}</td>
            <td>{{ obs.folio || '-' }}</td>
            <td>{{ obs.observacion }}</td>
            <td>{{ obs.usuario }}</td>
            <td>{{ obs.created_at | formatDate }}</td>
            <td><span v-if="obs.es_global">Sí</span><span v-else>No</span></td>
            <td>
              <button class="btn btn-sm btn-primary" @click="editObs(obs)">Editar</button>
              <button class="btn btn-sm btn-danger" @click="deleteObs(obs.id)">Eliminar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="card mt-4">
      <div class="card-header">
        <span v-if="editing">Editar Observación</span>
        <span v-else>Agregar Observación</span>
      </div>
      <div class="card-body">
        <form @submit.prevent="saveObs">
          <div class="mb-3">
            <label for="folio">Folio (opcional)</label>
            <input v-model="form.folio" id="folio" type="number" class="form-control" />
          </div>
          <div class="mb-3">
            <label for="observacion">Observación</label>
            <textarea v-model="form.observacion" id="observacion" class="form-control" rows="4" required @input="toUppercase"></textarea>
          </div>
          <div class="mb-3">
            <label for="usuario">Usuario</label>
            <input v-model="form.usuario" id="usuario" type="text" class="form-control" required />
          </div>
          <div class="form-check mb-3">
            <input v-model="form.es_global" id="es_global" type="checkbox" class="form-check-input" />
            <label for="es_global" class="form-check-label">Observación Global</label>
          </div>
          <button type="submit" class="btn btn-success">{{ editing ? 'Actualizar' : 'Agregar' }}</button>
          <button type="button" class="btn btn-secondary ms-2" @click="resetForm">Cancelar</button>
        </form>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'ObservaTransmPage',
  data() {
    return {
      cvecuenta: '',
      observaciones: [],
      form: {
        id: null,
        folio: '',
        observacion: '',
        usuario: '',
        es_global: false
      },
      editing: false,
      error: '',
      success: ''
    };
  },
  filters: {
    formatDate(val) {
      if (!val) return '';
      return new Date(val).toLocaleString();
    }
  },
  methods: {
    fetchObservaciones() {
      if (!this.cvecuenta) return;
      this.error = '';
      this.success = '';
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'list',
            params: { cvecuenta: this.cvecuenta }
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.observaciones = json.eResponse.data;
          } else {
            this.error = json.eResponse.message || 'Error al cargar observaciones';
          }
        });
    },
    saveObs() {
      this.error = '';
      this.success = '';
      const action = this.editing ? 'update' : 'create';
      const params = {
        cvecuenta: this.cvecuenta,
        folio: this.form.folio,
        observacion: this.form.observacion,
        usuario: this.form.usuario,
        es_global: this.form.es_global
      };
      if (this.editing) {
        params.id = this.form.id;
      }
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action,
            params
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.success = this.editing ? 'Observación actualizada' : 'Observación agregada';
            this.resetForm();
            this.fetchObservaciones();
          } else {
            this.error = json.eResponse.message || 'Error al guardar';
          }
        });
    },
    editObs(obs) {
      this.form = {
        id: obs.id,
        folio: obs.folio,
        observacion: obs.observacion,
        usuario: obs.usuario,
        es_global: !!obs.es_global
      };
      this.editing = true;
      this.error = '';
      this.success = '';
    },
    deleteObs(id) {
      if (!confirm('¿Desea eliminar esta observación?')) return;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'delete',
            params: { id }
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.success = 'Observación eliminada';
            this.fetchObservaciones();
          } else {
            this.error = json.eResponse.message || 'Error al eliminar';
          }
        });
    },
    resetForm() {
      this.form = {
        id: null,
        folio: '',
        observacion: '',
        usuario: '',
        es_global: false
      };
      this.editing = false;
      this.error = '';
      this.success = '';
    },
    toUppercase(e) {
      this.form.observacion = this.form.observacion.toUpperCase();
    }
  }
};
</script>

<style scoped>
.observa-transm-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.card {
  margin-top: 2rem;
}
</style>
