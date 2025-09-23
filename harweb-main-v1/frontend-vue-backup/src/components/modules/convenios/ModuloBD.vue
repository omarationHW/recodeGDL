<template>
  <div class="modulo-bd-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Tipos</li>
      </ol>
    </nav>
    <h1>Catálogo de Tipos</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showAddModal = true">Agregar Tipo</button>
    </div>
    <table class="table table-bordered">
      <thead>
        <tr>
          <th>ID</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="tipo in tipos" :key="tipo.tipo">
          <td>{{ tipo.tipo }}</td>
          <td>{{ tipo.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="editTipo(tipo)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteTipo(tipo.tipo)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Modal Agregar -->
    <div v-if="showAddModal" class="modal-backdrop">
      <div class="modal-content">
        <h3>Agregar Tipo</h3>
        <form @submit.prevent="addTipo">
          <div class="form-group">
            <label>Descripción</label>
            <input v-model="newTipo.descripcion" class="form-control" required maxlength="50" />
          </div>
          <div class="mt-3">
            <button class="btn btn-success" type="submit">Guardar</button>
            <button class="btn btn-secondary" @click="showAddModal = false">Cancelar</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Editar -->
    <div v-if="showEditModal" class="modal-backdrop">
      <div class="modal-content">
        <h3>Editar Tipo</h3>
        <form @submit.prevent="updateTipo">
          <div class="form-group">
            <label>ID</label>
            <input v-model="editTipoData.tipo" class="form-control" disabled />
          </div>
          <div class="form-group">
            <label>Descripción</label>
            <input v-model="editTipoData.descripcion" class="form-control" required maxlength="50" />
          </div>
          <div class="mt-3">
            <button class="btn btn-success" type="submit">Actualizar</button>
            <button class="btn btn-secondary" @click="showEditModal = false">Cancelar</button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ModuloBDTiposPage',
  data() {
    return {
      tipos: [],
      showAddModal: false,
      showEditModal: false,
      newTipo: { descripcion: '' },
      editTipoData: { tipo: '', descripcion: '' },
      error: null
    };
  },
  mounted() {
    this.fetchTipos();
  },
  methods: {
    async fetchTipos() {
      this.error = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: { action: 'getTipos' }
          })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.tipos = json.eResponse.data;
        } else {
          this.error = json.eResponse.error || 'Error al cargar tipos';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async addTipo() {
      this.error = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'addTipo',
              params: { descripcion: this.newTipo.descripcion }
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.showAddModal = false;
          this.newTipo.descripcion = '';
          this.fetchTipos();
        } else {
          this.error = json.eResponse.error || 'Error al agregar tipo';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    editTipo(tipo) {
      this.editTipoData = { ...tipo };
      this.showEditModal = true;
    },
    async updateTipo() {
      this.error = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'updateTipo',
              params: {
                tipo: this.editTipoData.tipo,
                descripcion: this.editTipoData.descripcion
              }
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.showEditModal = false;
          this.fetchTipos();
        } else {
          this.error = json.eResponse.error || 'Error al actualizar tipo';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async deleteTipo(tipoId) {
      if (!confirm('¿Está seguro de eliminar este tipo?')) return;
      this.error = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'deleteTipo',
              params: { tipo: tipoId }
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.fetchTipos();
        } else {
          this.error = json.eResponse.error || 'Error al eliminar tipo';
        }
      } catch (e) {
        this.error = e.message;
      }
    }
  }
};
</script>

<style scoped>
.modulo-bd-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-content {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  min-width: 350px;
  max-width: 400px;
}
</style>
