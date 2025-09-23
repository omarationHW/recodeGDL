<template>
  <div class="tipos-emp-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo Tipos de Empresa</li>
      </ol>
    </nav>
    <h1>Catálogo de Tipos de Empresa</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showCreateForm = true">Agregar Tipo</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Control</th>
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
            <button class="btn btn-sm btn-warning" @click="editTipo(item)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteTipo(item.ctrol_emp)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Crear/Editar Modal -->
    <div v-if="showCreateForm || showEditForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ showEditForm ? 'Editar Tipo de Empresa' : 'Agregar Tipo de Empresa' }}</h3>
          <form @submit.prevent="showEditForm ? updateTipo() : createTipo()">
            <div class="form-group">
              <label for="ctrol_emp">Control</label>
              <input v-model="form.ctrol_emp" :readonly="showEditForm" type="number" class="form-control" required />
            </div>
            <div class="form-group">
              <label for="tipo_empresa">Tipo</label>
              <input v-model="form.tipo_empresa" maxlength="1" class="form-control" required />
            </div>
            <div class="form-group">
              <label for="descripcion">Descripción</label>
              <input v-model="form.descripcion" class="form-control" required />
            </div>
            <div class="form-group mt-3">
              <button type="submit" class="btn btn-success">Guardar</button>
              <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'TiposEmpPage',
  data() {
    return {
      tiposEmp: [],
      showCreateForm: false,
      showEditForm: false,
      form: {
        ctrol_emp: '',
        tipo_empresa: '',
        descripcion: ''
      },
      error: '',
      success: ''
    };
  },
  mounted() {
    this.fetchTiposEmp();
  },
  methods: {
    async fetchTiposEmp() {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'list_tipos_emp'
        });
        if (res.data.success) {
          this.tiposEmp = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar datos';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async createTipo() {
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'create_tipos_emp',
          payload: { ...this.form }
        });
        if (res.data.success) {
          this.success = 'Tipo de empresa creado correctamente';
          this.closeForm();
          this.fetchTiposEmp();
        } else {
          this.error = res.data.message || 'Error al crear';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    editTipo(item) {
      this.form = { ...item };
      this.showEditForm = true;
      this.showCreateForm = false;
    },
    async updateTipo() {
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'update_tipos_emp',
          payload: { ...this.form }
        });
        if (res.data.success) {
          this.success = 'Tipo de empresa actualizado correctamente';
          this.closeForm();
          this.fetchTiposEmp();
        } else {
          this.error = res.data.message || 'Error al actualizar';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async deleteTipo(ctrol_emp) {
      if (!confirm('¿Está seguro de eliminar este tipo de empresa?')) return;
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'delete_tipos_emp',
          payload: { ctrol_emp }
        });
        if (res.data.success) {
          this.success = 'Tipo de empresa eliminado correctamente';
          this.fetchTiposEmp();
        } else {
          this.error = res.data.message || 'Error al eliminar';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    closeForm() {
      this.showCreateForm = false;
      this.showEditForm = false;
      this.form = { ctrol_emp: '', tipo_empresa: '', descripcion: '' };
    }
  }
};
</script>

<style scoped>
.tipos-emp-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-wrapper {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  min-width: 350px;
  max-width: 400px;
}
</style>
