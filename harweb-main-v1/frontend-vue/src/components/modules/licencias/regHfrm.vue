<template>
  <div class="reg-historic-page">
    <h1>Registros Históricos</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Registros Históricos
    </div>
    <div class="actions">
      <button @click="showCreateForm = true">Nuevo Registro Histórico</button>
    </div>
    <div v-if="showCreateForm" class="form-modal">
      <h2>Agregar Registro Histórico</h2>
      <form @submit.prevent="createRecord">
        <label>Año (axocomp): <input v-model.number="form.axocomp" type="number" required /></label>
        <label>No. Comp. (nocomp): <input v-model.number="form.nocomp" type="number" required /></label>
        <label>Clave Cuenta (cvecuenta): <input v-model.number="form.cvecuenta" type="number" required /></label>
        <!-- Agregar más campos según sea necesario -->
        <div class="form-actions">
          <button type="submit">Guardar</button>
          <button type="button" @click="showCreateForm = false">Cancelar</button>
        </div>
      </form>
    </div>
    <div v-if="showEditForm" class="form-modal">
      <h2>Editar Registro Histórico</h2>
      <form @submit.prevent="updateRecord">
        <label>Año (axocomp): <input v-model.number="form.axocomp" type="number" required disabled /></label>
        <label>No. Comp. (nocomp): <input v-model.number="form.nocomp" type="number" required disabled /></label>
        <label>Clave Cuenta (cvecuenta): <input v-model.number="form.cvecuenta" type="number" required disabled /></label>
        <!-- Agregar más campos según sea necesario -->
        <div class="form-actions">
          <button type="submit">Actualizar</button>
          <button type="button" @click="showEditForm = false">Cancelar</button>
        </div>
      </form>
    </div>
    <div class="table-container">
      <table class="historic-table">
        <thead>
          <tr>
            <th>Año</th>
            <th>No. Comp.</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in records" :key="row.axocomp + '-' + row.nocomp">
            <td>{{ row.axocomp }}</td>
            <td>{{ row.nocomp }}</td>
            <td>
              <button @click="editRecord(row)">Editar</button>
              <button @click="deleteRecord(row)">Eliminar</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div v-if="loading">Cargando...</div>
      <div v-if="error" class="error">{{ error }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RegHistoricPage',
  data() {
    return {
      records: [],
      loading: false,
      error: '',
      showCreateForm: false,
      showEditForm: false,
      form: {
        axocomp: '',
        nocomp: '',
        cvecuenta: ''
        // Otros campos si es necesario
      },
      editKey: null,
      cvecuentaFilter: '' // Para filtrar por cuenta
    }
  },
  created() {
    // Por defecto, pedir al usuario la cuenta o usar una cuenta de prueba
    this.cvecuentaFilter = this.$route.query.cvecuenta || '';
    if (this.cvecuentaFilter) {
      this.fetchRecords();
    }
  },
  methods: {
    async fetchRecords() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.get_historic_records',
          payload: { cvecuenta: this.cvecuentaFilter }
        });
        if (res.data.status === 'success') {
          this.records = res.data.eResponse.data.result;
        } else {
          this.error = res.data.message || 'Error al cargar registros';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    async createRecord() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.create_historic_record',
          payload: { ...this.form }
        });
        if (res.data.status === 'success') {
          this.showCreateForm = false;
          this.fetchRecords();
        } else {
          this.error = res.data.message || 'Error al crear registro';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    editRecord(row) {
      this.form = { ...row };
      this.showEditForm = true;
      this.editKey = {
        cvecuenta: row.cvecuenta,
        axocomp: row.axocomp,
        nocomp: row.nocomp
      };
    },
    async updateRecord() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.update_historic_record',
          payload: { ...this.form, ...this.editKey }
        });
        if (res.data.status === 'success') {
          this.showEditForm = false;
          this.fetchRecords();
        } else {
          this.error = res.data.message || 'Error al actualizar registro';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    async deleteRecord(row) {
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.delete_historic_record',
          payload: {
            cvecuenta: row.cvecuenta,
            axocomp: row.axocomp,
            nocomp: row.nocomp
          }
        });
        if (res.data.status === 'success') {
          this.fetchRecords();
        } else {
          this.error = res.data.message || 'Error al eliminar registro';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.reg-historic-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.actions {
  margin-bottom: 1rem;
}
.table-container {
  margin-top: 2rem;
}
.historic-table {
  width: 100%;
  border-collapse: collapse;
}
.historic-table th, .historic-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.form-modal {
  background: #f9f9f9;
  border: 1px solid #ccc;
  padding: 1rem;
  margin-bottom: 2rem;
}
.error {
  color: red;
  margin-top: 1rem;
}
</style>
