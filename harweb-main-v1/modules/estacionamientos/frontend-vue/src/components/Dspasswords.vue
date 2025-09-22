<template>
  <div class="passwords-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Gestión de Passwords</li>
      </ol>
    </nav>
    <h1>Gestión de Passwords</h1>
    <div class="mb-3">
      <input v-model="searchUsuario" @keyup.enter="fetchPasswords" placeholder="Buscar por usuario" class="form-control" />
      <button @click="fetchPasswords" class="btn btn-primary mt-2">Buscar</button>
      <button @click="showCreateForm = true" class="btn btn-success mt-2 ml-2">Nuevo</button>
    </div>
    <table class="table table-bordered">
      <thead>
        <tr>
          <th>ID Usuario</th>
          <th>Usuario</th>
          <th>Nombre</th>
          <th>Estado</th>
          <th>ID Rec</th>
          <th>Nivel</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in passwords" :key="row.id_usuario">
          <td>{{ row.id_usuario }}</td>
          <td>{{ row.usuario }}</td>
          <td>{{ row.nombre }}</td>
          <td>{{ row.estado }}</td>
          <td>{{ row.id_rec }}</td>
          <td>{{ row.nivel }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="editPassword(row)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deletePassword(row.id_usuario)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="passwords.length === 0">
          <td colspan="7" class="text-center">No hay registros</td>
        </tr>
      </tbody>
    </table>

    <!-- Crear/Editar Formulario -->
    <div v-if="showCreateForm || showEditForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ showEditForm ? 'Editar Password' : 'Nuevo Password' }}</h3>
          <form @submit.prevent="showEditForm ? updatePassword() : createPassword()">
            <div class="form-group">
              <label>Usuario</label>
              <input v-model="form.usuario" required class="form-control" />
            </div>
            <div class="form-group">
              <label>Nombre</label>
              <input v-model="form.nombre" required class="form-control" />
            </div>
            <div class="form-group">
              <label>Estado</label>
              <input v-model="form.estado" maxlength="1" required class="form-control" />
            </div>
            <div class="form-group">
              <label>ID Rec</label>
              <input v-model.number="form.id_rec" type="number" required class="form-control" />
            </div>
            <div class="form-group">
              <label>Nivel</label>
              <input v-model.number="form.nivel" type="number" required class="form-control" />
            </div>
            <div class="mt-3">
              <button type="submit" class="btn btn-primary">Guardar</button>
              <button type="button" class="btn btn-secondary ml-2" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <div v-if="errorMessage" class="alert alert-danger mt-3">{{ errorMessage }}</div>
    <div v-if="successMessage" class="alert alert-success mt-3">{{ successMessage }}</div>
  </div>
</template>

<script>
export default {
  name: 'PasswordsPage',
  data() {
    return {
      passwords: [],
      searchUsuario: '',
      showCreateForm: false,
      showEditForm: false,
      form: {
        id_usuario: null,
        usuario: '',
        nombre: '',
        estado: '',
        id_rec: null,
        nivel: null
      },
      errorMessage: '',
      successMessage: ''
    };
  },
  mounted() {
    this.fetchPasswords();
  },
  methods: {
    async fetchPasswords() {
      this.errorMessage = '';
      this.successMessage = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.passwords.list',
          payload: { usuario: this.searchUsuario }
        });
        if (res.data.status === 'success') {
          this.passwords = res.data.data || [];
        } else {
          this.errorMessage = res.data.message || 'Error al cargar datos';
        }
      } catch (error) {
        this.errorMessage = 'Error de conexión con el servidor';
      }
    },
    closeForm() {
      this.showCreateForm = false;
      this.showEditForm = false;
      this.resetForm();
    },
    resetForm() {
      this.form = {
        id_usuario: null,
        usuario: '',
        nombre: '',
        estado: '',
        id_rec: null,
        nivel: null
      };
    },
    async createPassword() {
      this.errorMessage = '';
      this.successMessage = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.passwords.create',
          payload: {
            usuario: this.form.usuario,
            nombre: this.form.nombre,
            estado: this.form.estado,
            id_rec: this.form.id_rec,
            nivel: this.form.nivel
          }
        });
        if (res.data.status === 'success') {
          this.successMessage = 'Registro creado correctamente';
          this.closeForm();
          this.fetchPasswords();
        } else {
          this.errorMessage = res.data.message || 'Error al crear registro';
        }
      } catch (error) {
        this.errorMessage = 'Error de conexión con el servidor';
      }
    },
    editPassword(row) {
      this.form = { ...row };
      this.showEditForm = true;
    },
    async updatePassword() {
      this.errorMessage = '';
      this.successMessage = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.passwords.update',
          payload: {
            id_usuario: this.form.id_usuario,
            usuario: this.form.usuario,
            nombre: this.form.nombre,
            estado: this.form.estado,
            id_rec: this.form.id_rec,
            nivel: this.form.nivel
          }
        });
        if (res.data.status === 'success') {
          this.successMessage = 'Registro actualizado correctamente';
          this.closeForm();
          this.fetchPasswords();
        } else {
          this.errorMessage = res.data.message || 'Error al actualizar registro';
        }
      } catch (error) {
        this.errorMessage = 'Error de conexión con el servidor';
      }
    },
    async deletePassword(id_usuario) {
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      this.errorMessage = '';
      this.successMessage = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.passwords.delete',
          payload: { id_usuario }
        });
        if (res.data.status === 'success') {
          this.successMessage = 'Registro eliminado correctamente';
          this.fetchPasswords();
        } else {
          this.errorMessage = res.data.message || 'Error al eliminar registro';
        }
      } catch (error) {
        this.errorMessage = 'Error de conexión con el servidor';
      }
    }
  }
};
</script>

<style scoped>
.passwords-page {
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
}
.modal-container {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.33);
}
</style>
