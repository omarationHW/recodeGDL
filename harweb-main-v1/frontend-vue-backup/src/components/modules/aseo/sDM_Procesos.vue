<template>
  <div class="procesos-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Procesos</li>
      </ol>
    </nav>
    <h1>Gestión de Procesos</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showCreateForm = true">Nuevo Proceso</button>
    </div>
    <div v-if="showCreateForm">
      <h3>Nuevo Proceso</h3>
      <form @submit.prevent="createProceso">
        <div class="mb-2">
          <label>Nombre</label>
          <input v-model="form.nombre" class="form-control" required />
        </div>
        <div class="mb-2">
          <label>Descripción</label>
          <textarea v-model="form.descripcion" class="form-control"></textarea>
        </div>
        <button class="btn btn-success" type="submit">Guardar</button>
        <button class="btn btn-secondary ms-2" @click="cancelForm">Cancelar</button>
      </form>
    </div>
    <div v-if="showEditForm">
      <h3>Editar Proceso</h3>
      <form @submit.prevent="updateProceso">
        <div class="mb-2">
          <label>Nombre</label>
          <input v-model="form.nombre" class="form-control" required />
        </div>
        <div class="mb-2">
          <label>Descripción</label>
          <textarea v-model="form.descripcion" class="form-control"></textarea>
        </div>
        <button class="btn btn-success" type="submit">Actualizar</button>
        <button class="btn btn-secondary ms-2" @click="cancelForm">Cancelar</button>
      </form>
    </div>
    <div v-if="!showCreateForm && !showEditForm">
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
          <tr v-for="proceso in procesos" :key="proceso.id">
            <td>{{ proceso.id }}</td>
            <td>{{ proceso.nombre }}</td>
            <td>{{ proceso.descripcion }}</td>
            <td>
              <button class="btn btn-sm btn-warning" @click="editProceso(proceso)">Editar</button>
              <button class="btn btn-sm btn-danger ms-2" @click="deleteProceso(proceso.id)">Eliminar</button>
            </td>
          </tr>
          <tr v-if="procesos.length === 0">
            <td colspan="4" class="text-center">No hay procesos registrados.</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="message" class="alert alert-info mt-2">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'ProcesosPage',
  data() {
    return {
      procesos: [],
      showCreateForm: false,
      showEditForm: false,
      form: {
        id: null,
        nombre: '',
        descripcion: ''
      },
      message: ''
    };
  },
  mounted() {
    this.fetchProcesos();
  },
  methods: {
    async fetchProcesos() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: { action: 'list' }
        })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        this.procesos = json.eResponse.data;
      } else {
        this.message = json.eResponse.message || 'Error al cargar procesos';
      }
    },
    async createProceso() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'create',
            data: {
              nombre: this.form.nombre,
              descripcion: this.form.descripcion
            }
          }
        })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        this.message = 'Proceso creado correctamente';
        this.showCreateForm = false;
        this.form = { id: null, nombre: '', descripcion: '' };
        this.fetchProcesos();
      } else {
        this.message = json.eResponse.message || 'Error al crear proceso';
      }
    },
    editProceso(proceso) {
      this.form = { ...proceso };
      this.showEditForm = true;
      this.showCreateForm = false;
      this.message = '';
    },
    async updateProceso() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'update',
            data: {
              id: this.form.id,
              nombre: this.form.nombre,
              descripcion: this.form.descripcion
            }
          }
        })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        this.message = 'Proceso actualizado correctamente';
        this.showEditForm = false;
        this.form = { id: null, nombre: '', descripcion: '' };
        this.fetchProcesos();
      } else {
        this.message = json.eResponse.message || 'Error al actualizar proceso';
      }
    },
    async deleteProceso(id) {
      if (!confirm('¿Está seguro de eliminar este proceso?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'delete',
            data: { id }
          }
        })
      });
      const json = await res.json();
      if (json.eResponse.success) {
        this.message = 'Proceso eliminado correctamente';
        this.fetchProcesos();
      } else {
        this.message = json.eResponse.message || 'Error al eliminar proceso';
      }
    },
    cancelForm() {
      this.showCreateForm = false;
      this.showEditForm = false;
      this.form = { id: null, nombre: '', descripcion: '' };
      this.message = '';
    }
  }
};
</script>

<style scoped>
.procesos-page {
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
