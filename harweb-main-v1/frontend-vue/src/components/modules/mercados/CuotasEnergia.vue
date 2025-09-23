<template>
  <div class="cuotas-energia-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Cuotas de Energía Eléctrica</li>
      </ol>
    </nav>
    <h1>Cuotas de Energía Eléctrica</h1>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showCreate = true">Agregar Cuota</button>
    </div>
    <div v-if="showCreate || editRow" class="card mb-4">
      <div class="card-body">
        <h5 v-if="!editRow">Agregar Nueva Cuota</h5>
        <h5 v-else>Modificar Cuota</h5>
        <form @submit.prevent="editRow ? updateCuota() : createCuota()">
          <div class="row">
            <div class="col-md-3">
              <label>Año</label>
              <input type="number" v-model.number="form.axo" class="form-control" required min="2000" max="2100">
            </div>
            <div class="col-md-3">
              <label>Periodo</label>
              <input type="number" v-model.number="form.periodo" class="form-control" required min="1" max="12">
            </div>
            <div class="col-md-3">
              <label>Importe</label>
              <input type="number" v-model.number="form.importe" class="form-control" step="0.000001" min="0.000001" required>
            </div>
          </div>
          <div class="mt-3">
            <button type="submit" class="btn btn-success">{{ editRow ? 'Guardar Cambios' : 'Agregar' }}</button>
            <button type="button" class="btn btn-secondary" @click="cancelForm">Cancelar</button>
          </div>
        </form>
      </div>
    </div>
    <div class="table-responsive">
      <table class="table table-striped table-hover">
        <thead>
          <tr>
            <th>Control</th>
            <th>Año</th>
            <th>Periodo</th>
            <th>Importe</th>
            <th>Fecha de Alta</th>
            <th>Usuario</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in cuotas" :key="row.id_kilowhatts">
            <td>{{ row.id_kilowhatts }}</td>
            <td>{{ row.axo }}</td>
            <td>{{ row.periodo }}</td>
            <td>{{ row.importe | currency }}</td>
            <td>{{ row.fecha_alta | datetime }}</td>
            <td>{{ row.usuario }}</td>
            <td>
              <button class="btn btn-sm btn-info" @click="editCuota(row)">Editar</button>
              <button class="btn btn-sm btn-danger" @click="deleteCuota(row)">Eliminar</button>
            </td>
          </tr>
          <tr v-if="cuotas.length === 0">
            <td colspan="7" class="text-center">No hay cuotas registradas.</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'CuotasEnergiaPage',
  data() {
    return {
      cuotas: [],
      showCreate: false,
      editRow: null,
      form: {
        axo: new Date().getFullYear(),
        periodo: 1,
        importe: null
      },
      error: '',
      success: ''
    };
  },
  created() {
    this.fetchCuotas();
  },
  methods: {
    async fetchCuotas() {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'list',
          params: {},
          module: 'cuotas_energia'
        });
        if (res.data.success) {
          this.cuotas = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar cuotas';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async createCuota() {
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'create',
          params: this.form,
          module: 'cuotas_energia'
        });
        if (res.data.success) {
          this.success = 'Cuota agregada correctamente';
          this.showCreate = false;
          this.resetForm();
          this.fetchCuotas();
        } else {
          this.error = res.data.message || 'Error al agregar cuota';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    editCuota(row) {
      this.editRow = row;
      this.form = {
        id_kilowhatts: row.id_kilowhatts,
        axo: row.axo,
        periodo: row.periodo,
        importe: row.importe
      };
      this.showCreate = false;
      this.error = '';
      this.success = '';
    },
    async updateCuota() {
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'update',
          params: this.form,
          module: 'cuotas_energia'
        });
        if (res.data.success) {
          this.success = 'Cuota modificada correctamente';
          this.editRow = null;
          this.resetForm();
          this.fetchCuotas();
        } else {
          this.error = res.data.message || 'Error al modificar cuota';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async deleteCuota(row) {
      if (!confirm('¿Está seguro de eliminar la cuota seleccionada?')) return;
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'delete',
          params: { id_kilowhatts: row.id_kilowhatts },
          module: 'cuotas_energia'
        });
        if (res.data.success) {
          this.success = 'Cuota eliminada correctamente';
          this.fetchCuotas();
        } else {
          this.error = res.data.message || 'Error al eliminar cuota';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    cancelForm() {
      this.showCreate = false;
      this.editRow = null;
      this.resetForm();
    },
    resetForm() {
      this.form = {
        axo: new Date().getFullYear(),
        periodo: 1,
        importe: null
      };
    }
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 6 });
    },
    datetime(val) {
      if (!val) return '';
      return new Date(val).toLocaleString('es-MX');
    }
  }
};
</script>

<style scoped>
.cuotas-energia-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.card {
  border: 1px solid #e3e3e3;
  border-radius: 6px;
}
</style>
