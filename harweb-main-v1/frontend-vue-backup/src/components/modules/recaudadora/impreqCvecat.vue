<template>
  <div class="impreq-cvecat-page">
    <h1>Impresión de Orden de Requerimiento de Predial</h1>
    <form @submit.prevent="onBuscar">
      <div class="form-row">
        <label>Recaudadora:</label>
        <input v-model="form.recaud" type="number" required />
        <label>Folio Inicial:</label>
        <input v-model="form.folioini" type="number" required />
        <label>Folio Final:</label>
        <input v-model="form.foliofin" type="number" required />
        <label>Fecha:</label>
        <input v-model="form.fecha" type="date" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="requerimientos.length">
      <h2>Requerimientos encontrados</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Cuenta</th>
            <th>Ejecutor</th>
            <th>Zona</th>
            <th>Estado</th>
            <th>Seleccionar</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="req in requerimientos" :key="req.folioreq">
            <td>{{ req.folioreq }}</td>
            <td>{{ req.cvecuenta }}</td>
            <td>{{ req.cveejecut }}</td>
            <td>{{ req.zona_subzona }}</td>
            <td>{{ req.vigencia }}</td>
            <td><input type="checkbox" v-model="selectedFolios" :value="req.folioreq" /></td>
          </tr>
        </tbody>
      </table>
      <div class="actions">
        <button @click="onAsignar">Asignar</button>
        <button @click="onImprimir">Imprimir</button>
        <button @click="onReporte">Reporte PDF</button>
      </div>
    </div>
    <div v-if="pdfUrl">
      <h3>Reporte PDF generado</h3>
      <a :href="pdfUrl" target="_blank">Descargar PDF</a>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ImpreqCvecatPage',
  data() {
    return {
      form: {
        recaud: '',
        folioini: '',
        foliofin: '',
        fecha: ''
      },
      requerimientos: [],
      selectedFolios: [],
      loading: false,
      error: '',
      pdfUrl: ''
    };
  },
  methods: {
    async onBuscar() {
      this.loading = true;
      this.error = '';
      this.requerimientos = [];
      this.selectedFolios = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'listar',
            params: {
              recaud: this.form.recaud,
              folioini: this.form.folioini,
              foliofin: this.form.foliofin,
              fecha: this.form.fecha
            }
          }
        });
        if (res.data.eResponse.error) throw res.data.eResponse.error;
        this.requerimientos = res.data.eResponse.data;
      } catch (e) {
        this.error = e.toString();
      } finally {
        this.loading = false;
      }
    },
    async onAsignar() {
      if (!this.selectedFolios.length) {
        this.error = 'Seleccione al menos un folio para asignar.';
        return;
      }
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'asignar',
            params: {
              recaud: this.form.recaud,
              folioini: Math.min(...this.selectedFolios),
              foliofin: Math.max(...this.selectedFolios),
              ejecutor: prompt('Ingrese el número de ejecutor a asignar:'),
              fecha: this.form.fecha,
              usuario: this.$store.state.auth.user
            }
          }
        });
        if (res.data.eResponse.error) throw res.data.eResponse.error;
        alert('Asignación realizada correctamente.');
        this.onBuscar();
      } catch (e) {
        this.error = e.toString();
      } finally {
        this.loading = false;
      }
    },
    async onImprimir() {
      if (!this.selectedFolios.length) {
        this.error = 'Seleccione al menos un folio para imprimir.';
        return;
      }
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'imprimir',
            params: {
              recaud: this.form.recaud,
              folioini: Math.min(...this.selectedFolios),
              foliofin: Math.max(...this.selectedFolios),
              usuario: this.$store.state.auth.user
            }
          }
        });
        if (res.data.eResponse.error) throw res.data.eResponse.error;
        alert('Folios marcados como impresos.');
        this.onBuscar();
      } catch (e) {
        this.error = e.toString();
      } finally {
        this.loading = false;
      }
    },
    async onReporte() {
      if (!this.selectedFolios.length) {
        this.error = 'Seleccione al menos un folio para el reporte.';
        return;
      }
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'reporte',
            params: {
              recaud: this.form.recaud,
              folioini: Math.min(...this.selectedFolios),
              foliofin: Math.max(...this.selectedFolios)
            }
          }
        });
        if (res.data.eResponse.error) throw res.data.eResponse.error;
        this.pdfUrl = res.data.eResponse.pdf_url;
      } catch (e) {
        this.error = e.toString();
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.impreq-cvecat-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  display: flex;
  gap: 1rem;
  align-items: center;
  margin-bottom: 1rem;
}
.table {
  width: 100%;
  margin-top: 1rem;
}
.actions {
  margin-top: 1rem;
  display: flex;
  gap: 1rem;
}
.error {
  color: red;
  margin: 1rem 0;
}
</style>
