<template>
  <div class="secciones-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Secciones</li>
      </ol>
    </nav>
    <h1>Catálogo de Secciones</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showCreate = true">Agregar Sección</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Sección</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in secciones" :key="row.seccion">
          <td>{{ row.seccion }}</td>
          <td>{{ row.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="editRow(row)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteRow(row.seccion)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <!-- Crear/Editar Modal -->
    <div v-if="showCreate || showEdit" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ showEdit ? 'Editar Sección' : 'Agregar Sección' }}</h3>
          <form @submit.prevent="showEdit ? updateSeccion() : createSeccion()">
            <div class="form-group">
              <label>Sección</label>
              <input v-model="form.seccion" :readonly="showEdit" maxlength="2" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input v-model="form.descripcion" maxlength="30" class="form-control" required />
            </div>
            <div class="form-group">
              <button class="btn btn-success" type="submit">Guardar</button>
              <button class="btn btn-secondary" type="button" @click="closeModal">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <!-- Mensaje -->
    <div v-if="message" class="alert alert-info mt-3">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'SeccionesPage',
  data() {
    return {
      secciones: [],
      showCreate: false,
      showEdit: false,
      form: {
        seccion: '',
        descripcion: ''
      },
      message: ''
    };
  },
  mounted() {
    this.loadSecciones();
  },
  methods: {
    async loadSecciones() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.secciones.list',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.secciones = res.data.data;
        } else {
          this.message = res.data.message;
        }
      } catch (error) {
        this.message = error.message;
      }
    },
    async createSeccion() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.secciones.create',
          payload: { ...this.form }
        });
        if (res.data.status === 'success') {
          this.message = 'Sección agregada correctamente';
          this.closeModal();
          this.loadSecciones();
        } else {
          this.message = res.data.message;
        }
      } catch (error) {
        this.message = error.message;
      }
    },
    editRow(row) {
      this.form = { ...row };
      this.showEdit = true;
      this.showCreate = false;
    },
    async updateSeccion() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.secciones.update',
          payload: { ...this.form }
        });
        if (res.data.status === 'success') {
          this.message = 'Sección actualizada correctamente';
          this.closeModal();
          this.loadSecciones();
        } else {
          this.message = res.data.message;
        }
      } catch (error) {
        this.message = error.message;
      }
    },
    async deleteRow(seccion) {
      if (!confirm('¿Está seguro de eliminar la sección ' + seccion + '?')) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.secciones.delete',
          payload: { seccion }
        });
        if (res.data.status === 'success') {
          this.message = 'Sección eliminada correctamente';
          this.loadSecciones();
        } else {
          this.message = res.data.message;
        }
      } catch (error) {
        this.message = error.message;
      }
    },
    closeModal() {
      this.showCreate = false;
      this.showEdit = false;
      this.form = { seccion: '', descripcion: '' };
    }
  }
};
</script>

<style scoped>
.secciones-page {
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
  width: 400px;
  background: #fff;
  border-radius: 8px;
  padding: 2rem;
}
</style>
