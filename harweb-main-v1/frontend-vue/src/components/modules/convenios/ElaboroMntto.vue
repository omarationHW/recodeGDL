<template>
  <div class="elaboro-mntto-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Catálogo de Elaboro Oficio</li>
      </ol>
    </nav>
    <h2>Mantenimiento para elaborar convenio</h2>
    <div class="card mb-3">
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-4">
              <label for="rec">Recaudadora</label>
              <input v-model="form.id_rec" type="number" class="form-control" id="rec" required @blur="fetchTitularInfo" />
            </div>
            <div class="col-md-4">
              <label for="id_usu_titular">ID Usuario Titular</label>
              <input v-model="form.id_usu_titular" type="number" class="form-control" id="id_usu_titular" required @blur="fetchTitularInfo" />
            </div>
            <div class="col-md-4">
              <label for="iniciales_titular">Iniciales Titular</label>
              <input v-model="form.iniciales_titular" type="text" class="form-control" id="iniciales_titular" maxlength="10" required />
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-4">
              <label for="id_usu_elaboro">ID Usuario Elabora</label>
              <input v-model="form.id_usu_elaboro" type="number" class="form-control" id="id_usu_elaboro" required @blur="fetchTitularInfo" />
            </div>
            <div class="col-md-4">
              <label for="iniciales_elaboro">Iniciales Elabora</label>
              <input v-model="form.iniciales_elaboro" type="text" class="form-control" id="iniciales_elaboro" maxlength="10" required />
            </div>
          </div>
          <div class="mb-3">
            <button type="submit" class="btn btn-primary me-2">{{ isEdit ? 'Actualizar' : 'Crear' }}</button>
            <button type="button" class="btn btn-secondary" @click="resetForm">Limpiar</button>
          </div>
        </form>
      </div>
    </div>
    <div class="card mb-3">
      <div class="card-header">Datos de Titular y Elabora</div>
      <div class="card-body">
        <div v-if="titularInfo">
          <div><strong>Recaudadora:</strong> {{ titularInfo.recaudadora }}</div>
          <div><strong>Titular:</strong> {{ titularInfo.titular }} ({{ titularInfo.usutitular }})</div>
          <div><strong>Elabora:</strong> {{ titularInfo.elabora }} ({{ titularInfo.usuelabora }})</div>
        </div>
        <div v-else class="text-muted">Ingrese los IDs y presione fuera del campo para ver los datos.</div>
      </div>
    </div>
    <div class="card">
      <div class="card-header">Registros existentes</div>
      <div class="card-body p-0">
        <table class="table table-striped table-hover mb-0">
          <thead>
            <tr>
              <th>ID</th>
              <th>Recaudadora</th>
              <th>ID Titular</th>
              <th>Iniciales Titular</th>
              <th>ID Elabora</th>
              <th>Iniciales Elabora</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in registros" :key="item.id_control">
              <td>{{ item.id_control }}</td>
              <td>{{ item.id_rec }}</td>
              <td>{{ item.id_usu_titular }}</td>
              <td>{{ item.iniciales_titular }}</td>
              <td>{{ item.id_usu_elaboro }}</td>
              <td>{{ item.iniciales_elaboro }}</td>
              <td>
                <button class="btn btn-sm btn-info me-1" @click="editItem(item)">Editar</button>
                <button class="btn btn-sm btn-danger" @click="deleteItem(item)">Eliminar</button>
              </td>
            </tr>
            <tr v-if="registros.length === 0">
              <td colspan="7" class="text-center text-muted">No hay registros</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ElaboroMnttoPage',
  data() {
    return {
      registros: [],
      form: {
        id_control: null,
        id_rec: '',
        id_usu_titular: '',
        iniciales_titular: '',
        id_usu_elaboro: '',
        iniciales_elaboro: ''
      },
      titularInfo: null,
      isEdit: false
    };
  },
  mounted() {
    this.fetchRegistros();
  },
  methods: {
    async fetchRegistros() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: { action: 'list', params: {} }
        })
      });
      const data = await res.json();
      this.registros = data.eResponse.data || [];
    },
    async fetchTitularInfo() {
      if (!this.form.id_rec || !this.form.id_usu_titular || !this.form.id_usu_elaboro) {
        this.titularInfo = null;
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'titular_info',
            params: {
              id_rec: this.form.id_rec,
              id_usu_titular: this.form.id_usu_titular,
              id_usu_elaboro: this.form.id_usu_elaboro
            }
          }
        })
      });
      const data = await res.json();
      this.titularInfo = data.eResponse.data && data.eResponse.data[0] ? data.eResponse.data[0] : null;
    },
    async onSubmit() {
      const action = this.isEdit ? 'update' : 'create';
      const params = { ...this.form };
      if (!this.isEdit) delete params.id_control;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, params } })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.$bvToast && this.$bvToast.toast(data.eResponse.message || 'Operación exitosa', { variant: 'success' });
        this.fetchRegistros();
        this.resetForm();
      } else {
        alert(data.eResponse.message || 'Error en la operación');
      }
    },
    editItem(item) {
      this.form = { ...item };
      this.isEdit = true;
      this.fetchTitularInfo();
    },
    async deleteItem(item) {
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'delete', params: { id_control: item.id_control } } })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.fetchRegistros();
        this.resetForm();
      } else {
        alert(data.eResponse.message || 'Error al eliminar');
      }
    },
    resetForm() {
      this.form = {
        id_control: null,
        id_rec: '',
        id_usu_titular: '',
        iniciales_titular: '',
        id_usu_elaboro: '',
        iniciales_elaboro: ''
      };
      this.isEdit = false;
      this.titularInfo = null;
    }
  }
};
</script>

<style scoped>
.elaboro-mntto-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  margin-bottom: 1.5rem;
}
</style>
