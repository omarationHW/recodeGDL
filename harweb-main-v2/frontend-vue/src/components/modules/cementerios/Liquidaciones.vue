<template>
  <div class="liquidaciones-page">
    <nav class="breadcrumb">
      <span @click="$router.push('/')">Inicio</span> /
      <span>Liquidaciones</span>
    </nav>
    <h1>Consulta de Liquidaciones</h1>
    <form @submit.prevent="onCalculate">
      <div class="form-row">
        <label>Cementerio:</label>
        <select v-model="form.cementerio" required>
          <option v-for="cem in cemeteries" :key="cem.cementerio" :value="cem.cementerio">
            {{ cem.nombre }} ({{ cem.cementerio }})
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Años a Liquidar:</label>
        <input type="number" v-model.number="form.anio_desde" min="1998" required placeholder="Desde" style="width:80px;" />
        <input type="number" v-model.number="form.anio_hasta" min="1998" required placeholder="Hasta" style="width:80px; margin-left:10px;" />
        <label style="margin-left:20px;">Metros:</label>
        <input type="number" v-model.number="form.metros" min="0.5" step="0.001" required style="width:100px;" />
        <label style="margin-left:20px;">Tipo:</label>
        <select v-model="form.tipo" required>
          <option value="F">Fosa</option>
          <option value="U">Urna</option>
          <option value="G">Gaveta</option>
        </select>
        <label style="margin-left:20px;">Nuevo:</label>
        <input type="checkbox" v-model="form.nuevo" />
      </div>
      <div class="form-row">
        <label>Mes de Liquidación:</label>
        <input type="number" v-model.number="form.mes" min="1" max="12" required style="width:60px;" />
      </div>
      <div class="form-row">
        <button type="submit">Calcular</button>
        <button type="button" @click="onPrint" :disabled="!result">Imprimir</button>
      </div>
    </form>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="result">
      <h2>Detalle de Liquidación</h2>
      <table class="liquidaciones-table">
        <thead>
          <tr>
            <th>Año</th>
            <th>Mantenimiento</th>
            <th>Recargos</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in result" :key="row.axo_cuota">
            <td>{{ row.axo_cuota }}</td>
            <td>{{ currency(row.manten) }}</td>
            <td>{{ currency(row.recargos) }}</td>
            <td>{{ currency(row.manten + row.recargos) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th>Total</th>
            <th>{{ currency(totalMant) }}</th>
            <th>{{ currency(totalRec) }}</th>
            <th>{{ currency(totalMant + totalRec) }}</th>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LiquidacionesPage',
  data() {
    return {
      cemeteries: [],
      form: {
        cementerio: '',
        anio_desde: new Date().getFullYear() - 6,
        anio_hasta: new Date().getFullYear(),
        metros: 3.125,
        tipo: 'F',
        nuevo: false,
        mes: new Date().getMonth() + 1
      },
      result: null,
      error: null
    };
  },
  computed: {
    totalMant() {
      if (!this.result) return 0;
      return this.result.reduce((sum, r) => sum + Number(r.manten), 0);
    },
    totalRec() {
      if (!this.result) return 0;
      return this.result.reduce((sum, r) => sum + Number(r.recargos), 0);
    }
  },
  methods: {
    currency(val) {
      return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(val);
    },
    async fetchCemeteries() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'list_cemeteries' } })
      });
      const data = await res.json();
      this.cemeteries = data.eResponse.data || [];
      if (this.cemeteries.length > 0) this.form.cementerio = this.cemeteries[0].cementerio;
    },
    async onCalculate() {
      this.error = null;
      this.result = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'calculate_liquidation',
              params: { ...this.form }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.result = data.eResponse.data;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor';
      }
    },
    async onPrint() {
      // Simula impresión (en real, podría abrir PDF)
      alert('Función de impresión no implementada.');
    }
  },
  mounted() {
    this.fetchCemeteries();
  }
};
</script>

<style scoped>
.liquidaciones-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  font-size: 0.95em;
  margin-bottom: 1em;
  color: #888;
}
.breadcrumb span {
  cursor: pointer;
  color: #007bff;
}
.breadcrumb span:last-child {
  color: #333;
  cursor: default;
}
.form-row {
  margin-bottom: 1em;
  display: flex;
  align-items: center;
}
.form-row label {
  margin-right: 0.5em;
  min-width: 100px;
}
.liquidaciones-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1em;
}
.liquidaciones-table th, .liquidaciones-table td {
  border: 1px solid #ccc;
  padding: 0.5em 1em;
  text-align: right;
}
.liquidaciones-table th {
  background: #f8f8f8;
}
.error {
  color: #b00;
  margin: 1em 0;
}
</style>
