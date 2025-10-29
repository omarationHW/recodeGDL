<template>
  <div class="elabora-convenios-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Quien elabora convenios</li>
      </ol>
    </nav>
    <h1 class="mb-4">Quien elabora convenios</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showForm('create')">Agregar</button>
    </div>
    <table class="table table-striped table-bordered">
      <thead>
        <tr>
          <th>Rec</th>
          <th>Recaudador</th>
          <th>Iniciales Titular</th>
          <th>Elaboró Convenio</th>
          <th>Iniciales Elaboró</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in convenios" :key="item.id_control">
          <td>{{ item.id_rec }}</td>
          <td>{{ item.recaudador }}</td>
          <td>{{ item.iniciales_titular }}</td>
          <td>{{ item.elaboro }}</td>
          <td>{{ item.iniciales_elaboro }}</td>
          <td>
            <button class="btn btn-sm btn-secondary" @click="showForm('edit', item)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteItem(item)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="convenios.length === 0">
          <td colspan="6" class="text-center">No hay registros</td>
        </tr>
      </tbody>
    </table>

    <!-- Modal Form -->
    <div v-if="formVisible" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ formMode === 'create' ? 'Agregar' : 'Editar' }} Elaboración de Convenio</h5>
            <button type="button" class="btn-close" @click="closeForm"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="submitForm">
              <div class="mb-3">
                <label for="id_rec" class="form-label">Recaudadora (ID)</label>
                <input type="number" v-model.number="form.id_rec" class="form-control" required />
              </div>
              <div class="mb-3">
                <label for="id_usu_titular" class="form-label">ID Usuario Titular</label>
                <input type="number" v-model.number="form.id_usu_titular" class="form-control" required />
              </div>
              <div class="mb-3">
                <label for="iniciales_titular" class="form-label">Iniciales Titular</label>
                <input type="text" v-model="form.iniciales_titular" class="form-control" maxlength="10" required />
              </div>
              <div class="mb-3">
                <label for="id_usu_elaboro" class="form-label">ID Usuario Elabora</label>
                <input type="number" v-model.number="form.id_usu_elaboro" class="form-control" required />
              </div>
              <div class="mb-3">
                <label for="iniciales_elaboro" class="form-label">Iniciales Elabora</label>
                <input type="text" v-model="form.iniciales_elaboro" class="form-control" maxlength="10" required />
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

  </div>
</template>

<script>
export default {
  name: 'ElaboraConveniosPage',
  data() {
    return {
      convenios: [],
      formVisible: false,
      formMode: 'create',
      form: {
        id_control: null,
        id_rec: '',
        id_usu_titular: '',
        iniciales_titular: '',
        id_usu_elaboro: '',
        iniciales_elaboro: ''
      }
    }
  },
  mounted() {
    this.fetchConvenios();
  },
  methods: {
    async fetchConvenios() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'list', params: { module: 'elabora_convenios' } })
      });
      const data = await res.json();
      if (data.success) {
        this.convenios = data.data;
      } else {
        this.convenios = [];
      }
    },
    showForm(mode, item = null) {
      this.formMode = mode;
      if (mode === 'edit' && item) {
        this.form = { ...item };
      } else {
        this.form = {
          id_control: null,
          id_rec: '',
          id_usu_titular: '',
          iniciales_titular: '',
          id_usu_elaboro: '',
          iniciales_elaboro: ''
        };
      }
      this.formVisible = true;
    },
    closeForm() {
      this.formVisible = false;
    },
    async submitForm() {
      let action = this.formMode === 'create' ? 'create' : 'update';
      let params = { ...this.form };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, params })
      });
      const data = await res.json();
      if (data.success) {
        this.fetchConvenios();
        this.closeForm();
      } else {
        alert('Error: ' + (data.errors ? JSON.stringify(data.errors) : data.message));
      }
    },
    async deleteItem(item) {
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'delete', params: { id_control: item.id_control } })
      });
      const data = await res.json();
      if (data.success) {
        this.fetchConvenios();
      } else {
        alert('Error: ' + (data.errors ? JSON.stringify(data.errors) : data.message));
      }
    }
  }
}
</script>

<style scoped>
.elabora-convenios-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-dialog {
  background: #fff;
  border-radius: 8px;
  max-width: 500px;
  width: 100%;
  box-shadow: 0 2px 16px rgba(0,0,0,0.2);
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #eee;
  padding: 1rem;
}
.modal-body {
  padding: 1rem;
}
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  padding: 1rem;
  border-top: 1px solid #eee;
}
.btn-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  line-height: 1;
  cursor: pointer;
}
</style>
