<template>
  <div class="page-unidades-recoleccion">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Unidades de Recolección</li>
      </ol>
    </nav>
    <h1>Catálogo de Unidades de Recolección</h1>
    <div class="mb-3">
      <label for="ejercicio" class="form-label">Ejercicio</label>
      <input v-model="ejercicio" type="number" class="form-control" id="ejercicio" min="2000" max="2100" />
      <button class="btn btn-primary mt-2" @click="fetchList">Buscar</button>
      <button class="btn btn-success mt-2 ms-2" @click="showCreateForm = true">Agregar Unidad</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Control</th>
          <th>Ejercicio</th>
          <th>Clave</th>
          <th>Descripción</th>
          <th>Costo Unidad</th>
          <th>Costo Excedente</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="unidad in unidades" :key="unidad.ctrol_recolec">
          <td>{{ unidad.ctrol_recolec }}</td>
          <td>{{ unidad.ejercicio_recolec }}</td>
          <td>{{ unidad.cve_recolec }}</td>
          <td>{{ unidad.descripcion }}</td>
          <td>{{ unidad.costo_unidad }}</td>
          <td>{{ unidad.costo_exed }}</td>
          <td>
            <button class="btn btn-sm btn-warning me-1" @click="editUnidad(unidad)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteUnidad(unidad.ctrol_recolec)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Crear/Editar Modal -->
    <div v-if="showCreateForm || showEditForm" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ showCreateForm ? 'Agregar Unidad' : 'Editar Unidad' }}</h5>
            <button type="button" class="btn-close" @click="closeForm"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="showCreateForm ? createUnidad() : updateUnidad()">
              <div class="mb-3">
                <label class="form-label">Ejercicio</label>
                <input v-model="form.ejercicio_recolec" type="number" class="form-control" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Clave</label>
                <input v-model="form.cve_recolec" type="text" maxlength="1" class="form-control" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Descripción</label>
                <input v-model="form.descripcion" type="text" class="form-control" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Costo Unidad</label>
                <input v-model="form.costo_unidad" type="number" step="0.01" class="form-control" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Costo Excedente</label>
                <input v-model="form.costo_exed" type="number" step="0.01" class="form-control" required />
              </div>
              <div class="modal-footer">
                <button type="submit" class="btn btn-primary">Guardar</button>
                <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'UnidadesRecoleccionPage',
  data() {
    return {
      ejercicio: new Date().getFullYear(),
      unidades: [],
      showCreateForm: false,
      showEditForm: false,
      form: {
        ctrol_recolec: null,
        ejercicio_recolec: '',
        cve_recolec: '',
        descripcion: '',
        costo_unidad: '',
        costo_exed: ''
      },
      error: ''
    };
  },
  mounted() {
    this.fetchList();
  },
  methods: {
    async fetchList() {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'list_unidades_recoleccion',
          payload: { ejercicio: this.ejercicio }
        });
        if (res.data.status === 'success') {
          this.unidades = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar unidades.';
        }
      } catch (error) {
        this.error = 'Error de conexión: ' + error.message;
      }
    },
    closeForm() {
      this.showCreateForm = false;
      this.showEditForm = false;
      this.form = {
        ctrol_recolec: null,
        ejercicio_recolec: '',
        cve_recolec: '',
        descripcion: '',
        costo_unidad: '',
        costo_exed: ''
      };
    },
    editUnidad(unidad) {
      this.form = { ...unidad };
      this.showEditForm = true;
      this.showCreateForm = false;
    },
    async createUnidad() {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'create_unidad_recoleccion',
          payload: {
            ejercicio_recolec: this.form.ejercicio_recolec,
            cve_recolec: this.form.cve_recolec,
            descripcion: this.form.descripcion,
            costo_unidad: this.form.costo_unidad,
            costo_exed: this.form.costo_exed
          }
        });
        if (res.data.status === 'success') {
          this.fetchList();
          this.closeForm();
        } else {
          this.error = res.data.message || 'Error al crear unidad.';
        }
      } catch (error) {
        this.error = 'Error de conexión: ' + error.message;
      }
    },
    async updateUnidad() {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'update_unidad_recoleccion',
          payload: {
            ctrol_recolec: this.form.ctrol_recolec,
            ejercicio_recolec: this.form.ejercicio_recolec,
            cve_recolec: this.form.cve_recolec,
            descripcion: this.form.descripcion,
            costo_unidad: this.form.costo_unidad,
            costo_exed: this.form.costo_exed
          }
        });
        if (res.data.status === 'success') {
          this.fetchList();
          this.closeForm();
        } else {
          this.error = res.data.message || 'Error al actualizar unidad.';
        }
      } catch (error) {
        this.error = 'Error de conexión: ' + error.message;
      }
    },
    async deleteUnidad(ctrol_recolec) {
      if (!confirm('¿Está seguro de eliminar esta unidad?')) return;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'delete_unidad_recoleccion',
          payload: { ctrol_recolec }
        });
        if (res.data.status === 'success') {
          this.fetchList();
        } else {
          this.error = res.data.message || 'Error al eliminar unidad.';
        }
      } catch (error) {
        this.error = 'Error de conexión: ' + error.message;
      }
    }
  }
};
</script>

<style scoped>
.page-unidades-recoleccion {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
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
.modal-dialog {
  background: #fff;
  border-radius: 8px;
  max-width: 500px;
  width: 100%;
  box-shadow: 0 2px 16px rgba(0,0,0,0.2);
}
</style>
