<template>
  <div class="observa-transm-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Observaciones de Transmisiones</li>
      </ol>
    </nav>
    <h2>Observaciones de Transmisiones Patrimoniales</h2>
    <div class="mb-3">
      <label for="folio">Folio de Transmisión</label>
      <input v-model="folio" id="folio" type="number" class="form-control" @change="fetchObservaciones" />
    </div>
    <div v-if="observaciones.length">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Folio</th>
            <th>No. Control</th>
            <th>Observación</th>
            <th>Status</th>
            <th>Capturista Alta</th>
            <th>Fecha Alta</th>
            <th>Capturista Baja</th>
            <th>Fecha Baja</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="obs in observaciones" :key="obs.id">
            <td>{{ obs.folio }}</td>
            <td>{{ obs.nocontrol }}</td>
            <td>{{ obs.observacion }}</td>
            <td>
              <span v-if="obs.status === 'B'" class="badge bg-warning">Bloqueada</span>
              <span v-else-if="obs.status === 'D'" class="badge bg-success">Desbloqueada</span>
              <span v-else>{{ obs.status }}</span>
            </td>
            <td>{{ obs.capturista_alta }}</td>
            <td>{{ obs.fecha_alta }}</td>
            <td>{{ obs.capturista_baja }}</td>
            <td>{{ obs.fecha_baja }}</td>
            <td>
              <button class="btn btn-sm btn-primary" @click="editObs(obs)">Editar</button>
              <button class="btn btn-sm btn-danger" @click="deleteObs(obs)">Eliminar</button>
              <button v-if="obs.status === 'B'" class="btn btn-sm btn-success" @click="unlockObs(obs)">Desbloquear</button>
              <button v-if="obs.status === 'D'" class="btn btn-sm btn-warning" @click="lockObs(obs)">Bloquear</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="card mt-4">
      <div class="card-header">{{ editMode ? 'Editar Observación' : 'Nueva Observación' }}</div>
      <div class="card-body">
        <form @submit.prevent="submitForm">
          <div class="mb-3">
            <label for="nocontrol">No. Control</label>
            <input v-model.number="form.nocontrol" id="nocontrol" type="number" class="form-control" required />
          </div>
          <div class="mb-3">
            <label for="observacion">Observación</label>
            <textarea v-model="form.observacion" id="observacion" class="form-control" rows="3" required></textarea>
          </div>
          <div class="mb-3">
            <label for="cvecuenta">Clave Cuenta</label>
            <input v-model.number="form.cvecuenta" id="cvecuenta" type="number" class="form-control" required />
          </div>
          <div class="mb-3">
            <label for="folio_form">Folio</label>
            <input v-model.number="form.folio" id="folio_form" type="number" class="form-control" required />
          </div>
          <div class="mb-3">
            <label for="usuario">Usuario</label>
            <input v-model="form.usuario" id="usuario" type="text" class="form-control" required />
          </div>
          <div class="mb-3">
            <button type="submit" class="btn btn-success">{{ editMode ? 'Actualizar' : 'Registrar' }}</button>
            <button type="button" class="btn btn-secondary ms-2" @click="resetForm">Cancelar</button>
          </div>
        </form>
      </div>
    </div>
    <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ObservaTransmPage',
  data() {
    return {
      folio: '',
      observaciones: [],
      form: {
        nocontrol: '',
        cvecuenta: '',
        folio: '',
        observacion: '',
        usuario: ''
      },
      editMode: false,
      editingObs: null,
      message: '',
      success: true
    };
  },
  methods: {
    fetchObservaciones() {
      if (!this.folio) return;
      this.apiRequest('list', { folio: this.folio });
    },
    apiRequest(action, params) {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: action,
            params: params
          }
        })
      })
        .then(res => res.json())
        .then(res => {
          if (res.eResponse.success) {
            if (action === 'list') {
              this.observaciones = res.eResponse.data;
            } else {
              this.message = res.eResponse.message;
              this.success = true;
              this.fetchObservaciones();
              this.resetForm();
            }
          } else {
            this.message = res.eResponse.message;
            this.success = false;
          }
        })
        .catch(err => {
          this.message = err.message;
          this.success = false;
        });
    },
    submitForm() {
      if (this.editMode) {
        this.apiRequest('update', {
          ...this.form
        });
      } else {
        this.apiRequest('create', {
          ...this.form
        });
      }
    },
    editObs(obs) {
      this.editMode = true;
      this.editingObs = obs;
      this.form = {
        nocontrol: obs.nocontrol,
        cvecuenta: obs.cvecuenta,
        folio: obs.folio,
        observacion: obs.observacion,
        usuario: obs.capturista_alta || ''
      };
    },
    deleteObs(obs) {
      if (confirm('¿Está seguro de eliminar esta observación?')) {
        this.apiRequest('delete', {
          nocontrol: obs.nocontrol,
          folio: obs.folio,
          usuario: obs.capturista_alta || ''
        });
      }
    },
    lockObs(obs) {
      if (confirm('¿Bloquear esta transmisión?')) {
        this.apiRequest('lock', {
          nocontrol: obs.nocontrol,
          cvecuenta: obs.cvecuenta,
          folio: obs.folio,
          observacion: obs.observacion,
          usuario: obs.capturista_alta || ''
        });
      }
    },
    unlockObs(obs) {
      if (confirm('¿Desbloquear esta transmisión?')) {
        this.apiRequest('unlock', {
          nocontrol: obs.nocontrol,
          folio: obs.folio,
          observacion: obs.observacion,
          usuario: obs.capturista_alta || ''
        });
      }
    },
    resetForm() {
      this.editMode = false;
      this.editingObs = null;
      this.form = {
        nocontrol: '',
        cvecuenta: '',
        folio: '',
        observacion: '',
        usuario: ''
      };
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
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
.card {
  margin-top: 2rem;
}
</style>
