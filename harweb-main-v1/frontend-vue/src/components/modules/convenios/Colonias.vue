<template>
  <div class="colonias-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Colonias</li>
      </ol>
    </nav>
    <h1>Catálogo de Colonias</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="openForm('create')">Agregar Colonia</button>
      <button class="btn btn-secondary ml-2" @click="fetchColonias">Refrescar</button>
      <button class="btn btn-info ml-2" @click="printReport">Imprimir Catálogo</button>
    </div>
    <table class="table table-striped table-bordered">
      <thead>
        <tr>
          <th>Colonia</th>
          <th>Descripción</th>
          <th>Rec</th>
          <th>Zona</th>
          <th>Zona (desc)</th>
          <th>Col. Obra94</th>
          <th>Usuario</th>
          <th>Fecha Actual</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="col in colonias" :key="col.colonia">
          <td>{{ col.colonia }}</td>
          <td>{{ col.descripcion }}</td>
          <td>{{ col.id_rec }}</td>
          <td>{{ col.id_zona }}</td>
          <td>{{ col.zona }}</td>
          <td>{{ col.col_obra94 }}</td>
          <td>{{ col.usuario }}</td>
          <td>{{ formatDate(col.fecha_actual) }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="openForm('edit', col)">Editar</button>
            <button class="btn btn-sm btn-danger ml-1" @click="deleteColonia(col.colonia)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Modal Form -->
    <div v-if="showForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ formMode === 'create' ? 'Agregar Colonia' : 'Editar Colonia' }}</h3>
          <form @submit.prevent="submitForm">
            <div class="form-group">
              <label>Código Colonia</label>
              <input v-model.number="form.colonia" :disabled="formMode==='edit'" type="number" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input v-model="form.descripcion" type="text" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Recaudadora (id_rec)</label>
              <input v-model.number="form.id_rec" type="number" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Zona (id_zona)</label>
              <input v-model.number="form.id_zona" type="number" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Colonia Obra94</label>
              <input v-model.number="form.col_obra94" type="number" class="form-control" />
            </div>
            <div class="form-group">
              <label>ID Usuario</label>
              <input v-model.number="form.id_usuario" type="number" class="form-control" required />
            </div>
            <div class="form-group text-right">
              <button type="submit" class="btn btn-success">Guardar</button>
              <button type="button" class="btn btn-secondary ml-2" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Report Modal -->
    <div v-if="showReport" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>Reporte de Colonias</h3>
          <pre style="max-height:400px;overflow:auto;">{{ JSON.stringify(reportData, null, 2) }}</pre>
          <button class="btn btn-secondary" @click="showReport=false">Cerrar</button>
        </div>
      </div>
    </div>

    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ColoniasPage',
  data() {
    return {
      colonias: [],
      showForm: false,
      formMode: 'create',
      form: {
        colonia: '',
        descripcion: '',
        id_rec: '',
        id_zona: '',
        col_obra94: '',
        id_usuario: ''
      },
      error: '',
      showReport: false,
      reportData: null
    };
  },
  created() {
    this.fetchColonias();
  },
  methods: {
    async fetchColonias() {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.colonias.list',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.colonias = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar colonias';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      }
    },
    openForm(mode, col = null) {
      this.formMode = mode;
      if (mode === 'edit' && col) {
        this.form = { ...col };
      } else {
        this.form = {
          colonia: '', descripcion: '', id_rec: '', id_zona: '', col_obra94: '', id_usuario: ''
        };
      }
      this.showForm = true;
    },
    closeForm() {
      this.showForm = false;
      this.error = '';
    },
    async submitForm() {
      this.error = '';
      let action = this.formMode === 'create' ? 'colonias.create' : 'colonias.update';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: `convenios.${action}`,
          payload: this.form
        });
        if (res.data.status === 'success') {
          this.fetchColonias();
          this.showForm = false;
        } else {
          this.error = res.data.message || 'Error al guardar';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      }
    },
    async deleteColonia(colonia) {
      if (!confirm('¿Está seguro de eliminar la colonia ' + colonia + '?')) return;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.colonias.delete',
          payload: { colonia }
        });
        if (res.data.status === 'success') {
          this.fetchColonias();
        } else {
          this.error = res.data.message || 'Error al eliminar';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      }
    },
    async printReport() {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.colonias.report',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.reportData = res.data.data;
          this.showReport = true;
        } else {
          this.error = res.data.message || 'Error al generar reporte';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      }
    },
    formatDate(dt) {
      if (!dt) return '';
      return new Date(dt).toLocaleString();
    }
  }
};
</script>

<style scoped>
.colonias-page { max-width: 1100px; margin: 0 auto; padding: 2rem; }
.modal-mask {
  position: fixed; z-index: 9998; top: 0; left: 0; width: 100vw; height: 100vh;
  background-color: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center;
}
.modal-wrapper { width: 100%; max-width: 500px; }
.modal-container { background: #fff; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 8px #0002; }
</style>
