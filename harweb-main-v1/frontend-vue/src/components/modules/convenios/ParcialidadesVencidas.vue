<template>
  <div class="parcialidades-vencidas-page">
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Convenios</span> &gt; <span class="active">Parcialidades Vencidas</span>
    </div>
    <h1>Convenios con Parcialidades Vencidas</h1>
    <div class="actions-bar">
      <button @click="fetchData" :disabled="loading">Buscar</button>
      <button @click="exportExcel" :disabled="loading || rows.length === 0">Exportar Excel</button>
    </div>
    <div v-if="loading" class="loading">Cargando datos...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="rows.length > 0">
      <table class="data-table">
        <thead>
          <tr>
            <th>Convenio</th>
            <th>Nombre</th>
            <th>Domicilio</th>
            <th>Subtipo</th>
            <th>Fecha Convenio</th>
            <th>Total Conveniado</th>
            <th>Periodos</th>
            <th>Parc. Conveniadas</th>
            <th>Registro</th>
            <th>Parc. Vencidas</th>
            <th>Adeudo</th>
            <th>Intereses</th>
            <th>Recargos</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.convenio">
            <td>{{ row.convenio }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.domicilio }}</td>
            <td>{{ row.subtipo }}</td>
            <td>{{ formatDate(row.fechaconv) }}</td>
            <td class="right">{{ formatCurrency(row.totalconv) }}</td>
            <td>{{ row.periodos }}</td>
            <td class="right">{{ row.parcconv }}</td>
            <td>{{ row.registro }}</td>
            <td class="right">{{ row.parcvenc }}</td>
            <td class="right">{{ formatCurrency(row.adeudo) }}</td>
            <td class="right">{{ formatCurrency(row.intereses) }}</td>
            <td class="right">{{ formatCurrency(row.recargos) }}</td>
            <td class="right">{{ formatCurrency(row.total) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!loading">No hay datos para mostrar.</div>
  </div>
</template>

<script>
export default {
  name: 'ParcialidadesVencidasPage',
  data() {
    return {
      rows: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchData() {
      this.loading = true;
      this.error = '';
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getVencidas',
              params: {}
            }
          })
        });
        const json = await response.json();
        if (json.eResponse.status === 'success') {
          this.rows = json.eResponse.data;
        } else {
          this.error = json.eResponse.message || 'Error al obtener datos';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    async exportExcel() {
      // Para demo, simplemente descarga los datos como CSV
      const csv = this.toCSV(this.rows);
      const blob = new Blob([csv], { type: 'text/csv' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'parcialidades_vencidas.csv';
      a.click();
      URL.revokeObjectURL(url);
    },
    toCSV(rows) {
      if (!rows.length) return '';
      const headers = Object.keys(rows[0]);
      const csvRows = [headers.join(',')];
      for (const row of rows) {
        csvRows.push(headers.map(h => '"' + (row[h] ?? '') + '"').join(','));
      }
      return csvRows.join('\n');
    },
    formatDate(date) {
      if (!date) return '';
      const d = new Date(date);
      return d.toLocaleDateString();
    },
    formatCurrency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  },
  mounted() {
    this.fetchData();
  }
};
</script>

<style scoped>
.parcialidades-vencidas-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  font-size: 0.95rem;
  margin-bottom: 1rem;
  color: #888;
}
.breadcrumb .active {
  font-weight: bold;
  color: #333;
}
h1 {
  margin-bottom: 1.5rem;
}
.actions-bar {
  margin-bottom: 1rem;
}
.actions-bar button {
  margin-right: 1rem;
  padding: 0.5rem 1.2rem;
  font-size: 1rem;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 2rem;
}
.data-table th, .data-table td {
  border: 1px solid #ddd;
  padding: 0.4rem 0.7rem;
}
.data-table th {
  background: #f5f5f5;
  text-align: center;
}
.data-table td.right {
  text-align: right;
}
.loading {
  color: #007bff;
  font-weight: bold;
}
.error {
  color: #c00;
  font-weight: bold;
  margin-bottom: 1rem;
}
</style>
