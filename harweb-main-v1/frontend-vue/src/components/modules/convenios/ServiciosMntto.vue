<template>
  <div class="servicios-mntto-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Servicios de Obra Pública</li>
      </ol>
    </nav>
    <h1>Catálogo de Servicios de Obra Pública</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showForm('create')">Agregar Servicio</button>
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
            <button class="btn btn-sm btn-warning" @click="showForm('edit', serv)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteServicio(serv.servicio)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="formVisible" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ formMode === 'create' ? 'Agregar Servicio' : 'Editar Servicio' }}</h5>
            <button type="button" class="close" @click="closeForm">&times;</button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="submitForm">
              <div class="form-group">
                <label for="servicio"># Servicio</label>
                <input type="number" v-model.number="form.servicio" :disabled="formMode==='edit'" class="form-control" required />
              </div>
              <div class="form-group">
                <label for="descripcion">Descripción</label>
                <input type="text" v-model="form.descripcion" class="form-control" maxlength="255" required />
              </div>
              <div class="form-group">
                <label for="serv_obra94">Obra 1994</label>
                <input type="number" v-model.number="form.serv_obra94" class="form-control" />
              </div>
              <div class="form-group text-right">
                <button type="submit" class="btn btn-success">Guardar</button>
                <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
              </div>
            </form>
            <div v-if="formError" class="alert alert-danger mt-2">{{ formError }}</div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-overlay">
      <div class="spinner-border"></div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ServiciosMnttoPage',
  data() {
    return {
      servicios: [],
      loading: false,
      formVisible: false,
      formMode: 'create',
      form: {
        servicio: '',
        descripcion: '',
        serv_obra94: ''
      },
      formError: ''
    };
  },
  created() {
    this.fetchServicios();
  },
  methods: {
    async fetchServicios() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'servicios_list' })
        });
        const data = await res.json();
        if (data.success) {
          this.servicios = data.data;
        } else {
          this.formError = data.message || 'Error al cargar servicios';
        }
      } finally {
        this.loading = false;
      }
    },
    showForm(mode, serv = null) {
      this.formMode = mode;
      this.formError = '';
      if (mode === 'edit' && serv) {
        this.form = { ...serv };
      } else {
        this.form = { servicio: '', descripcion: '', serv_obra94: '' };
      }
      this.formVisible = true;
    },
    closeForm() {
      this.formVisible = false;
      this.formError = '';
    },
    async submitForm() {
      this.loading = true;
      this.formError = '';
      try {
        const action = this.formMode === 'create' ? 'servicios_create' : 'servicios_update';
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action, params: this.form })
        });
        const data = await res.json();
        if (data.success) {
          this.fetchServicios();
          this.closeForm();
        } else {
          this.formError = data.message || 'Error al guardar';
        }
      } finally {
        this.loading = false;
      }
    },
    async deleteServicio(servicio) {
      if (!confirm('¿Está seguro de eliminar este servicio?')) return;
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'servicios_delete', params: { servicio } })
        });
        const data = await res.json();
        if (data.success) {
          this.fetchServicios();
        } else {
          alert(data.message || 'Error al eliminar');
        }
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.servicios-mntto-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.loading-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(255,255,255,0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1100;
}
.modal-dialog {
  background: #fff;
  border-radius: 6px;
  box-shadow: 0 2px 16px rgba(0,0,0,0.2);
  min-width: 400px;
}
</style>
