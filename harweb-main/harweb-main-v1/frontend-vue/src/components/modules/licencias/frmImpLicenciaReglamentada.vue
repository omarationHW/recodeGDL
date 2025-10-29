<template>
  <div class="imp-licencia-reglamentada-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Licencias Reglamentadas</li>
      </ol>
    </nav>
    <h1>Licencias Reglamentadas</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showCreateForm = true">Nueva Licencia</button>
    </div>
    <div v-if="showCreateForm" class="card mb-4">
      <div class="card-body">
        <h5 class="card-title">Crear Licencia Reglamentada</h5>
        <form @submit.prevent="createLicencia">
          <div class="mb-3">
            <label class="form-label">Nombre</label>
            <input v-model="form.nombre" type="text" class="form-control" required />
          </div>
          <div class="mb-3">
            <label class="form-label">Descripción</label>
            <textarea v-model="form.descripcion" class="form-control" required></textarea>
          </div>
          <div class="mb-3">
            <label class="form-label">Usuario ID</label>
            <input v-model="form.usuario_id" type="number" class="form-control" required />
          </div>
          <button type="submit" class="btn btn-success">Guardar</button>
          <button type="button" class="btn btn-secondary ms-2" @click="resetForm">Cancelar</button>
        </form>
      </div>
    </div>
    <div v-if="showEditForm" class="card mb-4">
      <div class="card-body">
        <h5 class="card-title">Editar Licencia Reglamentada</h5>
        <form @submit.prevent="updateLicencia">
          <div class="mb-3">
            <label class="form-label">Nombre</label>
            <input v-model="form.nombre" type="text" class="form-control" required />
          </div>
          <div class="mb-3">
            <label class="form-label">Descripción</label>
            <textarea v-model="form.descripcion" class="form-control" required></textarea>
          </div>
          <div class="mb-3">
            <label class="form-label">Usuario ID</label>
            <input v-model="form.usuario_id" type="number" class="form-control" required />
          </div>
          <button type="submit" class="btn btn-success">Actualizar</button>
          <button type="button" class="btn btn-secondary ms-2" @click="resetForm">Cancelar</button>
        </form>
      </div>
    </div>
    <div v-if="message" class="alert alert-info">{{ message }}</div>
    <table class="table table-bordered">
      <thead>
        <tr>
          <th>ID</th>
          <th>Nombre</th>
          <th>Descripción</th>
          <th>Usuario ID</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="lic in licencias" :key="lic.id">
          <td>{{ lic.id }}</td>
          <td>{{ lic.nombre }}</td>
          <td>{{ lic.descripcion }}</td>
          <td>{{ lic.usuario_id }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="editLicencia(lic)">Editar</button>
            <button class="btn btn-sm btn-danger ms-2" @click="deleteLicencia(lic.id)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="licencias.length === 0">
          <td colspan="5" class="text-center">No hay licencias registradas.</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  name: 'ImpLicenciaReglamentadaPage',
  data() {
    return {
      licencias: [],
      showCreateForm: false,
      showEditForm: false,
      form: {
        id: null,
        nombre: '',
        descripcion: '',
        usuario_id: ''
      },
      message: ''
    };
  },
  mounted() {
    this.fetchLicencias();
  },
  methods: {
    async fetchLicencias() {
      try {
        const res = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: 'getLicenciasReglamentadas' })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.licencias = data.eResponse.data;
        } else {
          this.message = data.eResponse.message || 'Error al cargar licencias.';
        }
      } catch (e) {
        this.message = 'Error de conexión.';
      }
    },
    async createLicencia() {
      try {
        const res = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'createLicenciaReglamentada',
            params: {
              nombre: this.form.nombre,
              descripcion: this.form.descripcion,
              usuario_id: this.form.usuario_id
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.message = 'Licencia creada correctamente.';
          this.fetchLicencias();
          this.resetForm();
        } else {
          this.message = data.eResponse.message || 'Error al crear licencia.';
        }
      } catch (e) {
        this.message = 'Error de conexión.';
      }
    },
    editLicencia(lic) {
      this.form = { ...lic };
      this.showEditForm = true;
      this.showCreateForm = false;
    },
    async updateLicencia() {
      try {
        const res = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'updateLicenciaReglamentada',
            params: {
              id: this.form.id,
              nombre: this.form.nombre,
              descripcion: this.form.descripcion,
              usuario_id: this.form.usuario_id
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.message = 'Licencia actualizada correctamente.';
          this.fetchLicencias();
          this.resetForm();
        } else {
          this.message = data.eResponse.message || 'Error al actualizar licencia.';
        }
      } catch (e) {
        this.message = 'Error de conexión.';
      }
    },
    async deleteLicencia(id) {
      if (!confirm('¿Está seguro de eliminar esta licencia?')) return;
      try {
        const res = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'deleteLicenciaReglamentada',
            params: { id }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.message = 'Licencia eliminada correctamente.';
          this.fetchLicencias();
        } else {
          this.message = data.eResponse.message || 'Error al eliminar licencia.';
        }
      } catch (e) {
        this.message = 'Error de conexión.';
      }
    },
    resetForm() {
      this.form = { id: null, nombre: '', descripcion: '', usuario_id: '' };
      this.showCreateForm = false;
      this.showEditForm = false;
    }
  }
};
</script>

<style scoped>
.imp-licencia-reglamentada-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
