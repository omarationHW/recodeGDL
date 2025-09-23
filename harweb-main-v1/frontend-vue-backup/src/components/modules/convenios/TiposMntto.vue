<template>
  <div class="tipos-mntto-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Tipos</li>
      </ol>
    </nav>
    <h1>Catálogo de Tipos</h1>
    <div class="card mb-4">
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row">
            <div class="col-md-2">
              <label for="tipo">Tipo</label>
              <input type="number" v-model.number="form.tipo" class="form-control" id="tipo" :readonly="isEdit" required />
            </div>
            <div class="col-md-8">
              <label for="descripcion">Descripción</label>
              <input type="text" v-model="form.descripcion" class="form-control" id="descripcion" maxlength="50" required />
            </div>
            <div class="col-md-2 d-flex align-items-end">
              <button type="submit" class="btn btn-primary me-2">{{ isEdit ? 'Actualizar' : 'Agregar' }}</button>
              <button type="button" class="btn btn-secondary" @click="resetForm">Cancelar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div class="card">
      <div class="card-body">
        <table class="table table-striped">
          <thead>
            <tr>
              <th>Tipo</th>
              <th>Descripción</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="tipo in tipos" :key="tipo.tipo">
              <td>{{ tipo.tipo }}</td>
              <td>{{ tipo.descripcion }}</td>
              <td>
                <button class="btn btn-sm btn-warning me-2" @click="editTipo(tipo)">Editar</button>
              </td>
            </tr>
            <tr v-if="tipos.length === 0">
              <td colspan="3" class="text-center">No hay registros</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="alert.message" :class="['alert', alert.type]" class="mt-3">{{ alert.message }}</div>
  </div>
</template>

<script>
export default {
  name: 'TiposMnttoPage',
  data() {
    return {
      tipos: [],
      form: {
        tipo: '',
        descripcion: ''
      },
      isEdit: false,
      alert: {
        message: '',
        type: 'alert-success'
      }
    };
  },
  mounted() {
    this.fetchTipos();
  },
  methods: {
    async fetchTipos() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: { action: 'list', data: {} }
          })
        });
        const json = await res.json();
        if (json.eResponse.status === 'success') {
          this.tipos = json.eResponse.data;
        } else {
          this.alert.message = json.eResponse.message;
          this.alert.type = 'alert-danger';
        }
      } catch (err) {
        this.alert.message = err.message;
        this.alert.type = 'alert-danger';
      }
    },
    async onSubmit() {
      if (!this.form.tipo || !this.form.descripcion) {
        this.alert.message = 'Todos los campos son obligatorios';
        this.alert.type = 'alert-danger';
        return;
      }
      const action = this.isEdit ? 'update' : 'create';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: { action, data: this.form }
          })
        });
        const json = await res.json();
        if (json.eResponse.status === 'success') {
          this.alert.message = json.eResponse.message;
          this.alert.type = 'alert-success';
          this.fetchTipos();
          this.resetForm();
        } else {
          this.alert.message = json.eResponse.message;
          this.alert.type = 'alert-danger';
        }
      } catch (err) {
        this.alert.message = err.message;
        this.alert.type = 'alert-danger';
      }
    },
    editTipo(tipo) {
      this.form.tipo = tipo.tipo;
      this.form.descripcion = tipo.descripcion;
      this.isEdit = true;
    },
    resetForm() {
      this.form.tipo = '';
      this.form.descripcion = '';
      this.isEdit = false;
      this.alert.message = '';
    }
  }
};
</script>

<style scoped>
.tipos-mntto-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  margin-bottom: 1rem;
}
</style>
