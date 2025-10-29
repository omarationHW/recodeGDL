<template>
  <div class="paso-mdos-page">
    <h1>Paso Pagos Mercados (Migración Tianguis a Padron)</h1>
    <div class="actions">
      <button @click="loadTianguis">Cargar Tianguis</button>
      <button @click="migrarTianguis" :disabled="loading || tianguis.length === 0">Migrar a Padron</button>
    </div>
    <div v-if="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="tianguis.length > 0">
      <h2>Registros de Tianguis</h2>
      <table class="table table-sm table-bordered">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Nombre</th>
            <th>Domicilio</th>
            <th>Colonia</th>
            <th>Poblacion</th>
            <th>Superficie</th>
            <th>Giro</th>
            <th>Descuento</th>
            <th>Motivo Descuento</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in tianguis" :key="row.Folio">
            <td>{{ row.Folio }}</td>
            <td>{{ row.Nombre }}</td>
            <td>{{ row.Domicilio }}</td>
            <td>{{ row.Colonia }}</td>
            <td>{{ row.Poblacion }}</td>
            <td>{{ row.Superficie }}</td>
            <td>{{ row.Giro }}</td>
            <td>{{ row.Descuento }}</td>
            <td>{{ row.MotivoDescuento }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="result">
      <h2>Resultado de Migración</h2>
      <div>Existentes: {{ result.existentes }}</div>
      <div>Errores: {{ result.errores.length }}</div>
      <ul v-if="result.errores.length">
        <li v-for="err in result.errores" :key="err.folio">Folio: {{ err.folio }} - {{ err.error }}</li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PasoMdosPage',
  data() {
    return {
      tianguis: [],
      loading: false,
      error: '',
      result: null
    }
  },
  methods: {
    async loadTianguis() {
      this.loading = true;
      this.error = '';
      this.result = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'get_tianguis' })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.tianguis = data.data;
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    },
    async migrarTianguis() {
      if (!confirm('¿Está seguro de migrar todos los registros de Tianguis a Padron?')) return;
      this.loading = true;
      this.error = '';
      this.result = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'migrar_tianguis_a_padron', data: { user_id: 1 } })
        });
        const data = await res.json();
        if (data.status === 'success') {
          this.result = data.data;
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    }
  }
}
</script>

<style scoped>
.paso-mdos-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.actions {
  margin-bottom: 1rem;
}
.error {
  color: red;
}
table {
  width: 100%;
  font-size: 0.95em;
}
th, td {
  padding: 0.2em 0.5em;
}
</style>
