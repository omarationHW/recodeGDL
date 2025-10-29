<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Cuotas Energia</h1>
        <p>Mercados - Gestión de Energía</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="cuotas-energia-page">
          <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
              <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
              <li class="breadcrumb-item active" aria-current="page">Cuotas de Energía Eléctrica</li>
            </ol>
          </nav>
          <h1>Cuotas de Energía Eléctrica</h1>
          <div class="mb-3">
            <button class="btn-municipal-primary" @click="showCreate = true">Agregar Cuota</button>
          </div>
          <div v-if="showCreate || editRow" class="municipal-card">
            <div class="municipal-card">
              <h5 v-if="!editRow">Agregar Nueva Cuota</h5>
              <h5 v-else>Modificar Cuota</h5>
              <form @submit.prevent="editRow ? updateCuota() : createCuota()">
                <div class="row">
                  <div class="col-md-3">
                    <label>Año</label>
                    <input type="number" v-model.number="form.axo" class="municipal-form-control" required min="2000" max="2100">
                  </div>
                  <div class="col-md-3">
                    <label>Periodo</label>
                    <input type="number" v-model.number="form.periodo" class="municipal-form-control" required min="1" max="12">
                  </div>
                  <div class="col-md-3">
                    <label>Importe</label>
                    <input type="number" v-model.number="form.importe" class="municipal-form-control" step="0.000001" min="0.000001" required>
                  </div>
                </div>
                <div class="mt-3">
                  <button type="submit" class="btn btn-success">{{ editRow ? 'Guardar Cambios' : 'Agregar' }}</button>
                  <button type="button" class="btn-municipal-secondary" @click="cancelForm">Cancelar</button>
                </div>
              </form>
            </div>
          </div>
          <div class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
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
                <tr v-for="row in cuotas" :key="row.id_kilowhatts" class="row-hover">
                  <td>{{ row.id_kilowhatts }}</td>
                  <td>{{ row.axo }}</td>
                  <td>{{ row.periodo }}</td>
                  <td>{{ row.importe | currency }}</td>
                  <td>{{ row.fecha_alta | datetime }}</td>
                  <td>{{ row.usuario }}</td>
                  <td>
                    <button class="btn-municipal-info" @click="editCuota(row)">Editar</button>
                    <button class="btn btn-sm btn-danger" @click="deleteCuota(row)">Eliminar</button>
                  </td>
                </tr>
                <tr v-if="cuotas.length === 0" class="row-hover">
                  <td colspan="7" class="text-center">No hay cuotas registradas.</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
          <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'CuotasEnergia'"
      :moduleName="'mercados'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

export default {
  components: {
    DocumentationModal
  },
  name: 'CuotasEnergiaPage',
  data() {
    return {
      cuotas: [],
      showCreate: false,
      editRow: null,
      form: {
        axo: new Date().getFullYear(),
        periodo: 1,
        importe: null,
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }},
      error: '',
      success: ''
    };
  },
  created() {
    this.fetchCuotas();
  },
  methods: {
    openDocumentation() {
      this.showDocumentation = true;
    },
    closeDocumentation() {
      this.showDocumentation = false;
    },
    showToast(type, message) {
      this.toast = { show: true, type, message };
      setTimeout(() => this.hideToast(), 3000);
    },
    hideToast() {
      this.toast.show = false;
    },
    getToastIcon(type) {
      const icons = {
        success: 'check-circle',
        error: 'exclamation-circle',
        warning: 'exclamation-triangle',
        info: 'info-circle'
      };
      return icons[type] || 'info-circle';
    },
    async fetchCuotas() {
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
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
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
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
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
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
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
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
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
