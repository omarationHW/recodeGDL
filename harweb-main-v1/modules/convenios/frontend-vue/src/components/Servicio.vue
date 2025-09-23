<template>
  <div class="servicio-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Obra Pública / Servicios</li>
      </ol>
    </nav>
    <h2>Catálogo de Obra Pública / Servicios</h2>
    <div class="mb-3">
      <button class="btn btn-primary" @click="openForm('create')">Agregar Servicio</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th># Servicio</th>
          <th>Descripción</th>
          <th>Obra 1994</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="serv in servicios" :key="serv.servicio">
          <td>{{ serv.servicio }}</td>
          <td>{{ serv.descripcion }}</td>
          <td>{{ serv.serv_obra94 }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="openForm('edit', serv)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteServicio(serv.servicio)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="showForm" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ formMode === 'create' ? 'Agregar Servicio' : 'Editar Servicio' }}</h5>
            <button type="button" class="close" @click="closeForm">&times;</button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="submitForm">
              <div class="form-group" v-if="formMode === 'edit'">
                <label># Servicio</label>
                <input type="number" class="form-control" v-model="form.servicio" readonly />
              </div>
              <div class="form-group">
                <label>Descripción</label>
                <input type="text" class="form-control" v-model="form.descripcion" required maxlength="50" />
              </div>
              <div class="form-group">
                <label>Obra 1994</label>
                <input type="number" class="form-control" v-model="form.serv_obra94" min="0" />
              </div>
              <div class="modal-footer">
                <button type="submit" class="btn btn-success">Guardar</button>
                <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    <div v-if="alert.message" :class="['alert', alert.success ? 'alert-success' : 'alert-danger']">
      {{ alert.message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ServicioPage',
  data() {
    return {
      servicios: [],
      showForm: false,
      formMode: 'create',
      form: {
        servicio: null,
        descripcion: '',
        serv_obra94: null
      },
      alert: {
        message: '',
        success: true
      }
    };
  },
  created() {
    this.loadServicios();
  },
  methods: {
    async apiRequest(action, data = {}) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: { action, data }
        })
      });
      return (await res.json()).eResponse;
    },
    async loadServicios() {
      const resp = await this.apiRequest('list');
      if (resp.success) {
        this.servicios = resp.data;
      } else {
        this.alert = { message: resp.message, success: false };
      }
    },
    openForm(mode, serv = null) {
      this.formMode = mode;
      if (mode === 'edit' && serv) {
        this.form = { ...serv };
      } else {
        this.form = { servicio: null, descripcion: '', serv_obra94: null };
      }
      this.showForm = true;
    },
    closeForm() {
      this.showForm = false;
      this.form = { servicio: null, descripcion: '', serv_obra94: null };
    },
    async submitForm() {
      let resp;
      if (this.formMode === 'create') {
        resp = await this.apiRequest('create', {
          descripcion: this.form.descripcion,
          serv_obra94: this.form.serv_obra94
        });
      } else {
        resp = await this.apiRequest('update', {
          servicio: this.form.servicio,
          descripcion: this.form.descripcion,
          serv_obra94: this.form.serv_obra94
        });
      }
      if (resp.success) {
        this.alert = { message: 'Guardado correctamente', success: true };
        this.closeForm();
        this.loadServicios();
      } else {
        this.alert = { message: resp.message, success: false };
      }
    },
    async deleteServicio(id) {
      if (!confirm('¿Está seguro de eliminar este servicio?')) return;
      const resp = await this.apiRequest('delete', { servicio: id });
      if (resp.success) {
        this.alert = { message: 'Eliminado correctamente', success: true };
        this.loadServicios();
      } else {
        this.alert = { message: resp.message, success: false };
      }
    }
  }
};
</script>

<style scoped>
.servicio-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-dialog {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.2);
  width: 400px;
  max-width: 90vw;
}
</style>
