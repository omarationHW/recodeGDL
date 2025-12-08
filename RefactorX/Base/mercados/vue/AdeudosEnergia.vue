<template>
  <div class="adeudos-energia-page">
    <div v-if="initialLoading" class="global-loading-overlay">
      <div class="spinner"></div>
      <p>Cargando...</p>
    </div>
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Reportes</span> &gt; <span class="active">Adeudos Energía</span>
    </div>
    <h1>Listado de Adeudos de Energía Eléctrica</h1>
    <div class="form-row">
      <label>Año de Adeudo</label>
      <input type="number" v-model="axo" min="1994" max="2999" />
      <label>Oficina</label>
      <select v-model="oficina">
        <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
      </select>
      <button @click="buscar" :disabled="loading">Buscar</button>
      <button @click="exportarExcel" :disabled="loading || !adeudos.length">Excel</button>
      <button @click="imprimir" :disabled="loading || !adeudos.length">Imprimir</button>
    </div>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <table v-if="adeudos.length" class="adeudos-table">
      <thead>
        <tr>
          <th>Rec.</th>
          <th>Merc.</th>
          <th>Cat.</th>
          <th>Sec.</th>
          <th>Local</th>
          <th>Letra</th>
          <th>Bloque</th>
          <th>Consumo</th>
          <th>Nombre</th>
          <th>Adicionales</th>
          <th>Cuota Bim/Mes</th>
          <th>Año Adeudo</th>
          <th>Adeudo</th>
          <th>Periodo Adeudo</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in adeudos" :key="row.id_local + '-' + row.id_energia">
          <td>{{ row.oficina }}</td>
          <td>{{ row.num_mercado }}</td>
          <td>{{ row.categoria }}</td>
          <td>{{ row.seccion }}</td>
          <td>{{ row.local }}</td>
          <td>{{ row.letra_local }}</td>
          <td>{{ row.bloque }}</td>
          <td>{{ row.cve_consumo }}</td>
          <td>{{ row.nombre }}</td>
          <td>{{ row.local_adicional }}</td>
          <td>{{ row.cuota | currency }}</td>
          <td>{{ row.axo }}</td>
          <td>{{ row.adeudo | currency }}</td>
          <td>{{ row.meses }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="!loading && !adeudos.length" class="no-data">No hay datos para los filtros seleccionados.</div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosEnergiaPage',
  data() {
    const currentYear = new Date().getFullYear();
    return {
      initialLoading: true,
      axo: currentYear,
      oficina: '',
      recaudadoras: [],
      adeudos: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') return '$' + val.toLocaleString('es-MX', {minimumFractionDigits: 2});
      return val;
    }
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.getRecaudadoras',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.recaudadoras = res.data.data;
          if (this.recaudadoras.length) this.oficina = this.recaudadoras[0].id_rec;
        } else {
          this.error = res.data.message || 'Error al cargar recaudadoras';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
        this.initialLoading = false;
      }
    },
    async buscar() {
      this.loading = true;
      this.error = '';
      this.adeudos = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.getAdeudosEnergia',
          payload: {axo: this.axo, oficina: this.oficina}
        });
        if (res.data.status === 'success') {
          this.adeudos = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar adeudos';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    async exportarExcel() {
      // Puede implementarse descarga de archivo en backend, aquí solo ejemplo
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.exportExcel',
          payload: {axo: this.axo, oficina: this.oficina}
        });
        if (res.data.status === 'success') {
          // El frontend debe convertir res.data.data a Excel (puede usar SheetJS)
          alert('Exportación a Excel simulada. Integrar SheetJS para descarga real.');
        } else {
          this.error = res.data.message || 'Error al exportar';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    async imprimir() {
      // Puede implementarse generación de PDF en backend, aquí solo ejemplo
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.printReport',
          payload: {axo: this.axo, oficina: this.oficina}
        });
        if (res.data.status === 'success') {
          // El frontend debe mostrar el PDF generado
          alert('Impresión simulada. Integrar generación de PDF para impresión real.');
        } else {
          this.error = res.data.message || 'Error al imprimir';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.adeudos-energia-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  position: relative;
}
.breadcrumb {
  font-size: 0.9rem;
  color: #888;
  margin-bottom: 1rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.form-row label {
  font-weight: bold;
}
.adeudos-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.adeudos-table th, .adeudos-table td {
  border: 1px solid #ccc;
  padding: 0.3rem 0.5rem;
  text-align: left;
}
.adeudos-table th {
  background: #f5f5f5;
}
.loading {
  color: #007bff;
  font-weight: bold;
}
.error {
  color: #b00;
  font-weight: bold;
}
.no-data {
  color: #888;
  margin-top: 2rem;
}
</style>
