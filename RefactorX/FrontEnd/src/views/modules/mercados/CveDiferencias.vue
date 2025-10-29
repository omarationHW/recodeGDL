<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info">
        <h1>Clave de Diferencias</h1>
        <p>Mercados - Clave de Diferencias</p>
      </div>
    </div>

    <div class="module-view-content">
    <h2>Clave de Diferencias</h2>
    <div class="mb-3">
      <button class="btn btn-municipal-primary me-2" @click="showAddModal = true">Agregar</button>
      <button class="btn btn-municipal-secondary me-2" :disabled="!selectedRow" @click="showEditModal = true">Modificar</button>
      <button class="btn btn-outline-secondary" @click="fetchData">Refrescar</button>
    </div>
    <table class="-striped municipal-table-hover">
      <thead>
        <tr>
          <th>Clave</th>
          <th>Descripción</th>
          <th>Cuenta Ingreso</th>
          <th>Usuario</th>
          <th>Fecha Actual</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in rows" :key="row.clave_diferencia" :class="{ 'table-active': selectedRow && selectedRow.clave_diferencia === row.clave_diferencia }" @click="selectRow(row)">
          <td>{{ row.clave_diferencia }}</td>
          <td>{{ row.descripcion }}</td>
          <td>{{ row.cuenta_ingreso }}</td>
          <td>{{ row.usuario }}</td>
          <td>{{ formatDate(row.fecha_actual) }}</td>
        </tr>
      </tbody>
    </table>

    <!-- Add Modal -->
    <b-modal v-model="showAddModal" title="Agregar Clave de Diferencia" @ok="addCveDiferencia">
      <form @submit.prevent="addCveDiferencia">
        <div class="mb-3">
          <label class="municipal-form-label">Descripción</label>
          <input v-model="form.descripcion" type="text" class="municipal-form-control" maxlength="60" required />
        </div>
        <div class="mb-3">
          <label class="municipal-form-label">Cuenta Ingreso</label>
          <select v-model="form.cuenta_ingreso" class="municipal-form-control" required>
            <option v-for="cuenta in cuentasIngreso" :key="cuenta.cta_aplicacion" :value="cuenta.cta_aplicacion">
              {{ cuenta.cta_aplicacion }} - {{ cuenta.descripcion }}
            </option>
          </select>
        </div>
      </form>
    </b-modal>

    <!-- Edit Modal -->
    <b-modal v-model="showEditModal" title="Modificar Clave de Diferencia" @ok="updateCveDiferencia">
      <form @submit.prevent="updateCveDiferencia">
        <div class="mb-3">
          <label class="municipal-form-label">Descripción</label>
          <input v-model="form.descripcion" type="text" class="municipal-form-control" maxlength="60" required />
        </div>
        <div class="mb-3">
          <label class="municipal-form-label">Cuenta Ingreso</label>
          <select v-model="form.cuenta_ingreso" class="municipal-form-control" required>
            <option v-for="cuenta in cuentasIngreso" :key="cuenta.cta_aplicacion" :value="cuenta.cta_aplicacion">
              {{ cuenta.cta_aplicacion }} - {{ cuenta.descripcion }}
            </option>
          </select>
        </div>
      </form>
    </b-modal>

    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
import axios from 'axios';
export default {
  name: 'CveDiferenciasPage',
  data() {
    return {
      rows: [],
      cuentasIngreso: [],
      selectedRow: null,
      showAddModal: false,
      showEditModal: false,
      form: {
        descripcion: '',
        cuenta_ingreso: ''
      },
      error: ''
    };
  },
  mounted() {
    this.fetchData();
    this.fetchCuentasIngreso();
  },
  methods: {
    fetchData() {
      axios.post('/api/execute', {
        eRequest: { action: 'getCveDiferencias' }
      }).then(res => {
        this.rows = res.data.eResponse.data;
      }).catch(err => {
        this.error = err.response?.data?.eResponse?.message || err.message;
      });
    },
    fetchCuentasIngreso() {
      axios.post('/api/execute', {
        eRequest: { action: 'getCuentasIngreso' }
      }).then(res => {
        this.cuentasIngreso = res.data.eResponse.data;
      });
    },
    selectRow(row) {
      this.selectedRow = row;
      this.form.descripcion = row.descripcion;
      this.form.cuenta_ingreso = row.cuenta_ingreso;
    },
    addCveDiferencia() {
      axios.post('/api/execute', {
        eRequest: {
          action: 'addCveDiferencia',
          params: {
            descripcion: this.form.descripcion,
            cuenta_ingreso: this.form.cuenta_ingreso,
            id_usuario: this.$store.state.user.id_usuario // Asume Vuex auth
          }
        }
      }).then(() => {
        this.showAddModal = false;
        this.fetchData();
      }).catch(err => {
        this.error = err.response?.data?.eResponse?.message || err.message;
      });
    },
    updateCveDiferencia() {
      if (!this.selectedRow) return;
      axios.post('/api/execute', {
        eRequest: {
          action: 'updateCveDiferencia',
          params: {
            clave_diferencia: this.selectedRow.clave_diferencia,
            descripcion: this.form.descripcion,
            cuenta_ingreso: this.form.cuenta_ingreso,
            id_usuario: this.$store.state.user.id_usuario
          }
        }
      }).then(() => {
        this.showEditModal = false;
        this.fetchData();
      }).catch(err => {
        this.error = err.response?.data?.eResponse?.message || err.message;
      });
    },
    formatDate(dt) {
      if (!dt) return '';
      return new Date(dt).toLocaleString();
    }
  }
};
</script>

<style scoped>
.cve-diferencias-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table-hover tbody tr:hover {
  background-color: #f5f5f5;
  cursor: pointer;
}
</style>
