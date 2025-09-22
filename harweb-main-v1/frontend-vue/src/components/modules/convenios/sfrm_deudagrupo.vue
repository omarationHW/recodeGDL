<template>
  <div class="deudagrupo-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Deuda Grupo</li>
      </ol>
    </nav>
    <h1>Gestión de Deuda Grupo</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showCreateForm = true">Nuevo Grupo</button>
    </div>
    <div v-if="showCreateForm">
      <h3>Nuevo Grupo</h3>
      <form @submit.prevent="createGrupo">
        <div class="mb-2">
          <label>Nombre</label>
          <input v-model="form.nombre" class="form-control" required />
        </div>
        <div class="mb-2">
          <label>Descripción</label>
          <input v-model="form.descripcion" class="form-control" />
        </div>
        <button class="btn btn-success" type="submit">Guardar</button>
        <button class="btn btn-secondary" @click="cancelForm" type="button">Cancelar</button>
      </form>
    </div>
    <div v-if="showEditForm">
      <h3>Editar Grupo</h3>
      <form @submit.prevent="updateGrupo">
        <div class="mb-2">
          <label>Nombre</label>
          <input v-model="form.nombre" class="form-control" required />
        </div>
        <div class="mb-2">
          <label>Descripción</label>
          <input v-model="form.descripcion" class="form-control" />
        </div>
        <button class="btn btn-success" type="submit">Actualizar</button>
        <button class="btn btn-secondary" @click="cancelForm" type="button">Cancelar</button>
      </form>
    </div>
    <div v-if="message" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">
      {{ message }}
    </div>
    <table class="table table-bordered mt-3">
      <thead>
        <tr>
          <th>ID</th>
          <th>Nombre</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="grupo in grupos" :key="grupo.id">
          <td>{{ grupo.id }}</td>
          <td>{{ grupo.nombre }}</td>
          <td>{{ grupo.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-info" @click="editGrupo(grupo)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteGrupo(grupo.id)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="grupos.length === 0">
          <td colspan="4" class="text-center">No hay registros</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  name: 'DeudaGrupoPage',
  data() {
    return {
      grupos: [],
      form: {
        id: null,
        nombre: '',
        descripcion: ''
      },
      showCreateForm: false,
      showEditForm: false,
      message: '',
      success: true
    };
  },
  mounted() {
    this.fetchGrupos();
  },
  methods: {
    fetchGrupos() {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'list' } })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse.success) {
            this.grupos = json.eResponse.data;
          } else {
            this.message = json.eResponse.message;
            this.success = false;
          }
        });
    },
    createGrupo() {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'create', data: this.form } })
      })
        .then(res => res.json())
        .then(json => {
          this.message = json.eResponse.message;
          this.success = json.eResponse.success;
          if (json.eResponse.success) {
            this.fetchGrupos();
            this.cancelForm();
          }
        });
    },
    editGrupo(grupo) {
      this.form = { ...grupo };
      this.showEditForm = true;
      this.showCreateForm = false;
    },
    updateGrupo() {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'update', data: this.form } })
      })
        .then(res => res.json())
        .then(json => {
          this.message = json.eResponse.message;
          this.success = json.eResponse.success;
          if (json.eResponse.success) {
            this.fetchGrupos();
            this.cancelForm();
          }
        });
    },
    deleteGrupo(id) {
      if (!confirm('¿Está seguro de eliminar este grupo?')) return;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'delete', data: { id } } })
      })
        .then(res => res.json())
        .then(json => {
          this.message = json.eResponse.message;
          this.success = json.eResponse.success;
          if (json.eResponse.success) {
            this.fetchGrupos();
          }
        });
    },
    cancelForm() {
      this.form = { id: null, nombre: '', descripcion: '' };
      this.showCreateForm = false;
      this.showEditForm = false;
    }
  }
};
</script>

<style scoped>
.deudagrupo-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
