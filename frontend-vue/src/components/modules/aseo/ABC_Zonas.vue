<template>
  <div class="zonas-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Zonas</li>
      </ol>
    </nav>
    <h1>Catálogo de Zonas</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showCreateForm = true">Agregar Zona</button>
    </div>
    <table class="table table-bordered table-striped">
      <thead>
        <tr>
          <th>Control</th>
          <th>Zona</th>
          <th>Sub Zona</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="zona in zonas" :key="zona.ctrol_zona">
          <td>{{ zona.ctrol_zona }}</td>
          <td>{{ zona.zona }}</td>
          <td>{{ zona.sub_zona }}</td>
          <td>{{ zona.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="editZona(zona)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteZona(zona.ctrol_zona)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="zonas.length === 0">
          <td colspan="5" class="text-center">No hay zonas registradas.</td>
        </tr>
      </tbody>
    </table>

    <!-- Crear/Editar Formulario -->
    <div v-if="showCreateForm || showEditForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ showEditForm ? 'Editar Zona' : 'Agregar Zona' }}</h3>
          <form @submit.prevent="showEditForm ? updateZona() : createZona()">
            <div class="form-group">
              <label for="zona">Zona</label>
              <input type="number" v-model.number="form.zona" class="form-control" required />
            </div>
            <div class="form-group">
              <label for="sub_zona">Sub Zona</label>
              <input type="number" v-model.number="form.sub_zona" class="form-control" required />
            </div>
            <div class="form-group">
              <label for="descripcion">Descripción</label>
              <input type="text" v-model="form.descripcion" class="form-control" maxlength="80" required />
            </div>
            <div class="form-group text-right">
              <button type="submit" class="btn btn-success">{{ showEditForm ? 'Actualizar' : 'Crear' }}</button>
              <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Mensaje -->
    <div v-if="message" class="alert" :class="{'alert-success': messageType==='success', 'alert-danger': messageType==='error'}">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ZonasPage',
  data() {
    return {
      zonas: [],
      showCreateForm: false,
      showEditForm: false,
      form: {
        ctrol_zona: null,
        zona: '',
        sub_zona: '',
        descripcion: ''
      },
      message: '',
      messageType: 'success',
      loading: false
    };
  },
  mounted() {
    this.fetchZonas();
  },
  methods: {
    async fetchZonas() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'zonas.list' })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.zonas = data.data;
        } else {
          this.message = data.message;
          this.messageType = 'error';
        }
      } catch (e) {
        this.message = 'Error al cargar zonas';
        this.messageType = 'error';
      }
      this.loading = false;
    },
    async createZona() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'zonas.create',
            payload: {
              zona: this.form.zona,
              sub_zona: this.form.sub_zona,
              descripcion: this.form.descripcion
            }
          })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.message = 'Zona creada correctamente';
          this.messageType = 'success';
          this.closeForm();
          this.fetchZonas();
        } else {
          this.message = data.message;
          this.messageType = 'error';
        }
      } catch (e) {
        this.message = 'Error al crear zona';
        this.messageType = 'error';
      }
    },
    editZona(zona) {
      this.form = { ...zona };
      this.showEditForm = true;
      this.showCreateForm = false;
    },
    async updateZona() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'zonas.update',
            payload: {
              ctrol_zona: this.form.ctrol_zona,
              zona: this.form.zona,
              sub_zona: this.form.sub_zona,
              descripcion: this.form.descripcion
            }
          })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.message = 'Zona actualizada correctamente';
          this.messageType = 'success';
          this.closeForm();
          this.fetchZonas();
        } else {
          this.message = data.message;
          this.messageType = 'error';
        }
      } catch (e) {
        this.message = 'Error al actualizar zona';
        this.messageType = 'error';
      }
    },
    async deleteZona(ctrol_zona) {
      if (!confirm('¿Está seguro de eliminar esta zona?')) return;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'zonas.delete',
            payload: { ctrol_zona }
          })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.message = 'Zona eliminada correctamente';
          this.messageType = 'success';
          this.fetchZonas();
        } else {
          this.message = data.message;
          this.messageType = 'error';
        }
      } catch (e) {
        this.message = 'Error al eliminar zona';
        this.messageType = 'error';
      }
    },
    closeForm() {
      this.showCreateForm = false;
      this.showEditForm = false;
      this.form = {
        ctrol_zona: null,
        zona: '',
        sub_zona: '',
        descripcion: ''
      };
    }
  }
};
</script>

<style scoped>
.zonas-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
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
  width: 400px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
  padding: 2rem;
}
.alert {
  margin-top: 1rem;
}
</style>
