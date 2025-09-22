<template>
  <div class="page-mannto-operaciones">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo Claves de Operación</li>
      </ol>
    </nav>
    <h2>Catálogo de Claves de Operación</h2>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showForm('create')">Nueva Clave</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th># Control</th>
          <th>Clave</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in operaciones" :key="item.ctrol_operacion">
          <td>{{ item.ctrol_operacion }}</td>
          <td>{{ item.cve_operacion }}</td>
          <td>{{ item.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="showForm('update', item)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="confirmDelete(item)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <!-- Modal Form -->
    <div v-if="modalVisible" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3 v-if="formMode==='create'">Nueva Clave de Operación</h3>
          <h3 v-else-if="formMode==='update'">Editar Clave de Operación</h3>
          <form @submit.prevent="submitForm">
            <div class="form-group">
              <label>Clave de Operación</label>
              <input v-model="form.cve_operacion" maxlength="1" class="form-control" :readonly="formMode==='update'" required />
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input v-model="form.descripcion" maxlength="80" class="form-control" required />
            </div>
            <div class="form-group text-right">
              <button type="submit" class="btn btn-success">Guardar</button>
              <button type="button" class="btn btn-secondary" @click="closeModal">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <!-- Modal Delete -->
    <div v-if="deleteModalVisible" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h4>¿Está seguro de eliminar la clave <b>{{ deleteItem.cve_operacion }}</b>?</h4>
          <div class="alert alert-warning" v-if="deleteError">{{ deleteError }}</div>
          <div class="text-right">
            <button class="btn btn-danger" @click="deleteItemConfirm">Eliminar</button>
            <button class="btn btn-secondary" @click="closeDeleteModal">Cancelar</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'ManntoOperacionesPage',
  data() {
    return {
      operaciones: [],
      error: '',
      success: '',
      modalVisible: false,
      formMode: 'create',
      form: {
        cve_operacion: '',
        descripcion: ''
      },
      deleteModalVisible: false,
      deleteItem: {},
      deleteError: ''
    }
  },
  mounted() {
    this.loadOperaciones();
  },
  methods: {
    async apiRequest(action, data = {}) {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action, data } })
        });
        const json = await res.json();
        return json.eResponse;
      } catch (e) {
        return { success: false, message: e.message };
      }
    },
    async loadOperaciones() {
      this.error = '';
      const resp = await this.apiRequest('list');
      if (resp.success !== false) {
        this.operaciones = resp.data;
      } else {
        this.error = resp.message || 'Error al cargar datos';
      }
    },
    showForm(mode, item = null) {
      this.formMode = mode;
      if (mode === 'create') {
        this.form = { cve_operacion: '', descripcion: '' };
      } else if (mode === 'update' && item) {
        this.form = { cve_operacion: item.cve_operacion, descripcion: item.descripcion };
      }
      this.modalVisible = true;
      this.error = '';
      this.success = '';
    },
    closeModal() {
      this.modalVisible = false;
      this.form = { cve_operacion: '', descripcion: '' };
    },
    async submitForm() {
      this.error = '';
      this.success = '';
      if (!this.form.cve_operacion || !this.form.descripcion) {
        this.error = 'Todos los campos son obligatorios';
        return;
      }
      let resp;
      if (this.formMode === 'create') {
        resp = await this.apiRequest('create', this.form);
      } else {
        resp = await this.apiRequest('update', this.form);
      }
      if (resp.success) {
        this.success = resp.message || 'Operación exitosa';
        this.closeModal();
        this.loadOperaciones();
      } else {
        this.error = resp.message || 'Error en la operación';
      }
    },
    confirmDelete(item) {
      this.deleteItem = item;
      this.deleteModalVisible = true;
      this.deleteError = '';
    },
    closeDeleteModal() {
      this.deleteModalVisible = false;
      this.deleteItem = {};
    },
    async deleteItemConfirm() {
      this.deleteError = '';
      // Check usage before delete
      const usage = await this.apiRequest('check_usage', { ctrol_operacion: this.deleteItem.ctrol_operacion });
      if (usage.success && usage.in_use) {
        this.deleteError = 'No se puede eliminar: existen pagos asociados a esta clave.';
        return;
      }
      const resp = await this.apiRequest('delete', { ctrol_operacion: this.deleteItem.ctrol_operacion });
      if (resp.success) {
        this.success = resp.message || 'Eliminado correctamente';
        this.closeDeleteModal();
        this.loadOperaciones();
      } else {
        this.deleteError = resp.message || 'Error al eliminar';
      }
    }
  }
}
</script>

<style scoped>
.page-mannto-operaciones {
  max-width: 900px;
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
  width: 400px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
  padding: 2rem;
}
</style>
