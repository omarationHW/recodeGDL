<template>
  <div class="rubros-page">
    <h1>Rubros de Ingreso</h1>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-else>
      <div class="section">
        <h2>Rubros Existentes</h2>
        <table class="table table-bordered">
          <thead>
            <tr>
              <th>ID</th>
              <th>Clave</th>
              <th>Nombre</th>
              <th>Cajero</th>
              <th>Auto Tab</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="rubro in rubros" :key="rubro.id_34_tab">
              <td>{{ rubro.id_34_tab }}</td>
              <td>{{ rubro.cve_tab }}</td>
              <td>{{ rubro.nombre }}</td>
              <td>{{ rubro.cajero }}</td>
              <td>{{ rubro.auto_tab }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="section">
        <h2>Crear Nuevo Rubro</h2>
        <form @submit.prevent="submitRubro">
          <div class="form-group">
            <label for="nombre">Nombre de la Tabla</label>
            <input v-model="form.nombre" id="nombre" maxlength="50" class="form-control" required />
          </div>
          <div class="form-group">
            <label>Status para el Rubro</label>
            <div class="status-list">
              <div v-for="status in statusCatalog" :key="status.cve_stat">
                <input type="checkbox" :id="'stat_' + status.cve_stat" :value="status" v-model="form.status_selected" />
                <label :for="'stat_' + status.cve_stat">{{ status.cve_stat }} - {{ status.descripcion }}</label>
              </div>
            </div>
          </div>
          <div class="form-actions">
            <button type="submit" class="btn btn-primary" :disabled="submitting">Ejecutar</button>
            <button type="button" class="btn btn-secondary" @click="resetForm">Limpiar</button>
          </div>
        </form>
        <div v-if="message" :class="{'alert': true, 'alert-success': success, 'alert-danger': !success}">{{ message }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RubrosPage',
  data() {
    return {
      loading: true,
      submitting: false,
      rubros: [],
      statusCatalog: [],
      form: {
        nombre: '',
        status_selected: []
      },
      message: '',
      success: false
    };
  },
  created() {
    this.fetchData();
  },
  methods: {
    async fetchData() {
      this.loading = true;
      try {
        const [rubrosRes, statusRes] = await Promise.all([
          this.$axios.post('/api/execute', { action: 'getRubros' }),
          this.$axios.post('/api/execute', { action: 'getStatusCatalog' })
        ]);
        this.rubros = rubrosRes.data.data || [];
        this.statusCatalog = statusRes.data.data || [];
      } catch (e) {
        this.message = 'Error cargando datos: ' + (e.response?.data?.message || e.message);
        this.success = false;
      } finally {
        this.loading = false;
      }
    },
    async submitRubro() {
      if (!this.form.nombre.trim()) {
        this.message = 'El nombre es obligatorio';
        this.success = false;
        return;
      }
      if (!this.form.status_selected.length) {
        this.message = 'Debe seleccionar al menos un status';
        this.success = false;
        return;
      }
      this.submitting = true;
      this.message = '';
      try {
        const payload = {
          action: 'createRubro',
          params: {
            nombre: this.form.nombre.trim(),
            status_selected: this.form.status_selected.map(s => ({
              cve_stat: s.cve_stat,
              descripcion: s.descripcion
            }))
          }
        };
        const res = await this.$axios.post('/api/execute', payload);
        if (res.data.success) {
          this.message = res.data.message || 'Rubro creado correctamente';
          this.success = true;
          this.resetForm();
          this.fetchData();
        } else {
          this.message = res.data.message || 'Error al crear rubro';
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error: ' + (e.response?.data?.message || e.message);
        this.success = false;
      } finally {
        this.submitting = false;
      }
    },
    resetForm() {
      this.form.nombre = '';
      this.form.status_selected = [];
    }
  }
};
</script>

<style scoped>
.rubros-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.section {
  margin-bottom: 2rem;
}
.status-list {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}
.form-actions {
  margin-top: 1rem;
}
.loading {
  font-size: 1.2rem;
  color: #888;
}
.alert {
  margin-top: 1rem;
  padding: 0.75rem 1rem;
  border-radius: 4px;
}
.alert-success {
  background: #e6ffe6;
  color: #1a7f1a;
}
.alert-danger {
  background: #ffe6e6;
  color: #a11a1a;
}
</style>
