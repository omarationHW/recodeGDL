<template>
  <div class="padron-locales-page">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Padron de Locales
    </div>
    <h1>Padron de Mercados</h1>
    <div class="filters">
      <label for="recaudadora">Oficina Recaudadora:</label>
      <select v-model="selectedRecaudadora" id="recaudadora">
        <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
          {{ rec.id_rec }} - {{ rec.recaudadora }}
        </option>
      </select>
      <button @click="fetchPadron">Generar Padron</button>
      <button @click="exportPadron('excel')">Exportar a Excel</button>
      <button @click="exportPadron('txt')">Exportar a Texto</button>
    </div>
    <div v-if="loading" class="loading">Cargando...</div>
    <table v-if="padron.length" class="padron-table">
      <thead>
        <tr>
          <th>Rec.</th>
          <th>Merc.</th>
          <th>Nombre Mercado</th>
          <th>Cat.</th>
          <th>Sección</th>
          <th>Local</th>
          <th>Letra</th>
          <th>Bloque</th>
          <th>Nombre Locatario</th>
          <th>Superficie</th>
          <th>Renta</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in padron" :key="row.id_local">
          <td>{{ row.oficina }}</td>
          <td>{{ row.num_mercado }}</td>
          <td>{{ row.descripcion }}</td>
          <td>{{ row.categoria }}</td>
          <td>{{ row.seccion }}</td>
          <td>{{ row.local }}</td>
          <td>{{ row.letra_local }}</td>
          <td>{{ row.bloque }}</td>
          <td>{{ row.nombre }}</td>
          <td>{{ row.superficie }}</td>
          <td>{{ row.renta | currency }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'PadronLocalesPage',
  data() {
    return {
      recaudadoras: [],
      selectedRecaudadora: '',
      padron: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
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
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getRecaudadoras' })
        });
        const data = await res.json();
        if (data.success) {
          this.recaudadoras = data.data;
          if (this.recaudadoras.length) {
            this.selectedRecaudadora = this.recaudadoras[0].id_rec;
          }
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async fetchPadron() {
      if (!this.selectedRecaudadora) {
        this.error = 'Seleccione una recaudadora';
        return;
      }
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getPadronLocales',
            params: { recaudadora: this.selectedRecaudadora }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.padron = data.data;
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async exportPadron(format) {
      if (!this.selectedRecaudadora) {
        this.error = 'Seleccione una recaudadora';
        return;
      }
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'exportPadronLocales',
            params: { recaudadora: this.selectedRecaudadora, format }
          })
        });
        const data = await res.json();
        if (data.success) {
          // Aquí se puede implementar la descarga del archivo
          alert('Exportación simulada. (Implementar descarga real en backend)');
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.padron-locales-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1em;
}
.filters {
  margin-bottom: 1em;
  display: flex;
  align-items: center;
  gap: 1em;
}
.padron-table {
  width: 100%;
  border-collapse: collapse;
}
.padron-table th, .padron-table td {
  border: 1px solid #ccc;
  padding: 0.3em 0.5em;
  text-align: left;
}
.loading {
  color: #007bff;
}
.error {
  color: #c00;
  margin-top: 1em;
}
.breadcrumb {
  margin-bottom: 0.5em;
  font-size: 0.95em;
  color: #888;
}
</style>
