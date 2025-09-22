<template>
  <div class="gastos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Gastos</li>
      </ol>
    </nav>
    <h1>Catálogo de Gastos</h1>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-else>
      <form @submit.prevent="onSubmit">
        <div class="row mb-3">
          <div class="col-md-3">
            <label>Salario Diario Zona Metropol. Gdl.</label>
            <input type="number" step="0.01" v-model.number="form.sdzmg" class="form-control" required />
          </div>
          <div class="col-md-2">
            <label>% Req.</label>
            <input type="number" step="0.01" v-model.number="form.porc1_req" class="form-control" required />
          </div>
          <div class="col-md-2">
            <label>% Embargo</label>
            <input type="number" step="0.01" v-model.number="form.porc2_embargo" class="form-control" required />
          </div>
          <div class="col-md-2">
            <label>% Secuestro</label>
            <input type="number" step="0.01" v-model.number="form.porc3_secuestro" class="form-control" required />
          </div>
        </div>
        <div class="mb-3">
          <button type="submit" class="btn btn-primary me-2" :disabled="saving">{{ isEditing ? 'Actualizar' : 'Crear' }}</button>
          <button type="button" class="btn btn-secondary me-2" @click="onReset" :disabled="saving">Limpiar</button>
          <button type="button" class="btn btn-danger" @click="onDelete" :disabled="saving || !isEditing">Eliminar</button>
        </div>
      </form>
      <hr />
      <h3>Valores Actuales</h3>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Salario Diario</th>
            <th>% Req.</th>
            <th>% Embargo</th>
            <th>% Secuestro</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="current">
            <td>{{ current.sdzmg }}</td>
            <td>{{ current.porc1_req }}</td>
            <td>{{ current.porc2_embargo }}</td>
            <td>{{ current.porc3_secuestro }}</td>
          </tr>
          <tr v-else>
            <td colspan="4" class="text-center">Sin datos registrados</td>
          </tr>
        </tbody>
      </table>
      <div v-if="message" :class="{'alert': true, 'alert-success': success, 'alert-danger': !success}">{{ message }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'GastosPage',
  data() {
    return {
      loading: true,
      saving: false,
      isEditing: false,
      form: {
        sdzmg: '',
        porc1_req: '',
        porc2_embargo: '',
        porc3_secuestro: ''
      },
      current: null,
      message: '',
      success: true
    };
  },
  created() {
    this.fetchCurrent();
  },
  methods: {
    fetchCurrent() {
      this.loading = true;
      this.$axios.post('/api/execute', {
        action: 'gastos.list',
        payload: {}
      }).then(res => {
        if (res.data.success && res.data.data && res.data.data.length > 0) {
          this.current = res.data.data[0];
          this.isEditing = true;
          this.form = { ...this.current };
        } else {
          this.current = null;
          this.isEditing = false;
        }
        this.loading = false;
      }).catch(() => {
        this.loading = false;
        this.message = 'Error al cargar los datos.';
        this.success = false;
      });
    },
    onSubmit() {
      this.saving = true;
      const action = this.isEditing ? 'gastos.update' : 'gastos.create';
      this.$axios.post('/api/execute', {
        action,
        payload: { ...this.form }
      }).then(res => {
        this.saving = false;
        this.message = res.data.message || 'Operación realizada';
        this.success = !!res.data.success;
        if (res.data.success) {
          this.fetchCurrent();
        }
      }).catch(() => {
        this.saving = false;
        this.message = 'Error en la operación.';
        this.success = false;
      });
    },
    onReset() {
      if (this.current) {
        this.form = { ...this.current };
        this.isEditing = true;
      } else {
        this.form = {
          sdzmg: '',
          porc1_req: '',
          porc2_embargo: '',
          porc3_secuestro: ''
        };
        this.isEditing = false;
      }
      this.message = '';
    },
    onDelete() {
      if (!confirm('¿Está seguro de eliminar los datos de gastos?')) return;
      this.saving = true;
      this.$axios.post('/api/execute', {
        action: 'gastos.delete',
        payload: {}
      }).then(res => {
        this.saving = false;
        this.message = res.data.message || 'Eliminado correctamente';
        this.success = !!res.data.success;
        this.fetchCurrent();
      }).catch(() => {
        this.saving = false;
        this.message = 'Error al eliminar.';
        this.success = false;
      });
    }
  }
};
</script>

<style scoped>
.gastos-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
</style>
