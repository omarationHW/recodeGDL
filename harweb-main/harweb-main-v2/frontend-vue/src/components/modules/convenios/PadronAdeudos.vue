<template>
  <div class="padron-adeudos-page">
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Reportes</span> &gt; <b>Padrón de Adeudos</b>
    </div>
    <h1>Padrón de Adeudos</h1>
    <div class="form-row">
      <label for="recaudadora">Oficina Recaudadora:</label>
      <select v-model="selectedRec" id="recaudadora">
        <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
          {{ rec.id_rec.toString().padStart(3, '0') }} - {{ rec.recaudadora }}
        </option>
      </select>
      <button @click="buscar" :disabled="loading">Buscar</button>
      <button @click="exportarExcel" :disabled="!padron.length || loading">Exportar Excel</button>
    </div>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="padron.length">
      <table class="data-table">
        <thead>
          <tr>
            <th>Tipo</th>
            <th>Subtipo</th>
            <th>Convenio</th>
            <th>Nombre</th>
            <th>Vigencia</th>
            <th>Fecha Inicio</th>
            <th>Plazo</th>
            <th>Tipo Plazo</th>
            <th>Cantidad Total</th>
            <th>1er. Pago</th>
            <th>Importe 1er. Pago</th>
            <th>Total Pagos</th>
            <th>Importe Pagado</th>
            <th>Parc. Adeudos</th>
            <th>Importe Adeudo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in padron" :key="row.convenio">
            <td>{{ row.tipo }}</td>
            <td>{{ row.subtipo }}</td>
            <td>{{ row.convenio }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.vigencia }}</td>
            <td>{{ row.fecha_otorg }}</td>
            <td>{{ row.plazo }}</td>
            <td>{{ row.tipo_plazo }}</td>
            <td>{{ row.cantidad }}</td>
            <td>{{ row.primer_pago }}</td>
            <td>{{ row.importe_primerpago }}</td>
            <td>{{ row.pagos_realizados }}</td>
            <td>{{ row.importe_pagado }}</td>
            <td>{{ row.parc_adeudo }}</td>
            <td>{{ row.importe_adeudo }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="!loading && !padron.length && searched">No hay datos para la recaudadora seleccionada.</div>
  </div>
</template>

<script>
export default {
  name: 'PadronAdeudosPage',
  data() {
    return {
      recaudadoras: [],
      selectedRec: '',
      padron: [],
      loading: false,
      error: '',
      searched: false
    };
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getRecaudadoras' })
        });
        const data = await res.json();
        if (data.success) {
          this.recaudadoras = data.data;
          if (this.recaudadoras.length) {
            this.selectedRec = this.recaudadoras[0].id_rec;
          }
        } else {
          this.error = 'Error al cargar recaudadoras';
        }
      } catch (e) {
        this.error = 'Error de red al cargar recaudadoras';
      } finally {
        this.loading = false;
      }
    },
    async buscar() {
      if (!this.selectedRec) return;
      this.loading = true;
      this.error = '';
      this.searched = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getPadronAdeudos',
            params: { rec_id: this.selectedRec }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.padron = data.data;
        } else {
          this.error = data.message || 'Error al consultar padrón';
          this.padron = [];
        }
      } catch (e) {
        this.error = 'Error de red al consultar padrón';
        this.padron = [];
      } finally {
        this.loading = false;
      }
    },
    async exportarExcel() {
      if (!this.selectedRec) return;
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'exportPadronAdeudosExcel',
            params: { rec_id: this.selectedRec }
          })
        });
        const data = await res.json();
        if (data.success && data.file) {
          // Descargar archivo
          const link = document.createElement('a');
          link.href = 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,' + data.file;
          link.download = data.filename || 'padron_adeudos.xlsx';
          document.body.appendChild(link);
          link.click();
          document.body.removeChild(link);
        } else {
          this.error = data.message || 'Error al exportar Excel';
        }
      } catch (e) {
        this.error = 'Error de red al exportar Excel';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.padron-adeudos-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  font-size: 0.95em;
  color: #888;
  margin-bottom: 1rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.data-table th, .data-table td {
  border: 1px solid #ccc;
  padding: 0.4rem 0.6rem;
  font-size: 0.95em;
}
.data-table th {
  background: #f0f0f0;
}
.loading {
  color: #007bff;
  font-weight: bold;
}
.error {
  color: #c00;
  font-weight: bold;
  margin: 1rem 0;
}
</style>
