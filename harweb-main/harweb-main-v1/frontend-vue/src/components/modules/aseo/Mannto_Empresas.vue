<template>
  <div class="empresas-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Empresas</li>
      </ol>
    </nav>
    <h2>Mantenimiento de Empresas</h2>
    <div class="card mb-4">
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-2">
              <label for="num_empresa">Número</label>
              <input v-model="form.num_empresa" :disabled="mode !== 'create'" type="number" class="form-control" id="num_empresa" />
            </div>
            <div class="col-md-5">
              <label for="ctrol_emp">Tipo de Empresa</label>
              <select v-model="form.ctrol_emp" class="form-control" id="ctrol_emp" :disabled="mode === 'delete' || mode === 'update'">
                <option v-for="tipo in tiposEmp" :key="tipo.ctrol_emp" :value="tipo.ctrol_emp">
                  {{ tipo.ctrol_emp }} - {{ tipo.tipo_empresa }} - {{ tipo.descripcion }}
                </option>
              </select>
            </div>
          </div>
          <div class="mb-3">
            <label for="descripcion">Nombre o Razón Social</label>
            <input v-model="form.descripcion" type="text" class="form-control" id="descripcion" maxlength="80" :disabled="mode === 'delete'" />
          </div>
          <div class="mb-3">
            <label for="representante">Representante</label>
            <input v-model="form.representante" type="text" class="form-control" id="representante" maxlength="80" :disabled="mode === 'delete'" />
          </div>
          <div class="mb-3">
            <button v-if="mode === 'create'" type="submit" class="btn btn-success">Crear</button>
            <button v-if="mode === 'update'" type="submit" class="btn btn-primary">Actualizar</button>
            <button v-if="mode === 'delete'" type="submit" class="btn btn-danger">Eliminar</button>
            <button type="button" class="btn btn-secondary ms-2" @click="resetForm">Cancelar</button>
          </div>
        </form>
      </div>
    </div>
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <span>Listado de Empresas</span>
        <button class="btn btn-outline-primary btn-sm" @click="fetchEmpresas">Refrescar</button>
      </div>
      <div class="card-body p-0">
        <table class="table table-striped mb-0">
          <thead>
            <tr>
              <th>#</th>
              <th>Tipo</th>
              <th>Nombre</th>
              <th>Representante</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="emp in empresas" :key="emp.num_empresa + '-' + emp.ctrol_emp">
              <td>{{ emp.num_empresa }}</td>
              <td>{{ emp.ctrol_emp }}</td>
              <td>{{ emp.descripcion }}</td>
              <td>{{ emp.representante }}</td>
              <td>
                <button class="btn btn-sm btn-primary me-1" @click="editEmpresa(emp)">Editar</button>
                <button class="btn btn-sm btn-danger" @click="deleteEmpresa(emp)">Eliminar</button>
              </td>
            </tr>
            <tr v-if="empresas.length === 0">
              <td colspan="5" class="text-center">No hay empresas registradas.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="alert.message" :class="['alert', alert.success ? 'alert-success' : 'alert-danger', 'mt-3']">
      {{ alert.message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'EmpresasPage',
  data() {
    return {
      empresas: [],
      tiposEmp: [],
      form: {
        num_empresa: '',
        ctrol_emp: '',
        descripcion: '',
        representante: ''
      },
      mode: 'create', // create | update | delete
      alert: {
        message: '',
        success: true
      }
    };
  },
  mounted() {
    this.fetchTiposEmp();
    this.fetchEmpresas();
  },
  methods: {
    async fetchEmpresas() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'empresas.list' })
      });
      const data = await res.json();
      this.empresas = data.data || [];
    },
    async fetchTiposEmp() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'tipos_emp.list' })
      });
      const data = await res.json();
      this.tiposEmp = data.data || [];
    },
    async onSubmit() {
      let action = '';
      let payload = { ...this.form };
      if (this.mode === 'create') {
        action = 'empresas.create';
        delete payload.num_empresa;
      } else if (this.mode === 'update') {
        action = 'empresas.update';
      } else if (this.mode === 'delete') {
        action = 'empresas.delete';
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, payload })
      });
      const data = await res.json();
      this.alert.message = data.message || (data.success ? 'Operación exitosa' : 'Error en la operación');
      this.alert.success = !!data.success;
      if (data.success) {
        this.resetForm();
        this.fetchEmpresas();
      }
    },
    editEmpresa(emp) {
      this.form = { ...emp };
      this.mode = 'update';
    },
    deleteEmpresa(emp) {
      if (confirm('¿Está seguro de eliminar esta empresa?')) {
        this.form = { ...emp };
        this.mode = 'delete';
        this.onSubmit();
      }
    },
    resetForm() {
      this.form = {
        num_empresa: '',
        ctrol_emp: '',
        descripcion: '',
        representante: ''
      };
      this.mode = 'create';
    }
  }
};
</script>

<style scoped>
.empresas-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  margin-bottom: 2rem;
}
</style>
