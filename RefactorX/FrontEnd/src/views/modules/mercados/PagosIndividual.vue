<template>
  <div class="pagos-individual-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Consulta Individual de Pagos del Local</span>
    </nav>
    <h1>Consulta Individual de Pagos del Local</h1>
    <form @submit.prevent="buscarPago">
      <div class="form-row">
        <label for="id_local">ID Local:</label>
        <input v-model.number="form.id_local" type="number" required />
        <label for="axo">Año:</label>
        <input v-model.number="form.axo" type="number" required />
        <label for="periodo">Mes:</label>
        <input v-model.number="form.periodo" type="number" min="1" max="12" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="pago">
      <h2>Datos del Mercado</h2>
      <table class="info-table">
        <tr><th>Oficina</th><td>{{ pago.oficina }}</td></tr>
        <tr><th>Mercado</th><td>{{ pago.num_mercado }}</td></tr>
        <tr><th>Categoría</th><td>{{ pago.categoria }}</td></tr>
        <tr><th>Sección</th><td>{{ pago.seccion }}</td></tr>
        <tr><th>Local</th><td>{{ pago.local }}</td></tr>
        <tr><th>Letra</th><td>{{ pago.letra_local }}</td></tr>
        <tr><th>Bloque</th><td>{{ pago.bloque }}</td></tr>
        <tr><th>Descripción</th><td>{{ pago.descripcion_local }}</td></tr>
      </table>
      <h2>Datos del Pago</h2>
      <table class="info-table">
        <tr><th>Control</th><td>{{ pago.id_local }}</td></tr>
        <tr><th>Año</th><td>{{ pago.axo }}</td></tr>
        <tr><th>Mes</th><td>{{ pago.periodo }}</td></tr>
        <tr><th>Fecha de Pago</th><td>{{ pago.fecha_pago }}</td></tr>
        <tr><th>Oficina de Pago</th><td>{{ pago.oficina_pago }}</td></tr>
        <tr><th>Caja de Pago</th><td>{{ pago.caja_pago }}</td></tr>
        <tr><th>Operación de Pago</th><td>{{ pago.operacion_pago }}</td></tr>
        <tr><th>Importe Pagado</th><td>{{ pago.importe_pago }}</td></tr>
        <tr><th>Partida</th><td>{{ pago.folio }}</td></tr>
        <tr><th>Actualización</th><td>{{ pago.fecha_modificacion_1 }}</td></tr>
        <tr><th>Usuario</th><td>{{ pago.usuario }}</td></tr>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PagosIndividual',
  data() {
    return {
      form: {
        id_local: '',
        axo: '',
        periodo: ''
      },
      pago: null,
      loading: false,
      error: ''
    };
  },
  methods: {
    async buscarPago() {
      this.loading = true;
      this.error = '';
      this.pago = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getPagoIndividual',
            params: {
              id_local: this.form.id_local,
              axo: this.form.axo,
              periodo: this.form.periodo
            }
          })
        });
        const json = await res.json();
        if (json.success && json.data) {
          this.pago = json.data;
        } else {
          this.error = json.message || 'No se encontró el pago.';
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.pagos-individual-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.95em;
}
.form-row {
  display: flex;
  gap: 1em;
  align-items: center;
  margin-bottom: 1.5em;
}
.info-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 2em;
}
.info-table th {
  text-align: left;
  background: #f0f0f0;
  padding: 0.3em 0.7em;
}
.info-table td {
  padding: 0.3em 0.7em;
}
.loading {
  color: #888;
}
.error {
  color: #c00;
  margin: 1em 0;
}
</style>
