<template>
  <div class="colonias-mntto-page">
    <h1>Catálogo de Colonias</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Colonias</li>
      </ol>
    </nav>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-else>
      <form @submit.prevent="onSubmit">
        <div class="form-row">
          <div class="form-group col-md-2">
            <label for="colonia">Colonia</label>
            <input type="number" v-model.number="form.colonia" class="form-control" id="colonia" :readonly="editMode" required min="1" max="999" />
          </div>
          <div class="form-group col-md-6">
            <label for="descripcion">Descripción</label>
            <input type="text" v-model="form.descripcion" class="form-control" id="descripcion" maxlength="50" required />
          </div>
        </div>
        <div class="form-row">
          <div class="form-group col-md-4">
            <label for="id_rec">Recaudadora</label>
            <select v-model.number="form.id_rec" class="form-control" id="id_rec" required>
              <option value="">Seleccione...</option>
              <option v-for="rec in catalogs.recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                {{ rec.id_rec.toString().padStart(3, '0') }} - {{ rec.recaudadora }}
              </option>
            </select>
          </div>
          <div class="form-group col-md-4">
            <label for="id_zona">Zona</label>
            <select v-model.number="form.id_zona" class="form-control" id="id_zona" required>
              <option value="">Seleccione...</option>
              <option v-for="zona in catalogs.zonas" :key="zona.id_zona" :value="zona.id_zona">
                {{ zona.id_zona.toString().padStart(3, '0') }} - {{ zona.zona }}
              </option>
            </select>
          </div>
          <div class="form-group col-md-2">
            <label for="col_obra94">Col. Obra94</label>
            <input type="number" v-model.number="form.col_obra94" class="form-control" id="col_obra94" min="0" max="999" />
          </div>
        </div>
        <div class="form-row">
          <div class="form-group col-md-12">
            <button type="submit" class="btn btn-primary mr-2">{{ editMode ? 'Actualizar' : 'Agregar' }}</button>
            <button type="button" class="btn btn-secondary" @click="resetForm">Cancelar</button>
          </div>
        </div>
      </form>
      <hr />
      <h2>Listado de Colonias</h2>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Colonia</th>
            <th>Descripción</th>
            <th>Recaudadora</th>
            <th>Zona</th>
            <th>Col. Obra94</th>
            <th>Usuario</th>
            <th>Fecha Actualización</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="col in colonias" :key="col.colonia">
            <td>{{ col.colonia }}</td>
            <td>{{ col.descripcion }}</td>
            <td>{{ col.id_rec.toString().padStart(3, '0') }} - {{ col.recaudadora || '' }}</td>
            <td>{{ col.id_zona.toString().padStart(3, '0') }} - {{ col.zona || '' }}</td>
            <td>{{ col.col_obra94 }}</td>
            <td>{{ col.usuario }}</td>
            <td>{{ formatDate(col.fecha_actual) }}</td>
            <td>
              <button class="btn btn-sm btn-info" @click="editColonia(col)">Editar</button>
              <button class="btn btn-sm btn-danger" @click="deleteColonia(col.colonia)">Eliminar</button>
            </td>
          </tr>
          <tr v-if="colonias.length === 0">
            <td colspan="8" class="text-center">No hay registros</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="alert.message" :class="['alert', alert.success ? 'alert-success' : 'alert-danger']">
      {{ alert.message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ColoniasMnttoPage',
  data() {
    return {
      loading: true,
      colonias: [],
      catalogs: {
        recaudadoras: [],
        zonas: []
      },
      form: {
        colonia: '',
        descripcion: '',
        id_rec: '',
        id_zona: '',
        col_obra94: ''
      },
      editMode: false,
      alert: {
        message: '',
        success: true
      }
    };
  },
  created() {
    this.fetchCatalogs();
    this.fetchColonias();
  },
  methods: {
    async fetchCatalogs() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.colonias.catalogs',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.catalogs = res.data.data;
        }
      } catch (error) {
        console.error('Error loading catalogs:', error);
      }
      this.loading = false;
    },
    async fetchColonias() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.colonias.list',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.colonias = res.data.data;
        }
      } catch (error) {
        console.error('Error loading colonias:', error);
      }
      this.loading = false;
    },
    async onSubmit() {
      this.alert.message = '';
      const action = this.editMode ? 'colonias.update' : 'colonias.create';
      const payload = { ...this.form };
      if (!payload.colonia || !payload.descripcion || !payload.id_rec || !payload.id_zona) {
        this.alert = { message: 'Todos los campos obligatorios deben estar completos', success: false };
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: `convenios.${action}`,
          payload: payload
        });
        if (res.data.status === 'success') {
          this.alert = { message: res.data.message || 'Operación exitosa', success: true };
          this.resetForm();
          this.fetchColonias();
        } else {
          this.alert = { message: res.data.message || 'Error en la operación', success: false };
        }
      } catch (error) {
        this.alert = { message: 'Error de conexión con el servidor', success: false };
      }
    },
    editColonia(col) {
      this.form = {
        colonia: col.colonia,
        descripcion: col.descripcion,
        id_rec: col.id_rec,
        id_zona: col.id_zona,
        col_obra94: col.col_obra94
      };
      this.editMode = true;
      this.alert.message = '';
    },
    async deleteColonia(colonia) {
      if (!confirm('¿Está seguro de eliminar la colonia ' + colonia + '?')) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.colonias.delete',
          payload: { colonia }
        });
        if (res.data.status === 'success') {
          this.alert = { message: res.data.message || 'Eliminado correctamente', success: true };
          this.fetchColonias();
        } else {
          this.alert = { message: res.data.message || 'Error al eliminar', success: false };
        }
      } catch (error) {
        this.alert = { message: 'Error de conexión con el servidor', success: false };
      }
    },
    resetForm() {
      this.form = {
        colonia: '',
        descripcion: '',
        id_rec: '',
        id_zona: '',
        col_obra94: ''
      };
      this.editMode = false;
    },
    formatDate(dt) {
      if (!dt) return '';
      return new Date(dt).toLocaleString();
    }
  }
};
</script>

<style scoped>
.colonias-mntto-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
