<template>
  <div class="sdos-favor-ctrl-exp">
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Saldos a Favor - Control de Expedientes</span>
    </div>
    <div class="card">
      <h2>Control de Expedientes - Saldos a Favor</h2>
      <div class="form-row">
        <label for="status">Estatus:</label>
        <select v-model="selectedStatus" @change="onStatusChange">
          <option v-for="opt in statusOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
        </select>
        <button @click="searchFolios">Buscar Folios</button>
        <span class="total-folios">Total Folios: <strong>{{ totalFolios }}</strong></span>
      </div>
      <div class="form-row">
        <label>Folios encontrados:</label>
        <div class="folios-list">
          <div v-if="folios.length === 0">No hay folios para el criterio seleccionado.</div>
          <div v-else>
            <table class="folios-table">
              <thead>
                <tr>
                  <th></th>
                  <th>Folio</th>
                  <th>Año</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="folio in folios" :key="folio.folio">
                  <td><input type="checkbox" v-model="selectedFolios" :value="folio.folio" /></td>
                  <td>{{ folio.folio }}</td>
                  <td>{{ folio.axofol }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      <div class="form-row">
        <button @click="assignFolios" :disabled="selectedFolios.length === 0">Asignar Folios</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SdosFavorCtrlExp',
  data() {
    return {
      statusOptions: [],
      selectedStatus: '',
      folios: [],
      selectedFolios: [],
      totalFolios: 0
    };
  },
  created() {
    this.fetchStatusOptions();
    this.fetchTotalFolios();
  },
  methods: {
    async fetchStatusOptions() {
      const res = await this.$axios.post('/api/execute', { action: 'getStatusOptions' });
      this.statusOptions = res.data.data;
      this.selectedStatus = '';
    },
    async fetchTotalFolios() {
      const res = await this.$axios.post('/api/execute', { action: 'getTotalFolios', params: { status: this.selectedStatus } });
      this.totalFolios = res.data.data;
    },
    async searchFolios() {
      this.selectedFolios = [];
      const res = await this.$axios.post('/api/execute', { action: 'searchFolios', params: { status: this.selectedStatus } });
      this.folios = res.data.data;
      this.fetchTotalFolios();
    },
    async assignFolios() {
      if (this.selectedFolios.length === 0) return;
      const res = await this.$axios.post('/api/execute', {
        action: 'assignFolios',
        params: {
          folios: this.selectedFolios,
          new_status: 'AS' // Asignados
        }
      });
      if (res.data.status === 'success') {
        this.$notify({ type: 'success', message: res.data.message });
        this.searchFolios();
      } else {
        this.$notify({ type: 'error', message: res.data.message });
      }
    },
    onStatusChange() {
      this.searchFolios();
    }
  }
};
</script>

<style scoped>
.sdos-favor-ctrl-exp {
  max-width: 800px;
  margin: 0 auto;
}
.card {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.07);
}
.form-row {
  margin-bottom: 18px;
  display: flex;
  align-items: center;
}
.form-row label {
  min-width: 120px;
  font-weight: bold;
}
.folios-list {
  width: 100%;
}
.folios-table {
  width: 100%;
  border-collapse: collapse;
}
.folios-table th, .folios-table td {
  border: 1px solid #e0e0e0;
  padding: 6px 10px;
  text-align: left;
}
.total-folios {
  margin-left: 24px;
  color: #1976d2;
  font-size: 1.1em;
}
</style>
