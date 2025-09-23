<template>
  <div class="tipos-emp-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Tipos de Empresa</li>
      </ol>
    </nav>
    <h2>Catálogo de Tipos de Empresa</h2>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showForm('create')">Nuevo Tipo de Empresa</button>
    </div>
    <table class="table table-bordered table-hover">
      <thead>
        <tr>
          <th># Control</th>
          <th>Tipo</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in tiposEmp" :key="item.ctrol_emp">
          <td>{{ item.ctrol_emp }}</td>
          <td>{{ item.tipo_empresa }}</td>
          <td>{{ item.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-info" @click="showForm('edit', item)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="confirmDelete(item)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="tiposEmp.length === 0">
          <td colspan="4" class="text-center">No hay registros</td>
        </tr>
      </tbody>
    </table>

    <!-- Modal Form -->
    <div v-if="formVisible" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3 v-if="formMode==='create'">Nuevo Tipo de Empresa</h3>
          <h3 v-else>Editar Tipo de Empresa</h3>
          <form @submit.prevent="submitForm">
            <div class="form-group">
              <label>Tipo de Empresa</label>
              <input v-model="form.tipo_empresa" :disabled="formMode==='edit'" maxlength="1" required class="form-control" />
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input v-model="form.descripcion" maxlength="80" required class="form-control" />
            </div>
            <div class="form-group text-right">
              <button type="submit" class="btn btn-success">Guardar</button>
              <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <!-- End Modal -->
  </div>
</template>

<script>
export default {
  name: 'TiposEmpPage',
  data() {
    return {
      tiposEmp: [],
      formVisible: false,
      formMode: 'create', // 'create' | 'edit'
      form: {
        tipo_empresa: '',
        descripcion: ''
      },
      editingItem: null
    };
  },
  created() {
    this.loadTiposEmp();
  },
  methods: {
    async loadTiposEmp() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: 'TiposEmp.list' })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        this.tiposEmp = json.eResponse.data;
      } else {
        alert('Error al cargar tipos de empresa: ' + json.eResponse.message);
      }
    },
    showForm(mode, item = null) {
      this.formMode = mode;
      this.formVisible = true;
      if (mode === 'edit' && item) {
        this.form.tipo_empresa = item.tipo_empresa;
        this.form.descripcion = item.descripcion;
        this.editingItem = item;
      } else {
        this.form.tipo_empresa = '';
        this.form.descripcion = '';
        this.editingItem = null;
      }
    },
    closeForm() {
      this.formVisible = false;
    },
    async submitForm() {
      if (!this.form.tipo_empresa || !this.form.descripcion) {
        alert('Todos los campos son obligatorios');
        return;
      }
      let eRequest = this.formMode === 'create' ? 'TiposEmp.create' : 'TiposEmp.update';
      let params = {
        tipo_empresa: this.form.tipo_empresa,
        descripcion: this.form.descripcion
      };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest, params })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        this.closeForm();
        this.loadTiposEmp();
      } else {
        alert('Error: ' + json.eResponse.message);
      }
    },
    async confirmDelete(item) {
      // Check if can delete
      const resCheck = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: 'TiposEmp.canDelete', params: { ctrol_emp: item.ctrol_emp } })
      });
      const jsonCheck = await resCheck.json();
      if (!jsonCheck.eResponse.data.can_delete) {
        alert('No se puede eliminar: existen empresas asociadas a este tipo.');
        return;
      }
      if (confirm('¿Está seguro de eliminar este tipo de empresa?')) {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: 'TiposEmp.delete', params: { ctrol_emp: item.ctrol_emp } })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.loadTiposEmp();
        } else {
          alert('Error: ' + json.eResponse.message);
        }
      }
    }
  }
};
</script>

<style scoped>
.tipos-emp-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-wrapper {
  width: 100%;
  max-width: 400px;
}
.modal-container {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
</style>
