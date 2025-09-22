<template>
  <div class="recargos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Recargos</li>
      </ol>
    </nav>
    <h2>Catálogo de Recargos</h2>
    <div class="mb-3">
      <button class="btn btn-success me-2" @click="showForm('create')">Alta</button>
      <button class="btn btn-primary me-2" :disabled="!selectedRow" @click="showForm('update')">Cambios</button>
      <button class="btn btn-danger me-2" :disabled="!selectedRow" @click="showForm('delete')">Baja</button>
      <button class="btn btn-secondary" @click="fetchRecargos">Refrescar</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Periodo Recargo</th>
          <th>% Recargo</th>
          <th>% Multa</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in recargos" :key="row.aso_mes_recargo" :class="{ 'table-active': selectedRow && selectedRow.aso_mes_recargo === row.aso_mes_recargo }" @click="selectRow(row)">
          <td>{{ formatPeriodo(row.aso_mes_recargo) }}</td>
          <td>{{ row.porc_recargo }}</td>
          <td>{{ row.porc_multa }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="formVisible" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ formTitle }}</h5>
            <button type="button" class="btn-close" @click="closeForm"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="submitForm">
              <div class="mb-3">
                <label for="aso_mes_recargo" class="form-label">Periodo Recargo (YYYY-MM)</label>
                <input v-model="form.aso_mes_recargo" :disabled="formMode==='update'||formMode==='delete'" type="month" id="aso_mes_recargo" class="form-control" required />
              </div>
              <div class="mb-3">
                <label for="porc_recargo" class="form-label">% Recargo</label>
                <input v-model.number="form.porc_recargo" :disabled="formMode==='delete'" type="number" step="0.01" id="porc_recargo" class="form-control" required />
              </div>
              <div class="mb-3">
                <label for="porc_multa" class="form-label">% Multa</label>
                <input v-model.number="form.porc_multa" :disabled="formMode==='delete'" type="number" step="0.01" id="porc_multa" class="form-control" required />
              </div>
              <div class="modal-footer">
                <button type="submit" class="btn btn-primary">Aceptar</button>
                <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
              </div>
            </form>
            <div v-if="formError" class="alert alert-danger mt-2">{{ formError }}</div>
          </div>
        </div>
      </div>
    </div>
    <div v-if="message" class="alert alert-info mt-3">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'RecargosPage',
  data() {
    return {
      recargos: [],
      selectedRow: null,
      formVisible: false,
      formMode: '', // create|update|delete
      form: {
        aso_mes_recargo: '',
        porc_recargo: '',
        porc_multa: ''
      },
      formError: '',
      message: ''
    };
  },
  computed: {
    formTitle() {
      switch (this.formMode) {
        case 'create': return 'Alta de Recargo';
        case 'update': return 'Cambios de Recargo';
        case 'delete': return 'Baja de Recargo';
        default: return '';
      }
    }
  },
  mounted() {
    this.fetchRecargos();
  },
  methods: {
    async fetchRecargos() {
      this.selectedRow = null;
      this.message = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recargos.list',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.recargos = res.data.data;
        } else {
          this.message = res.data.message || 'Error al cargar recargos';
        }
      } catch (error) {
        this.message = 'Error de conexión: ' + error.message;
      }
    },
    selectRow(row) {
      this.selectedRow = row;
    },
    showForm(mode) {
      this.formMode = mode;
      this.formError = '';
      if (mode === 'create') {
        this.form = { aso_mes_recargo: '', porc_recargo: '', porc_multa: '' };
      } else if (this.selectedRow) {
        this.form = {
          aso_mes_recargo: this.selectedRow.aso_mes_recargo.slice(0, 7),
          porc_recargo: this.selectedRow.porc_recargo,
          porc_multa: this.selectedRow.porc_multa
        };
      }
      this.formVisible = true;
    },
    closeForm() {
      this.formVisible = false;
      this.formError = '';
    },
    async submitForm() {
      let action = '';
      if (this.formMode === 'create') action = 'recargos.create';
      if (this.formMode === 'update') action = 'recargos.update';
      if (this.formMode === 'delete') action = 'recargos.delete';
      const payload = {
        aso_mes_recargo: this.form.aso_mes_recargo + '-01',
        porc_recargo: this.form.porc_recargo,
        porc_multa: this.form.porc_multa
      };
      try {
        const res = await this.$axios.post('/api/execute', {
          action,
          payload
        });
        if (res.data.status === 'success') {
          this.message = res.data.message || 'Operación exitosa';
          this.fetchRecargos();
          this.closeForm();
        } else {
          this.formError = res.data.message || 'Error en la operación';
        }
      } catch (error) {
        this.formError = 'Error de conexión: ' + error.message;
      }
    },
    formatPeriodo(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0');
    }
  }
};
</script>

<style scoped>
.recargos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.table-active {
  background-color: #e9ecef;
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
  min-width: 400px;
  box-shadow: 0 2px 16px rgba(0,0,0,0.2);
}
</style>
